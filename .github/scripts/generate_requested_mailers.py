from __future__ import annotations

import html
import re
import shutil
import struct
import zipfile
from pathlib import Path


ROOT = Path(r"c:\Users\user\OneDrive\digidanWork\Mailers")

JOB_NG = ROOT / r"2026\ZAS26111017  2026_SEWA Retainer_CE NG _ Cheest Freezer + Crystal UHD _ Mailers _ W20"
JOB_SA = ROOT / r"2026\ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20"
JOB_AI = ROOT / r"2026\TODO ZAS26113053 _ ROA _ MX Samsung AI Week _ W21"

BRANDSTORE_SOURCE = ROOT / r"2026\ZAS26088075  2026_SSA Retainer_Digital_CRM MX _ Galaxy S26 Brandstores _ Mailer _ W12\ZAS26088075_2026_SSA Retainer_Digital_CRM MX_Galaxy S26 Brandstores_Mailer_W12.html"

SHARP = "Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif"
BODY = "avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif"
MIRROR_PAGE_BLOCK = "<% if ( document.mode != 'mirror' && document.mode != 'forward' ) { %><a _type=\"mirrorPage\" href=\"<%@ include view='MirrorPageUrl' %>\" target=\"_blank\" rel=\"noopener noreferrer\" class=\"header-dm-text inline-link\" style=\"color: #000001; text-decoration: none;\"><span class=\"inline-link\" style=\"text-decoration: none; color: #B8B7B4;\">View online</span></a><% } %>"
UNSUBSCRIBE_URL = "https://samsung-mena-mkt-prod6-m.adobe-campaign.com/webApp/smgUnsub?id=<%= escapeUrl(recipient.cryptedId) %>&lang=en&unsub=true"

FOOTER_FILES = {
    "ng": ROOT / "footers" / "footer_ng.txt",
    "gh": ROOT / "footers" / "footer_gh.txt",
    "ke": ROOT / "footers" / "footer_ke.txt",
    "tz": ROOT / "footers" / "footer_tz.txt",
    "sn": ROOT / "footers" / "footer_sn.txt",
    "ci": ROOT / "footers" / "footer_ci.txt",
}

COUNTRY_TITLES = {
    "NG": "Samsung Nigeria",
    "GH": "Samsung Ghana",
    "KE": "Samsung Kenya",
    "TZ": "Samsung Tanzania",
    "SN": "Samsung Senegal",
    "CIV": "Samsung Cote d'Ivoire",
    "SA": "Samsung South Africa",
}


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8", newline="\n")


def replace_unsubscribe_markup(content: str) -> str:
    content = content.replace("\r\n", "\n")
    content = re.sub(
        r'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^\"]*"',
        f'href="{UNSUBSCRIBE_URL}"',
        content,
    )
    content = content.replace("©", "&copy;")
    return content


def load_footer(code: str) -> str:
    return replace_unsubscribe_markup(read_text(FOOTER_FILES[code]))


def load_brandstore_footer() -> str:
    marker = '<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color: #fff;" width="600">'
    source = read_text(BRANDSTORE_SOURCE)
    index = source.rfind(marker)
    if index == -1:
        raise ValueError("Could not locate brandstore footer block")
    return replace_unsubscribe_markup(source[index:])


