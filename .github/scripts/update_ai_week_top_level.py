from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(r"c:\Users\user\OneDrive\digidanWork\Mailers")
PUBLISHED = ROOT / r"2026\TODO ZAS26113053 _ ROA _ MX Samsung AI Week _ W21\Published"

GH_MASTER = PUBLISHED / "GH_ZAS26113053_Samsung_AI_Week_W21.html"
CIV_MASTER = PUBLISHED / "CIV_ZAS26113053_Samsung_AI_Week_W21.html"

FOOTERS = {
    "NG": ROOT / "footers" / "footer_ng.txt",
    "KE": ROOT / "footers" / "footer_ke.txt",
    "TZ": ROOT / "footers" / "footer_tz.txt",
    "SN": ROOT / "footers" / "footer_sn.txt",
}

UNSUBSCRIBE_URL = "https://samsung-mena-mkt-prod6-m.adobe-campaign.com/webApp/smgUnsub?id=<%= escapeUrl(recipient.cryptedId) %>&lang=en&unsub=true"

TARGETS = {
    "NG": {
        "master": GH_MASTER,
        "title": "Samsung Nigeria",
        "target": PUBLISHED / "NG_ZAS26113053_Samsung_AI_Week_W21.html",
    },
    "KE": {
        "master": GH_MASTER,
        "title": "Samsung Kenya",
        "target": PUBLISHED / "KE_ZAS26113053_Samsung_AI_Week_W21.html",
    },
    "TZ": {
        "master": GH_MASTER,
        "title": "Samsung Tanzania",
        "target": PUBLISHED / "TZ_ZAS26113053_Samsung_AI_Week_W21.html",
    },
    "SN": {
        "master": CIV_MASTER,
        "title": "Samsung Senegal",
        "target": PUBLISHED / "SN_ZAS26113053_Samsung_AI_Week_W21.html",
    },
}


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.write_text(content, encoding="utf-8", newline="\n")


def sanitize_footer(content: str) -> str:
    content = content.replace("\r\n", "\n")
    content = re.sub(
        r'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^\"]*"',
        f'href="{UNSUBSCRIBE_URL}"',
        content,
    )
    content = content.replace("©", "&copy;")
    return content


def swap_title(content: str, title: str) -> str:
    return re.sub(r"<title>.*?</title>", f"<title>{title}</title>", content, count=1, flags=re.S)


def swap_footer(content: str, footer: str) -> str:
    marker = '<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color: #ffffff;" width="600">'
    start = content.rfind(marker)
    if start == -1:
        raise ValueError("Footer marker not found")
    return content[:start] + footer


def main() -> None:
    for code, config in TARGETS.items():
        master_html = read_text(config["master"])
        footer_html = sanitize_footer(read_text(FOOTERS[code]))
        updated_html = swap_footer(swap_title(master_html, config["title"]), footer_html)
        if "MirrorPageUrl" not in updated_html:
            raise ValueError(f"Missing MirrorPage markup in {code}")
        if UNSUBSCRIBE_URL not in updated_html:
            raise ValueError(f"Missing live unsubscribe URL in {code}")
        if "YYYYY" in updated_html or "ZZZZZ" in updated_html:
            raise ValueError(f"Old placeholders still present in {code}")
        write_text(config["target"], updated_html)


if __name__ == "__main__":
    main()