def image_size(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        signature = handle.read(24)
        if signature.startswith(b"\x89PNG\r\n\x1a\n"):
            width, height = struct.unpack(">II", signature[16:24])
            return int(width), int(height)
        if signature[:2] == b"\xff\xd8":
            handle.seek(2)
            while True:
                marker_start = handle.read(1)
                if not marker_start:
                    break
                if marker_start != b"\xff":
                    continue
                marker = handle.read(1)
                while marker == b"\xff":
                    marker = handle.read(1)
                if not marker:
                    break
                marker_byte = marker[0]
                if marker_byte in {0xD8, 0xD9}:
                    continue
                length = struct.unpack(">H", handle.read(2))[0]
                if marker_byte in {0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF}:
                    handle.read(1)
                    height, width = struct.unpack(">HH", handle.read(4))
                    return int(width), int(height)
                handle.seek(length - 2, 1)
    raise ValueError(f"Unsupported image type: {path}")


def scaled_dimensions(path: Path, display_width: int | None = None) -> tuple[int, int]:
    width, height = image_size(path)
    if display_width is None or display_width == width:
        return width, height
    display_height = round(height * (display_width / width))
    return display_width, display_height


def image_tag(name: str, source_path: Path, alt_text: str, display_width: int | None = None, margin: str = "auto") -> str:
    width, height = scaled_dimensions(source_path, display_width)
    return (
        f'<img alt="{html.escape(alt_text, quote=True)}" border="0" height="{height}" '
        f'src="{name}" style="display:block; width:{width}px; height:{height}px; margin:{margin};" width="{width}">'
    )


def linked_image(name: str, source_path: Path, alt_text: str, href: str, display_width: int | None = None) -> str:
    return f'<a href="{href}" target="_blank">{image_tag(name, source_path, alt_text, display_width)}</a>'


def document_shell(title: str, preheader: str, content: str, footer: str, body_background: str = "#555555") -> str:
    return (
        "<!DOCTYPE html>\n"
        "<html>\n"
        "<head>\n"
        '<meta http-equiv="content-type" content="text/html; charset=utf-8">\n'
        '<meta name="viewport" content="width=600">\n'
        '<meta name="format-detection" content="telephone=no">\n'
        f"<title>{html.escape(title)}</title>\n"
        "</head>\n"
        f'<body style="background-color:{body_background}; margin:0; padding:0;">\n'
        f'<span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;">{html.escape(preheader)}</span>\n'
        '<table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">\n'
        "    <tbody>\n"
        "        <tr>\n"
        '            <td align="center" valign="top">\n'
        '                <table border="0" cellpadding="0" cellspacing="0" width="100%">\n'
        "                    <tbody>\n"
        "                        <tr>\n"
        '                            <td align="center" valign="top" width="10"></td>\n'
        '                            <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"><br>\n'
        f'                                {MIRROR_PAGE_BLOCK}<br>\n'
        '                                &nbsp; &nbsp; &nbsp;&nbsp;</td>\n'
        '                            <td align="center" valign="top" width="10"></td>\n'
        "                        </tr>\n"
        "                        <tr>\n"
        '                            <td align="center" valign="top" width="10"></td>\n'
        '                            <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"></td>\n'
        '                            <td align="center" valign="top" width="10"></td>\n'
        "                        </tr>\n"
        "                    </tbody>\n"
        "                </table>\n"
        f"{content}\n"
        f"{footer}"
    )


def flatten_output(job_dir: Path, basename: str, html_content: str, image_map: dict[Path, str]) -> None:
    published_dir = job_dir / "Published"
    folder = published_dir / basename
    published_dir.mkdir(parents=True, exist_ok=True)
    if folder.exists():
        shutil.rmtree(folder)
    folder.mkdir(parents=True, exist_ok=True)

    html_name = f"{basename}.html"
    html_path = folder / html_name
    write_text(html_path, html_content)
    write_text(published_dir / html_name, html_content)

    copied_names: list[str] = []
    for source_path, target_name in image_map.items():
        shutil.copy2(source_path, folder / target_name)
        copied_names.append(target_name)

    local_srcs = {
        match
        for match in re.findall(r'src="([^\"]+)"', html_content)
        if not match.startswith("http")
    }
    missing = sorted(src for src in local_srcs if not (folder / src).exists())
    if missing:
        raise FileNotFoundError(f"Missing local assets for {basename}: {missing}")
    if "MirrorPageUrl" not in html_content:
        raise ValueError(f"Missing MirrorPage markup in {basename}")
    if UNSUBSCRIBE_URL not in html_content:
        raise ValueError(f"Missing live unsubscribe URL in {basename}")
    if "YYYYY" in html_content or "ZZZZZ" in html_content:
        raise ValueError(f"Old campaign placeholders still present in {basename}")

    zip_path = folder / f"{basename}.zip"
    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        archive.write(html_path, arcname=html_name)
        for image_name in copied_names:
            archive.write(folder / image_name, arcname=image_name)

    with zipfile.ZipFile(zip_path, "r") as archive:
        entries = archive.namelist()
        expected = {html_name, *copied_names}
        if set(entries) != expected:
            raise ValueError(f"Zip validation failed for {basename}: {entries}")


def build_ng_mailer(
    *,
    hero_name: str,
    hero_source: Path,
    hero_alt: str,
    button_name: str,
    button_source: Path,
    button_alt: str,
    link: str,
    preheader: str,
    heading_html: str,
    body_html: str,
) -> tuple[str, dict[Path, str]]:
    content = (
        '<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">\n'
        "    <tbody>\n"
        f'        <tr><td style="text-align:center; font-size:0; line-height:0;">{linked_image(hero_name, hero_source, hero_alt, link, 600)}</td></tr>\n'
        "    </tbody>\n"
        "</table>\n"
        '<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">\n'
        "    <tbody>\n"
        '        <tr><td height="56" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center; padding:0 52px;"><span style="font-size:46px; line-height:52px;"><strong><span style="font-family:{SHARP}; color:#000000;">{heading_html}</span></strong></span></td></tr>\n'
        '        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center; padding:0 68px;"><span style="font-size:22px; line-height:32px;"><span style="font-family:{BODY}; color:#000000;">{body_html}</span></span></td></tr>\n'
        '        <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center;"><span style="font-size:16px; line-height:22px;"><span style="font-family:{BODY}; color:#5E5E5E;">Available at all authorized Samsung stores nationwide.</span></span></td></tr>\n'
        '        <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center;">{linked_image(button_name, button_source, button_alt, link)}</td></tr>\n'
        '        <tr><td height="60" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        "    </tbody>\n"
        "</table>"
    )
    footer = load_footer("ng")
    html_content = document_shell("Samsung Nigeria", preheader, content, footer)
    image_map = {
        hero_source: hero_name,
        button_source: button_name,
    }
    return html_content, image_map


def price_block(
    badge_name: str,
    badge_source: Path,
    badge_alt: str,
    now_price: str,
    save_price: str,
    include_header: bool,
    product_name: str = "",
    model_name: str = "",
) -> str:
    badge_markup = image_tag(badge_name, badge_source, badge_alt)
    header_row = ""
    if include_header:
        header_row = (
            f'<tr><td style="background-color:#000000; color:#FFFFFF; text-align:center; padding:8px 6px 7px 6px; border-bottom:1px solid #000000;"><span style="font-size:11px; line-height:14px;"><strong><span style="font-family:{SHARP}; color:#FFFFFF;">{product_name}</span></strong></span><br><span style="font-size:10px; line-height:12px;"><span style="font-family:{BODY}; color:#FFFFFF;">{model_name}</span></span></td></tr>'
        )
    return (
        '<table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; width:152px;" width="152">'
        '<tbody>'
        '<tr>'
        f'<td style="width:22px; background-color:#000000; border:1px solid #000000; border-right:0; text-align:center; vertical-align:middle; padding:4px 0;">{badge_markup}</td>'
        '<td style="width:130px; border:1px solid #000000; padding:0;">'
        '<table border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; width:130px;" width="130">'
        '<tbody>'
        f'{header_row}'
        f'<tr><td style="background-color:#FFFFFF; text-align:center; padding:10px 6px 8px 6px; border-bottom:1px solid #000000;"><span style="font-size:12px; line-height:14px;"><span style="font-family:{SHARP}; color:#000000;">Now</span></span><span style="font-size:22px; line-height:24px;"><strong><span style="font-family:{SHARP}; color:#000000;">&nbsp;{now_price}</span></strong></span></td></tr>'
        f'<tr><td style="background-color:#FFFFFF; text-align:center; padding:10px 6px 8px 6px;"><span style="font-size:12px; line-height:14px;"><span style="font-family:{SHARP}; color:#000000;">Save</span></span><span style="font-size:22px; line-height:24px;"><strong><span style="font-family:{SHARP}; color:#000000;">&nbsp;{save_price}</span></strong></span></td></tr>'
        '</tbody>'
        '</table>'
        '</td>'
        '</tr>'
        '</tbody>'
        '</table>'
    )


def product_column(
    image_name: str,
    image_source: Path,
    image_alt: str,
    link: str,
    blocks: list[str],
) -> str:
    rows = [
        f'<tr><td style="text-align:center; font-size:0; line-height:0;">{linked_image(image_name, image_source, image_alt, link)}</td></tr>',
        '<tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>',
    ]
    for index, block in enumerate(blocks):
        rows.append(f'<tr><td style="text-align:center;">{block}</td></tr>')
        if index != len(blocks) - 1:
            rows.append('<tr><td height="8" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>')
    return (
        '<table align="center" border="0" cellpadding="0" cellspacing="0" width="164">'
        '<tbody>'
        f'{"".join(rows)}'
        '</tbody>'
        '</table>'
    )


def build_brandstore_mailer() -> tuple[str, dict[Path, str]]:
    catalogue_link = "https://images.samsung.com/is/content/samsung/assets/za/pdf/ZAS26076279_Brand_Store_Mothers_Day_Showcase_FA_804273_1.pdf"
    store_link = "https://www.samsung.com/za/samsung-experience-store/about/"

    kv_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "KV" / "Group 1136.png"
    flower_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "Flowers" / "Image 125.png"
    ultra_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "Products" / "Mask Group 8.png"
    plus_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "Products" / "Group 13.png"
    s26_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "Products" / "Mask Group 19.png"
    badge_1tb_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "groupimage_01-1TB.png"
    badge_512_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "groupimage_01-512gb.png"
    badge_256_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "groupimage_01-256gb.png"
    button_catalogue_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "Buttons" / "Group 1125.png"
    button_store_source = JOB_SA / "ZAS26088143 _ 2026_SSA Retainer_Digital_CRM MX _ Brandstores Mother's Day _ Mailer _ W20_Assets" / "Buttons" / "Group 1126.png"

    ultra_blocks = [
        price_block("Badge_1TB.png", badge_1tb_source, "1TB", "R37 999", "R4 000", True, "Galaxy S26 Ultra", "SM-S948B"),
        price_block("Badge_512GB.png", badge_512_source, "512GB", "R30 999", "R4 000", False),
        price_block("Badge_256GB.png", badge_256_source, "256GB", "R28 999", "R2 000", False),
    ]
    plus_blocks = [
        price_block("Badge_512GB.png", badge_512_source, "512GB", "R25 999", "R4 000", True, "Galaxy S26+", "SM-S947"),
        price_block("Badge_256GB.png", badge_256_source, "256GB", "R23 999", "R2 000", False),
    ]
    s26_blocks = [
        price_block("Badge_512GB.png", badge_512_source, "512GB", "R20 999", "R2 000", True, "Galaxy S26", "SM-S942"),
        price_block("Badge_256GB.png", badge_256_source, "256GB", "R18 999", "R2 000", False),
    ]

    columns_html = (
        '<table align="center" border="0" cellpadding="0" cellspacing="0" width="540">'
        '<tbody>'
        '<tr>'
        f'<td align="center" valign="top" width="164">{product_column("Product_S26_Ultra.png", ultra_source, "Galaxy S26 Ultra", catalogue_link, ultra_blocks)}</td>'
        '<td width="24"></td>'
        f'<td align="center" valign="top" width="164">{product_column("Product_S26_Plus.png", plus_source, "Galaxy S26+", catalogue_link, plus_blocks)}</td>'
        '<td width="24"></td>'
        f'<td align="center" valign="top" width="164">{product_column("Product_S26.png", s26_source, "Galaxy S26", catalogue_link, s26_blocks)}</td>'
        '</tr>'
        '</tbody>'
        '</table>'
    )

    store_list_section = (
        '<table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#fff;" width="600">\n'
        '    <tbody>\n'
        '        <tr><td style="text-align:left;"><br>&nbsp; &nbsp;</td></tr>\n'
        '        <tr>\n'
        '            <td style="text-align:center;">\n'
        '                <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:500px;">\n'
        '                    <tbody>\n'
        '                        <tr>\n'
        f'                            <td style="line-height:9px; text-align:left; width:33%; vertical-align:top;"><span style="font-size:9px;"><span style="font-family:{BODY};"><strong>Gauteng:</strong><br>Clearwater - 011 615 1157<br>Cresta - 011 615 1157<br>Sandton City - 010 001 9440<br>Mall of Africa - 010 001 9441<br>Fourways Crossing - 011 465 1466<br>Menlyn - 012 368 9107<br>Eastgate - 011 615 1157</span></span></td>\n'
        f'                            <td style="line-height:9px; text-align:left; width:34%; vertical-align:top;"><span style="font-size:9px;"><span style="font-family:{BODY};"><strong>Western Cape:</strong><br>Canal Walk - 021 555 4683<br>Cavendish Square - 021 001 0685<br>Table Bay Mall - 021 065 2336<br>Tygervalley - 021 914 0909<br>V&amp;A - 087 148 4082<br>Somerset - 021 851 1946</span></span></td>\n'
        f'                            <td style="line-height:9px; text-align:left; width:33%; vertical-align:top;"><span style="font-size:9px;"><span style="font-family:{BODY};"><strong>KwaZulu-Natal:</strong><br>Ballito - 032 001 0388<br>Gateway - 031 566 6783<br>Pavilion - 031 001 0424</span></span></td>\n'
        '                        </tr>\n'
        '                    </tbody>\n'
        '                </table>\n'
        '            </td>\n'
        '        </tr>\n'
        '        <tr><td style="text-align:left;"><br><br>&nbsp;&nbsp;</td></tr>\n'
        '    </tbody>\n'
        '</table>'
    )

    content = (
        '<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#FEDAA8; width:600px;" width="600">\n'
        '    <tbody>\n'
        f'        <tr><td style="text-align:center; font-size:0; line-height:0;">{linked_image("KV_Hero.png", kv_source, "When moments become memories", catalogue_link, 600)}</td></tr>\n'
        '    </tbody>\n'
        '</table>\n'
        '<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FEDAA8;" width="600">\n'
        '    <tbody>\n'
        '        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center; font-size:0; line-height:0;">{image_tag("Flower.png", flower_source, "Flower")}</td></tr>\n'
        '        <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center; padding:0 50px;"><span style="font-size:42px; line-height:48px;"><strong><span style="font-family:{SHARP}; color:#000000;">Perfect gifts at the<br>perfect price</span></strong></span></td></tr>\n'
        '        <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center; padding:0 80px;"><span style="font-size:22px; line-height:30px;"><span style="font-family:{BODY}; color:#000000;">Discover Galaxy gifts mom will love<br>for every budget</span></span></td></tr>\n'
        '        <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center;">{columns_html}</td></tr>\n'
        '        <tr><td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        f'        <tr><td style="text-align:center;"><span style="font-size:14px; line-height:20px;"><span style="font-family:{BODY}; color:#555555;">Valid until 31 May 2026</span></span></td></tr>\n'
        '        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        '        <tr>\n'
        '            <td style="text-align:center;">\n'
        '                <table align="center" border="0" cellpadding="0" cellspacing="0" width="470">\n'
        '                    <tbody>\n'
        '                        <tr>\n'
        f'                            <td align="center" valign="top" width="220">{linked_image("Button_Catalogue_Here.png", button_catalogue_source, "Catalogue here", catalogue_link)}</td>\n'
        '                            <td width="30"></td>\n'
        f'                            <td align="center" valign="top" width="220">{linked_image("Button_Visit_Nearest_Store.png", button_store_source, "Visit your nearest store", store_link)}</td>\n'
        '                        </tr>\n'
        '                    </tbody>\n'
        '                </table>\n'
        '            </td>\n'
        '        </tr>\n'
        '        <tr><td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>\n'
        '    </tbody>\n'
        '</table>\n'
        f'{store_list_section}'
    )

    footer = load_brandstore_footer()
    html_content = document_shell("Samsung South Africa", "When moments become memories", content, footer)
    image_map = {
        kv_source: "KV_Hero.png",
        flower_source: "Flower.png",
        ultra_source: "Product_S26_Ultra.png",
        plus_source: "Product_S26_Plus.png",
        s26_source: "Product_S26.png",
        badge_1tb_source: "Badge_1TB.png",
        badge_512_source: "Badge_512GB.png",
        badge_256_source: "Badge_256GB.png",
        button_catalogue_source: "Button_Catalogue_Here.png",
        button_store_source: "Button_Visit_Nearest_Store.png",
    }
    return html_content, image_map


def build_ai_week_mailer(country_code: str, language: str) -> tuple[str, dict[Path, str]]:
    base_folder = JOB_AI / "ZAS26113053_images export" / "products" / "work around the products"
    slice_folder = base_folder / ("eng" if language == "en" else "French") / "images"
    slice_sources = [
        slice_folder / "ZAS26113053_2026_SEWA-Retainer_MX-Samsung-AI-Week_W21_01.png",
        slice_folder / "ZAS26113053_2026_SEWA-Retainer_MX-Samsung-AI-Week_W21_02.png",
        slice_folder / "ZAS26113053_2026_SEWA-Retainer_MX-Samsung-AI-Week_W21_03.png",
        slice_folder / "ZAS26113053_2026_SEWA-Retainer_MX-Samsung-AI-Week_W21_04.png",
        slice_folder / "ZAS26113053_2026_SEWA-Retainer_MX-Samsung-AI-Week_W21_05.png",
        slice_folder / "ZAS26113053_2026_SEWA-Retainer_MX-Samsung-AI-Week_W21_06.png",
    ]

    if language == "en":
        hero_link = "https://www.samsung.com/africa_en/smartphones/galaxy-s26-ultra/"
        s26_link = "https://www.samsung.com/africa_en/smartphones/galaxy-s26-ultra/"
        buds_link = "https://www.samsung.com/africa_en/audio-sound/galaxy-buds/galaxy-buds4-pro-white-sm-r640nzwamea/"
        watch_link = "https://www.samsung.com/africa_en/watches/galaxy-watch/galaxy-watch8-44mm-silver-bluetooth-sm-l330nzsamea/"
        a57_link = "https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/"
        health_link = "https://www.samsung.com/africa_en/apps/samsung-health/"
        preheader = "Shop AI Week and turn goals into routines"
        footer_code = country_code.lower() if country_code != "CIV" else "ci"
    else:
        hero_link = "https://www.samsung.com/africa_fr/smartphones/galaxy-s26-ultra/"
        s26_link = "https://www.samsung.com/africa_fr/smartphones/galaxy-s26-ultra/"
        buds_link = "https://www.samsung.com/africa_fr/audio-sound/galaxy-buds/galaxy-buds4-pro-white-sm-r640nzwamea/"
        watch_link = "https://www.samsung.com/africa_fr/watches/galaxy-watch/galaxy-watch8-44mm-silver-bluetooth-sm-l330nzsamea/"
        a57_link = "https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/"
        health_link = "https://www.samsung.com/africa_fr/apps/samsung-health/"
        preheader = "Profitez de la Semaine de l'IA Samsung et transformez vos objectifs en habitudes durables"
        footer_code = "sn" if country_code == "SN" else "ci"

    content = (
        '<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">\n'
        '    <tbody>\n'
        f'        <tr><td style="text-align:center; font-size:0; line-height:0;">{linked_image("AI_Week_01.png", slice_sources[0], "AI Week hero", hero_link, 600)}</td></tr>\n'
        '        <tr>\n'
        '            <td style="text-align:center; font-size:0; line-height:0;">\n'
        '                <table align="center" border="0" cellpadding="0" cellspacing="0" width="600">\n'
        '                    <tbody>\n'
        '                        <tr>\n'
        f'                            <td width="300" style="font-size:0; line-height:0;">{linked_image("AI_Week_02.png", slice_sources[1], "Galaxy S26 Ultra", s26_link, 300)}</td>\n'
        f'                            <td width="300" style="font-size:0; line-height:0;">{linked_image("AI_Week_03.png", slice_sources[2], "Galaxy Buds4 Pro", buds_link, 300)}</td>\n'
        '                        </tr>\n'
        '                        <tr>\n'
        f'                            <td width="300" style="font-size:0; line-height:0;">{linked_image("AI_Week_04.png", slice_sources[3], "Galaxy Watch8", watch_link, 300)}</td>\n'
        f'                            <td width="300" style="font-size:0; line-height:0;">{linked_image("AI_Week_05.png", slice_sources[4], "Galaxy A57 5G", a57_link, 300)}</td>\n'
        '                        </tr>\n'
        f'                        <tr><td colspan="2" style="font-size:0; line-height:0;">{linked_image("AI_Week_06.png", slice_sources[5], "Samsung Health", health_link, 600)}</td></tr>\n'
        '                    </tbody>\n'
        '                </table>\n'
        '            </td>\n'
        '        </tr>\n'
        '    </tbody>\n'
        '</table>'
    )

    footer = load_footer(footer_code)
    html_content = document_shell(COUNTRY_TITLES[country_code], preheader, content, footer)
    image_map = {source: f"AI_Week_{index:02d}.png" for index, source in enumerate(slice_sources, start=1)}
    return html_content, image_map


def generate() -> None:
    chest_hero = JOB_NG / "ZAS26111017_images" / "Group 2684.png"
    chest_button = JOB_NG / "ZAS26111017_images" / "Group 2683.png"
    crystal_hero = JOB_NG / "ZAS26111017_images" / "Group 2685.png"
    crystal_button = JOB_NG / "ZAS26111017_images" / "Group 2686.png"

    chest_html, chest_images = build_ng_mailer(
        hero_name="Hero_Chest_Freezer.png",
        hero_source=chest_hero,
        hero_alt="Samsung Chest Freezer",
        button_name="Button_Learn_More.png",
        button_source=chest_button,
        button_alt="Learn more",
        link="https://www.samsung.com/africa_en/refrigerators/one-door/ri70fm51-198l-dark-gray-ri70f20v2gaut/",
        preheader="Heavy on energy efficiency, light on your bills",
        heading_html="Enjoy greater energy efficiency and<br>less load on your pockets.",
        body_html="The Digital Inverter Compressor automatically<br>adjusts its speed in response to cooling demand<br>giving you better energy consumption.",
    )
    flatten_output(JOB_NG, "NG_ZAS26111017_CE_Chest_Freezer_W20", chest_html, chest_images)

    crystal_html, crystal_images = build_ng_mailer(
        hero_name="Hero_Crystal_UHD.png",
        hero_source=crystal_hero,
        hero_alt="Samsung Crystal UHD",
        button_name="Button_Learn_More.png",
        button_source=crystal_button,
        button_alt="Learn more",
        link="https://www.samsung.com/africa_en/tvs/crystal-uhd-tv/",
        preheader="More screen, less bezel",
        heading_html="Our Crystal UHD TV's sleek and<br>elegant design draws you into<br>the pure picture.",
        body_html="Crafted with minimalism in mind and a<br>boundless design, your screen looks stunning<br>from every angle.",
    )
    flatten_output(JOB_NG, "NG_ZAS26111017_CE_Crystal_UHD_W20", crystal_html, crystal_images)

    sa_html, sa_images = build_brandstore_mailer()
    flatten_output(JOB_SA, "SA_ZAS26088143_Brandstores_Mothers_Day_W20", sa_html, sa_images)

    for country_code in ("GH", "NG", "KE", "TZ"):
        ai_html, ai_images = build_ai_week_mailer(country_code, "en")
        flatten_output(JOB_AI, f"{country_code}_ZAS26113053_Samsung_AI_Week_W21", ai_html, ai_images)

    for country_code in ("SN", "CIV"):
        ai_html, ai_images = build_ai_week_mailer(country_code, "fr")
        flatten_output(JOB_AI, f"{country_code}_ZAS26113053_Samsung_AI_Week_W21", ai_html, ai_images)


if __name__ == "__main__":
    generate()