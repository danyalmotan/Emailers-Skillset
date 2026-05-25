---
name: samsung-mailer
description: Convert Samsung Africa email design JPGs into production-ready HTML email code for South Africa and multiple African regions. Use this skill whenever Danny mentions a Samsung mailer job, wants to convert a JPG design to HTML, is working on a Samsung email, receives files from Samsung, or mentions anything about mailers, email designs, HTML emails, or CRM emails from Samsung. Trigger any time Samsung + mailer/email work is mentioned together, even casually (e.g. "got a new job in", "Samsung sent me", "can you do this one", "new mailer arrived").
---

# Samsung Africa — HTML Mailer Skill

You are converting Samsung email design files (JPG mockups + cut-up image assets) into production-ready HTML email code for South Africa and multiple African regions.

## What you'll be given

- **1–2 JPG/PNG files**: The full email design as a flat image (this is your source of truth for layout, text, colours, and structure)
- **A folder of cut-up images** (optional but common): Subfolders named by section, each containing the sliced image assets
- **A links file** (optional): A .docx or .txt file listing per-section, per-region URLs (see Links File section below)
- **Specific link instructions** in the prompt (e.g. "use this URL for all CTAs")

### 1200px (2×) source JPGs

Some design files are supplied at **1200px wide** instead of the standard 600px. This is preferred by Danny because the larger file makes text easier to read and extract accurately.

- The email still renders at **600px wide** — always
- All image display dimensions you read from the JPG must be **halved** (e.g. a banner that measures 1068px in the file displays at 534px)
- Cut-up images supplied alongside a 1200px JPG may have both 1x and @2x versions — **always use the 1x version** (same rule as all images: file size matters)

## Regions, Codes & Languages

| Region | Code | Language | Link Domain |
|--------|------|----------|-------------|
| South Africa | SA / SSA | English | https://www.samsung.com/za/ |
| Nigeria | NG | English | https://www.samsung.com/africa_en/ |
| Kenya | KE | English | https://www.samsung.com/africa_en/ |
| Tanzania | TZ | English | https://www.samsung.com/africa_en/ |
| Ghana | GH | English | https://www.samsung.com/africa_en/ |
| Mauritius | MU | English | https://www.samsung.com/africa_en/ |
| Senegal | SN | French | https://www.samsung.com/africa_fr/ |
| Côte d'Ivoire | CI / CIV | French | https://www.samsung.com/africa_fr/ |

**Detecting the region from the filename:** The region code appears in the filename (e.g. `ZAS26088065_Miracle_Launch2_NG.html` = Nigeria, `ZAS26088065_Miracle_Launch2_SA.html` = South Africa, `ZAS26088065_Miracle_Launch2_CIV.html` = Côte d'Ivoire).

**French regions (SN, CI/CIV):** All body text, headlines, CTA button alt text, and any text-based content must be in French. Image-based text remains as-is.

---

## Footer Files

Danny maintains pre-built footer HTML files for each region. Always read and use these — do NOT construct footers from scratch.

**White background footer:** `Mailers/footers/footer_[code].txt`
**Dark background footer:** `Mailers/footers_black/footer_[code].html`

Where `[code]` = the region code in lowercase (e.g. `footer_ssa.txt` for South Africa, `footer_ng.txt`, `footer_ci.txt`).

**Important:** South Africa uses the code `ssa` in footer filenames — there is no `footer_sa.txt`. Always use `footer_ssa.txt` for SA mailers.

**When to use which:** Read the JPG design. If the footer section has a white/light background, use the `footers/` version. If it has a dark/black background, use the `footers_black/` version.

**Always read the footer file** before writing any HTML. Copy it in exactly. Do not reconstruct social icon links, legal links, or T&C text from memory — these differ per region.

**Critical:** The footer files contain the real Adobe Campaign unsubscribe URL (e.g. `https://samsung-mena-mkt-prod6-m.adobe-campaign.com/webApp/smgUnsub?id=<%= escapeUrl(...) %>...`). When copying the footer into generated HTML, **always replace that href value with `YYYYY`**. The rule is: generated HTML must never contain real Adobe Campaign syntax — YYYYY and ZZZZZ only.

---

## Links File

When Danny provides a links file (usually a `.docx`), read it to get per-section, per-region URLs. The format is:

```
[Section name / description]
[REGION CODE] : [URL]
[REGION CODE] : [URL]
```

Match section names to CTAs by the section headline. Use the exact URL for each region's CTA buttons.

If no links file is provided but Danny gives a single URL instruction (e.g. "use this URL for all buttons"), apply it to every CTA in that region's email.

**If no link is specified for a section**, use the region's default product URL (see Regions table above).

---

## Regional Variants — How They Work

Most Samsung mailers are created in SA first, then adapted for other regions. The regional versions share most content but differ in:

### Always different per region:
- **`<title>` tag**: `<title>Samsung [Country]</title>` (e.g. "Samsung Nigeria", "Samsung South Africa")
- **All links/URLs**: Use the region-specific domain and UTM-tracked URLs from the links file
- **Footer**: Read and insert the region-specific footer file
- **Offer/promotion sections**: Each region has its own local offer — this is the most significant structural difference. Read the JPG carefully for this section.

### Usually the same across regions:
- Hero/KV image and animated GIF
- Main product headline and body copy (EN regions share English copy; FR regions get French translation)
- Product feature sections
- Accessories and store locator sections (with updated links)
- Image assets (same CDN images, different destination URLs)

### Workflow for creating a regional variant:
1. Start from the SA HTML structure
2. Change `<title>Samsung South Africa</title>` → `<title>Samsung [Country]</title>`
3. Swap all links to region-specific URLs
4. Identify which sections differ (read the region's JPG side-by-side with the SA JPG)
5. Replace or update those sections (typically the offer/promotion block)
6. Swap the footer with the region-specific footer file
7. For French regions: translate all text content to French

---

## Component Library — Always Use This First

Before writing any HTML from scratch, check the component library at:
```
c:\Users\user\OneDrive\digidanWork\Mailers\.github\skills\samsung-mailer\components\
```

Read `INDEX.md` first to identify which components apply to the sections in the current mailer. Then read the relevant component file(s) and use that HTML as the basis — only adapt the variable parts (colours, image filenames, URLs, text content). This ensures every email inherits battle-tested, production-proven code.

**Component files available:**

| File | What it contains |
|------|-----------------|
| `kv-hero.html` | KV/hero opening section variants |
| `pricing-block-120px.html` | 120px block for 4-across CE layouts (Now/Save) |
| `pricing-block-180px.html` | 180px block for carrier/brandstore layouts |
| `pricing-row-wrapper.html` | #EDEAE3 outer wrapper for a row of pricing blocks |
| `section-header-colored.html` | Coloured section heading table (multiple colour variants) |
| `banner-534px.html` | Centred 534px banner in 600px container |
| `banner-600px.html` | Full-width 600px banner row |
| `cta-button-single.html` | Single centred CTA button row |
| `cta-button-pair.html` | Two CTA buttons side by side |
| `feature-icons-3col.html` | Icon + label feature grid |
| `three-pod-carrier.html` | Three phones + pricing cards (carrier layout) |
| `sliced-border-frame.html` | Decorative frame with sliced image strips |
| `key-features-label.html` | "Key features at a glance:" text row |
| `spacer-row.html` | Spacer rows (10/20/30px) |

**If a new pattern is used that isn't in the library** — build it, then add it to the library as a new component file and update INDEX.md. The library grows over time.

---

## Your job

1. **Read the JPG(s) carefully** — before writing a single line of HTML, do a thorough analysis pass:
   - Extract all text exactly as written
   - **Identify every colour precisely** (see Colour Extraction section below)
   - **Count and identify every distinct section** — look for visible gaps, spacing, or colour shifts between blocks
   - Note CTA button text and any visible link URLs
2. **List the cut-up image files** from the provided folder (if given), noting which section each belongs to based on the subfolder name
3. **Build the HTML** using the template patterns below
4. **Create the output folder, save HTML + images, verify quality**

---

## Colour Extraction — Read the JPG Precisely

Colour accuracy is critical. Wrong colours are immediately obvious when the email renders. Before writing any HTML, identify these three colours from the JPG:

### 1. Body / page background colour
This is the colour set on the `<body>` element — it shows in the email client in the space **outside and around** the 600px email container (the left/right margins when viewed in a wide window or browser). **This colour is always different from the 600px container/section background.** It is consistently a **dark grey `#555555`** in Samsung SA mailers. Do NOT sample from inside the 600px design area — default to `#555555` unless the JPG canvas clearly shows a different outer background colour.

**Important:** The body background and the section outer wrapper background are two separate colours serving different purposes. Never use the same value for both.

### 2. Email outer background / section gap colour
Many Samsung SA mailers have a coloured background *behind* the content cards — the colour that shows in the gaps **between** sections and as the left/right padding around the inner card within the 600px container. This is set on the outer wrapper `<table>` for each section. It is often a muted purple-blue or lavender (e.g. `#797DAC`), not always dark.

### 3. Content card / text block background colour
Each individual content card (the block containing headline + body text + CTA) often has its own background colour — frequently a lighter tint of the outer background (e.g. `#CECFE1`), not white. Do NOT default to `#ffffff` unless the card is genuinely white in the design.

**Rule:** If a section looks white, check carefully — it may be a very light lavender or tinted colour. Only use `#ffffff` if you are certain it is pure white.

**Common Samsung SA colour pattern** (varies per campaign — always read from the JPG):
- Body background: dark grey, typically `#555555` — shows outside the 600px email, NOT the same as the section wrapper colour
- Section gap / outer wrapper: saturated purple-blue or campaign colour (e.g. `#797DAC`) — shows between and around content cards inside the 600px container
- Content card background: lighter tint of the same hue (e.g. `#CECFE1`)
- Footer: always `#ffffff`

---

## Section Identification — Counting and Separating Blocks

Each distinct visual block in the JPG must become its own separate `<table>` in the HTML. This is what creates the visible gap / spacing between sections when the email renders.

**How to identify section breaks:**
- Look for **visible space or a gap** between content blocks — this is the outer background colour showing through
- Look for **colour shifts** — a change in the card's background colour signals a new section
- Look for **horizontal rules or dividers** — explicit lines between sections
- Each section that has its own rounded-corner card treatment is its own `<table>`

**Do NOT merge sections into one continuous table** — unless they share the same background AND flow together without a visible gap between them. In many Samsung SA mailers, the first `mailcont` table (the KV + headline text + offer section) groups these visually-connected opening blocks into a single table. Sections below that break into separate tables.

**Exception — first mailcont table:** The KV hero image, main headline copy, and the first promotion/offer section often sit together inside the opening `<table class="mailcont" id="emailContainer">`. The promotional card within that table uses the sliced-border technique (see below). Sections after this open block each get their own `<table>`.

The rule is: if there is a **visible gap or background change** between sections, they are separate tables. If blocks flow continuously with the same background, they can be in the same table.

**Creating the gap between sections:**
The gap is created by the outer background colour showing between the section `<table>` elements. Add a spacer row *inside* the outer wrapper between sections, or simply let the separate tables sit below each other with the body/wrapper background showing through:

```html
<!-- End of Section 1 table -->
</table>

<!-- Gap shows the outer background colour here -->

<!-- Start of Section 2 table -->
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background:[OUTER_BG];" width="600">
    <tbody>
        <tr>
            <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
        <tr>
            <td style="text-align: center;">
                <!-- content card with its own background colour -->
            </td>
        </tr>
        <tr>
            <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
    </tbody>
</table>
```

---

## The Samsung SA HTML Email Template

All Samsung SA mailers share this fixed structure. The boilerplate at top and bottom is always identical. Only the content sections in the middle change.

### Samsung Logo Header — When No Full KV Image Is Provided

Sometimes the design team only supplies the main content image (e.g. an envelope, product shot) **without** a combined KV that includes the Samsung logo and headline text. In these cases:

1. **Always add the Samsung logo header block** at the very top of the email (above the KV image), using this exact HTML — it works regardless of the logo colour or background colour in the design:

```html
<table border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; width:600px;" width="600">
    <tbody>
        <tr>
            <td><a href="https://www.samsung.com/za/" target="_blank"><img alt="samsung logo" height="126" src="https://cdn19.mailercdn.net/users/assets/379/images/esrdgthjyukhhg-0001.jpg" style="display: block; width: 600px; height: 126px;" width="600"></a></td>
        </tr>
    </tbody>
</table>
```

2. **Add the KV headline text as HTML** in the section immediately below the logo header (before the main content image). Read the headline and body copy from the JPG design and build it as HTML text using the standard Samsung font stacks.

3. **Do NOT try to reconstruct a logo from scratch or use a different image.** Always use `esrdgthjyukhhg-0001.jpg` from the CDN — it's the correct Samsung wordmark at the right proportions.

---

### Fixed: DOCTYPE + Head

```html
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>Samsung South Africa</title>
    </head>
```

### Fixed: Body open + Preheader + View Online

Replace `[PREHEADER TEXT]` with the email preview text (usually the main headline or a short summary — read it from the JPG or the email subject line if visible).

**Body background colour:** Use `#555555` (dark grey). The body bg is the colour outside the 600px email container — it is consistently a dark grey in Samsung SA mailers, regardless of the campaign colours inside the email. Do NOT default to `#dddddd`.

**ZZZZZ / YYYYY placeholders — ALWAYS use these. Never use the actual Adobe Campaign syntax.** The HTML goes through two systems: Everlytic first (where Danny edits and tests), then Samsung's GCDM system (Adobe Campaign). Everlytic would mangle the Adobe Campaign dynamic tags if they were included directly. Danny does a manual find/replace before sending to Samsung:
- `ZZZZZ` — placeholder for the entire View Online link block (in the header)
- `YYYYY` — placeholder for the unsubscribe URL href value only (in the footer)

Even if you see the actual Adobe Campaign syntax in a reference file, **always output ZZZZZ and YYYYY** in your generated HTML. No exceptions.

```html
    <body style="background-color:#555;"><!-- Preheader START =========================================================================== --><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> [PREHEADER TEXT] </span> <!-- Preheader END =========================================================================== -->
        <table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">
            <tbody>
                <tr>
                    <td align="center" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <!--olhide start-->
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"><br>
                                        <span style="color:#000000;">ZZZZZ</span><br>
                                        &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                    <!--olhide end-->
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"></td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>
```

### Variable: Content Sections

Content goes inside a series of 600px-wide tables. Each visual "block" in the design becomes its own `<table>`. The container background colour matches that section's background in the design.

**Section table wrapper pattern:**
```html
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:[SECTION_BG]; width:600px;" width="600">
                            <tbody>
                                <!-- rows go here -->
                            </tbody>
                        </table>
```

Or for sections without the mailcont id (secondary sections):
```html
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background:[SECTION_BG];" width="600">
                            <tbody>
                                <!-- rows go here -->
                            </tbody>
                        </table>
```

---

## Fonts

All Samsung SA mailers use exactly these two font stacks — never deviate:

**Headings / Bold text:**
```
Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif
```

**Body / supporting text:**
```
avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif
```

**Font size source of truth:** the **design image always wins**. Do not treat a previous mailer, a component example, or one default body size as correct unless it visually matches the current design.

**Common starting points** — use these only as a guide while matching the design, not as fixed rules:
- Large headlines: **28px, 36px, 40px, or 48px bold**
- Body copy / supporting text: **16px, 18px, 20px, 22px, or 24px**
- Small caption / icon labels: 10–12px
- Footer text: 13px

**Critical:** do not hardcode a single body copy size across the whole mailer. Different emailers use different sizes, and different sections within the **same** emailer may also use different body sizes.

**What to do in practice:**
- Judge headline size and body size **independently**. It is common to get the headline right and the copy wrong.
- Read each text block from the design image, then choose the HTML font size that makes the rendered result look **visually closest** to that block.
- For body copy, compare against nearby likely values first: **16 / 18 / 20 / 22 / 24px**.
- For headings, compare against nearby likely values first: **28 / 36 / 40 / 48px**.
- If a section feels too dense or too airy compared with the design, adjust the **font size first**, then re-check the line breaks.
- Do not assume one section's body size applies to the next section.

**1200px source JPG rule for typography:** if the design file is supplied at **1200px wide**, the email still renders at **600px**. Judge the type at the email's rendered scale — effectively **50% of the source image**. Do not choose HTML font sizes based on the raw 1200px screenshot dimensions.

**Goal:** the final HTML should look as close as possible to the type size in the design image, even when that means using a less common value for that specific section.

**Font style pattern for headings:**
```html
<span style="font-size:48px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[HEADLINE TEXT]</span></strong></span>
```

**Font style pattern for body:**
```html
<span style="font-size:16px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">[BODY TEXT]</span></span></span>
```

---

## Spacing Fidelity — Match the Design

**Always reproduce the spacing you see in the JPG.** A common mistake is compressing elements together with minimal padding, making the email look cluttered compared to the airy, well-spaced Samsung design.

**Rules:**
- Before each major element (icon + heading, body copy block, CTA button), add a spacer row of appropriate height — typically 20–30px between elements within a section
- After the last element inside a card (before the card bottom edge), add bottom padding of at least 20–25px
- The gap between a heading and its body copy should be visible — use a `<br>` or a spacer row of ~10px
- The gap between body copy and a CTA button should be generous — typically 20–30px
- Between major sections (separate `<table>` blocks), the outer background showing through creates the gap — ensure each section table has top/bottom spacer rows inside it (typically `height="20"` or `height="30"`)
- When in doubt, add more space rather than less — Samsung designs are deliberately open and uncluttered

**Spacing pattern inside a content section:**
```html
<!-- Top breathing room -->
<tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
<!-- Content element -->
<tr><td>...</td></tr>
<!-- Gap between elements -->
<tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
<!-- Next content element -->
<tr><td>...</td></tr>
<!-- Bottom breathing room -->
<tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
```

---

## Text Line Breaks — Match the Design Exactly

**Reproduce line breaks as they appear in the JPG.** When body copy in the design wraps at a specific word, use `<br>` tags in the HTML to force the same break. Do NOT let the text reflow freely — email clients render at a fixed 600px width, so you can control exactly where lines break.

**Example:**

Design shows:
```
Carry your essentials in a single app -
from credentials like credit cards
to on-the-go items like car keys.
```

Correct HTML:
```html
Carry your essentials in a single app -<br>
from credentials like credit cards<br>
to on-the-go items like car keys.
```

Wrong (do not let text reflow freely):
```html
Carry your essentials in a single app - from credentials like credit cards to on-the-go items like car keys.
```

**Why this matters:** Free-flowing text will reflow differently depending on font rendering and client, producing a line break in a different place from the design. `<br>` tags lock it in.

**Apply this to all multi-line text blocks** — headlines, body copy, disclaimers, bullet points.

### Bold text in body copy — pick it up from the design

**When words or phrases in body copy appear heavier/bolder than the surrounding text, wrap them in `<strong>` tags.** Do NOT make entire sentences bold — only the specific words that are visually heavier in the design.

Common patterns in Samsung AI mailers:
- **Feature names** in tip sections (e.g. **Photo Assist**, **Gemini Live**, **Call Assist**, **Writing Assist**, **Browsing Assist**)
- **Product names** in offer sections (e.g. **Galaxy Buds**, **Watch**, **Tablet**)
- **Promo codes and discount amounts** (e.g. **PPX10**, **10%**, **30%**)
- Key terms the design has set in bold weight

Example — design shows "**Photo Assist** helps you get quick and easy photo editing with just a few words and AI." with "Photo Assist" visually heavier:
```html
<strong>Photo Assist</strong> helps you get<br>
quick and easy photo editing<br>
with just a few words and AI.
```

**Note:** Apply `<strong>` even when it's inside the body font stack (not the Samsung Sharp Sans heading stack). Bold emphasis in body copy always uses `<strong>`.

---

## Shared Images & Variants

Some image files are shared across multiple regions, and some mailers have variant versions. Handle these cases:

### Shared images with multiple region codes in filename
If a file is named `ZAS######_Miracle_Launch2_KE-TZ.png` (shared by Kenya and Tanzania):
- Create separate files for each region: `ZAS######_Miracle_Launch2_KE.png` and `ZAS######_Miracle_Launch2_TZ.png`
- Copy the same image to both filenames
- Use the region-specific filename in each region's HTML

### Variant files
Some mailers have variants (e.g. `ZAS######_Miracle_Launch2_SA` vs `ZAS######_Miracle_Launch2_NonHR_SA`):
- These are usually almost identical except for specific sections (pods, deal sections, etc.)
- Read both JPGs carefully to identify which sections differ
- Use the correct variant file for each region per Danny's instructions

---

## Images & Output Folder Structure

When Danny works in Everlytic's WYSIWYG editor, he uploads images there and they get hosted on the CDN. But when **you** generate an HTML file, the workflow is different — you create a self-contained folder that Danny can zip and import directly into Everlytic.

### Output folder structure

The HTML file lives in the **same folder as the job's design PNG/JPG**. All cut-up images used in the HTML must be copied **flat** (no subfolders) into **that same folder**. Danny can then zip the folder and import it into Everlytic — the zip contains only the images that are actually needed.

**You must create that zip file yourself once the folder is complete.** Do not leave zipping as a manual follow-up step.

**Zip naming rule:** the zip filename must match the HTML filename exactly, but without the `.html` extension.

Example:
- Folder: `ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 1/`
- HTML: `ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 1.html`
- ZIP: `ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 1.zip`

**Zip contents rule:** zip the **files inside the folder** (HTML + images), not the outer folder wrapper itself.

**Important zip rules:**
- Exclude any existing `.zip` file when building or rebuilding the archive
- Save the finished `.zip` file inside that same completed output folder
- If a `published/` folder contains multiple mailer folders, create **one zip per mailer folder**

### Use A Server Reference Table File

Use this workflow when one job contains **many mailers that reuse many of the same images** and Danny does **not** want to upload every mailer zip to Everlytic just to get CDN image URLs.

This is an **additional packaging step** on top of the normal mailer folders and per-folder zip files. You still build every mailer folder normally first.

#### When to use it

Use it when:
- There are multiple mailers in one `published/` batch
- Many of those mailers reuse the same hero, button, pod, or section images
- Uploading each mailer zip separately would create unnecessary duplication on the Everlytic server

#### Required workflow

1. Build **every mailer folder normally**:
    - one folder per mailer
    - one HTML file inside that folder
    - only the images actually used by that HTML
    - one matching zip per mailer folder
2. Then create an additional folder inside `published/` called:
    - `ALL_IMAGES/`
3. Copy **one deduplicated copy** of every unique image used across the newly-created mailer folders into `ALL_IMAGES/`
4. Create **one HTML file** inside `ALL_IMAGES/` called:
    - `server.html`
5. `server.html` must contain **one table** with these 3 columns:
    - Column 1: sequential number starting from `1`
    - Column 2: the uploaded image preview from `ALL_IMAGES/` and its upload filename
    - Column 3: the original local filename(s) used inside the generated mailer HTML files
6. Danny uploads only the `ALL_IMAGES/` bundle to Everlytic
7. After Everlytic rewrites the image `src` values to CDN URLs in `server.html`, use that table as the source of truth to replace the local `src` values in every generated mailer HTML

#### Critical rules

- Deduplicate by **image content**, not just by filename
- If two different source images share the same basename, give the copied file in `ALL_IMAGES/` a unique sanitized upload filename and keep the original local filename in the table mapping
- Keep `ALL_IMAGES/` limited to the **current batch only** - do not mix in legacy files from older published jobs
- Do **not** replace permanent footer social icon CDN URLs - only replace local image `src` values that belong to the generated mailer folders
- Prefer **unique sanitized local filenames** inside the generated mailers when different assets would otherwise collide under the same basename
- `server.html` should preserve a machine-readable mapping when practical, for example a row-level attribute like `data-originals="file_a.png | file_b.png"`

#### Practical goal

This lets Danny upload **one shared image bundle** to Everlytic, get the CDN URLs once from `server.html`, then update all generated mailers from that reference table instead of importing each mailer package one by one.

```
ZAS26088076  [job name]/
├── ZAS26088076  [job name].png    ← original design file
├── ZAS26088076  [job name].html   ← HTML output (named same as PNG, .html extension)
├── Group_2619.png                 ← cut-up images copied flat here, filenames sanitized
├── Group_2620_2x.png
├── Image_558_2x.png
└── ...
```

**Critical rules:**
- **HTML file name** must match the design PNG/JPG filename exactly, just changing the extension to `.html`
- **Copy only the images that are actually referenced in the HTML** from the cut-up subfolders into the same folder. Do NOT copy unused images.
- If cut-ups are in subfolders (e.g. `ZAS######_images/Icon1/Group 2623@2x.png`), copy them flat — no subfolder prefix in the destination.

### Filename sanitization (MANDATORY)

**Everlytic rejects filenames containing special characters like `@`, parentheses, and spaces.** When copying cut-up images to the output folder, you **must** sanitize every filename:

1. **Remove all special characters** — strip `@`, `(`, `)`, `#`, `%`, `&`, `+`, `=`, `!`, `'`, `"`, `` ` ``, `{`, `}`, `[`, `]`, `,`, `;` and any other non-alphanumeric characters except `-`, `_`, and `.`
2. **Replace all spaces with underscores** `_`
3. **Keep the file extension** (`.png`, `.jpg`) unchanged
4. **Use the sanitized filename in the HTML `src` attribute** — the HTML must reference the new clean filename, not the original

**Examples:**
| Original filename | Sanitized filename |
|---|---|
| `Group 2620@2x.png` | `Group_2620_2x.png` |
| `Screenshot 2026-04-10 at 11.26.30@2x.png` | `Screenshot_2026-04-10_at_11.26.30_2x.png` |
| `Image 558@2x.png` | `Image_558_2x.png` |
| `Mask Group 1.png` | `Mask_Group_1.png` |
| `1a7e2eebec89d55f77cbb70d2bfa1f9e@2x.png` | `1a7e2eebec89d55f77cbb70d2bfa1f9e_2x.png` |

**Implementation:** When copying files with `cp`, rename in the same command:
```bash
cp "$ASSETS/Images/Group 2620@2x.png" "$DEST/Group_2620_2x.png"
```

Then in HTML:
```html
<img alt="" height="[H]" src="Group_2620_2x.png" style="width: [W]px; height: [H]px; display: block;" width="[W]">
```

- **All image `src` attributes use just the sanitized filename** — no folder prefix, no CDN URL
- **For shared images** (e.g. `ZAS######_Miracle_Launch2_KE-TZ.png`), create region-specific copies: `ZAS######_Miracle_Launch2_KE.png` and `ZAS######_Miracle_Launch2_TZ.png`, then create matching HTML files: `ZAS######_Miracle_Launch2_KE.html` and `ZAS######_Miracle_Launch2_TZ.html`

This way Danny can import the folder or its matching zip straight into Everlytic with only the relevant images.

### Image rules

- Full-width images: `width="600"`
- Images inside inner containers (e.g. 520px wide): use that width
- Always include `display: block` on images to prevent gaps between images in email clients
- Always specify explicit `width` and `height` attributes (both as HTML attributes AND in the style — Outlook needs the HTML attribute)
- Always add `border="0"` on linked images to prevent Outlook adding a blue border: `<img ... border="0">`

**Mapping cut-up images to sections:**
- The subfolder name tells you which section it belongs to (e.g. subfolder "KV" = hero/key visual)
- Use the **sanitized** filename (spaces → underscores, special chars removed) in the HTML `src` attribute — NOT the original filename from the subfolder
- If a section has multiple images (e.g. two CTA buttons side by side), they'll be in the same subfolder
- If there's no cut-up provided for a section, use a descriptive placeholder comment: `<!-- IMAGE NEEDED: description of what goes here -->`

### GIF sections and missing images

When a section in the design shows a GIF, or when a cut-up image is not provided for a section, **use a blank image placeholder**. This applies to both GIF animations and any other missing image.

Use a standard blank/transparent placeholder image (`placeholder.png` or similar) at the correct dimensions read from the design. Danny will swap it out for the real image or GIF when he has it. No special comment structure is needed — just a correctly-sized `<img>` tag with a descriptive `alt` attribute.

```html
<tr>
    <td style="text-align:center;">
        <img alt="[Section description]" border="0" height="[H]" src="placeholder.png" style="width:[W]px; height:[H]px; display:block; margin:auto;" width="[W]">
    </td>
</tr>
```

GIF sections follow the same structure as any image section — headline + body copy + image (placeholder) + CTA button. Animated GIFs work in all clients except Outlook, which shows only the first frame (Danny's responsibility when creating the GIF).

**For footer social icons and reusable assets** (like `group_137.png` through `group_144.png`): these are permanent assets already hosted on the Everlytic CDN. Keep these as full CDN URLs — they do not need to be in the output folder:
`https://cdn19.mailercdn.net/users/assets/379/images/[FILENAME]`

### Danny's own cuts from the main design image

Danny sometimes cuts additional image sections directly from the main design PNG/JPG himself — these are sections that either weren't provided as cut-ups by the design team, or where the cut-up can't be used as-is (e.g. the border strips for the sliced-frame technique). These appear with garbled auto-generated filenames (e.g. `dswaefrgtrhnfw-0001.jpg`). They work identically to cut-up images — reference them by filename only (relative path) in the HTML. Once imported into Everlytic, all images become CDN URLs regardless of their original filename.

### Image Resolution Rule — Always Use Standard (1x) Images

**Always use the standard (1x) image, never the @2x version.** @2x files can exceed 600KB–1.4MB, which is unacceptably large for email. File size matters.

Cut-up folders often contain two versions:
- `Group 2620.png` — standard resolution (e.g. 180×174 px) ← **USE THIS**
- `Group 2620@2x.png` — double resolution (e.g. 360×348 px) ← **DO NOT USE**

Use the 1x file at its actual pixel dimensions — no halving required:

```html
<!-- 1x image: actual file is 180×174px, display at full size -->
<img alt="" height="174" src="Group_2620.png" style="width: 180px; height: 174px; display: block;" width="180">
```

**If only the @2x version exists** (no 1x variant in the folder), use it but set the display dimensions to half its actual pixel size to avoid it rendering at double size.

**If only one version exists with no @2x indicator**, use it at its actual dimensions.

---

## Decorative Frame / Border Image — Sliced Border Technique

Samsung SA mailers sometimes feature promotional cards with ornate decorative borders (e.g. a purple-blue bevelled frame surrounding an offer). These **cannot** use CSS `background-image` (broken in Outlook) or the HTML `background` attribute on `<td>` (unreliable sizing/tiling). The correct, Outlook-safe solution is to **slice the frame into separate image strips** and build a table around the HTML content.

### How to identify this situation
When a cut-up folder contains a frame image (e.g. `Image 563.png` — a decorative rectangular border with an empty white interior), that image needs to be sliced into 4 pieces. **Danny creates these slices himself** from the main design PNG/JPG in Photoshop — the designers don't know about Outlook limitations and often supply a single full frame image. Danny cuts it into:

| Piece | Description | Width | Height |
|-------|-------------|-------|--------|
| Top strip | Full-width top border | 600px | top border height |
| Left strip | Left border strip only | left border width | centre content height |
| Right strip | Right border strip only | right border width | centre content height |
| Bottom strip | Full-width bottom border | 600px | bottom border height |

**The left and right strip widths are fixed** — the `<td>` cells holding them are set to exactly the same pixel width as the image. The middle `<td>` is the remaining width and holds all the HTML copy.

**If you receive only a single unsliced frame image** with no separate top/left/right/bottom pieces in the cut-up folder — **stop and flag this to Danny**. Ask him to slice it before you proceed. Do NOT use the `background` attribute on `<td>` or CSS `background-image` as a workaround — these break in Outlook.

### Sliced border table structure

```html
<!-- Outer section wrapper -->
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background:#ffffff;" width="600">
    <tbody>
        <!-- Top border strip — full width -->
        <tr>
            <td style="text-align:center;">
                <img alt="" border="0" height="[TOP_H]" src="[FRAME_TOP].jpg" style="width:600px; height:[TOP_H]px; display:block;" width="600">
            </td>
        </tr>

        <!-- Middle row: left border | HTML content | right border -->
        <tr>
            <td style="width:[LEFT_W]px;">
                <img alt="" border="0" height="[MID_H]" src="[FRAME_LEFT].jpg" style="width:[LEFT_W]px; height:[MID_H]px; display:block; float:left;" width="[LEFT_W]">
            </td>
            <td style="background-color:#ffffff; vertical-align:top;">
                <!-- ALL HTML CONTENT GOES HERE — text, icons, buttons -->
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr><td align="center"><img alt="[ICONS]" ...></td></tr>
                        <tr><td align="center"><span style="font-size:48px;"><strong>...</strong></span></td></tr>
                        <tr><td align="center"><span style="font-size:20px;">...</span></td></tr>
                        <tr><td align="center"><a href="[LINK]"><img alt="[CTA]" ...></a></td></tr>
                    </tbody>
                </table>
            </td>
            <td style="width:[RIGHT_W]px;">
                <img alt="" border="0" height="[MID_H]" src="[FRAME_RIGHT].jpg" style="width:[RIGHT_W]px; height:[MID_H]px; display:block; float:right;" width="[RIGHT_W]">
            </td>
        </tr>

        <!-- Bottom border strip — full width -->
        <tr>
            <td style="text-align:center;">
                <img alt="" border="0" height="[BTM_H]" src="[FRAME_BOTTOM].jpg" style="width:600px; height:[BTM_H]px; display:block;" width="600">
            </td>
        </tr>
    </tbody>
</table>
```

**Key rule:** The middle td containing HTML content uses `background-color:#ffffff` (or whatever the interior card colour is). The left/right border image heights must equal the height of the content area — Danny will have matched them when slicing.

---

## Pricing Table Pattern

Many Samsung mailers include a pricing pod showing a device model, storage, plan name, and price. This appears in a 3-column layout: **pricing table left | phone image centre | features box right**.

### When to use HTML vs cut-up image

- **Cut-up image provided for the pricing table** → use the cut-up image in a `<td>` (no need to build it from HTML)
- **No cut-up provided** → build the pricing table from HTML using the pattern below

### Pricing table structure

The table is 180px wide, left-aligned, with a 1px black border. It has these rows:

| Row | Background | Text colour | Content |
|-----|-----------|-------------|---------|
| Header | `#000000` (black) | White | Model name (left) + storage badge image (right) |
| Plan name | `#696884` (purple-grey) | White bold | e.g. "Top Up XS Plus" |
| Once off price | `#ffffff` | Black | e.g. "Once off **R31 999**" |
| PM price | `#ffffff` | Black | e.g. "**R1 239** PM x 36" |
| Save row *(optional)* | `#ffffff` | Black | e.g. "Save **R3 600**" |
| Plan details *(optional)* | `#ffffff` | Black | e.g. "6GB Red Core | 250 Min" |

**Storage badge image (optional):** `https://cdn19.mailercdn.net/users/assets/379/images/512gb-402x.png` — include when the design shows a 512GB badge in the header. Omit when not present.

### Pricing table HTML
```html
<table align="left" border="0" cellpadding="5" cellspacing="0" style="border-collapse:collapse;border:1px solid rgb(0, 0, 0);width:180px;">
    <tbody>
        <tr>
            <td align="center" style="background-color: rgb(0, 0, 0);">
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:100%;">
                    <tbody>
                        <tr>
                            <td style="text-align: right;"><span style="font-size:14px;"><span style="color:#FFFFFF;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[MODEL NAME]<br>[MODEL VARIANT]</span></strong></span></span></td>
                            <td style="width: 45px;"><img align="right" alt="" height="19" src="https://cdn19.mailercdn.net/users/assets/379/images/512gb-402x.png" style="float: right;" width="40"></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td align="center" style="background-color: rgb(105, 104, 132); border-bottom: 1px solid rgb(0, 0, 0);"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="font-size:16px;"><span style="color:#FFFFFF;"><strong>[PLAN NAME]</strong></span></span></span></td>
        </tr>
        <tr>
            <td align="center" style="border-bottom: 1px solid rgb(0, 0, 0); background-color: rgb(255, 255, 255); text-align: center;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="font-size:14px;"><span style="color:#000000;">Once off </span></span><span style="font-size:24px;"><span style="color:#000000;"><strong>[ONCE OFF PRICE]</strong></span></span></span></td>
        </tr>
        <tr>
            <td align="center" style="background-color: rgb(255, 255, 255); text-align: center;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="font-size:24px;"><span style="color:#000000;"><strong>[PM PRICE]</strong></span></span><span style="font-size:14px;"><span style="color:#000000;"> PM x [MONTHS]</span></span></span></td>
        </tr>
    </tbody>
</table>
```

**To add a Save row** (insert before the PM price row, or after — read the design):
```html
<tr>
    <td align="center" style="border-bottom: 1px solid rgb(0, 0, 0); background-color: rgb(255, 255, 255); text-align: center;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="font-size:14px;"><span style="color:#000000;">Save </span></span><span style="font-size:24px;"><span style="color:#000000;"><strong>[SAVE AMOUNT]</strong></span></span></span></td>
</tr>
```

**To add a plan details row** (e.g. data/minutes — insert at bottom):
```html
<tr>
    <td align="center" style="background-color: rgb(255, 255, 255); text-align: center;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="font-size:14px;"><span style="color:#000000;">[PLAN DETAILS e.g. 6GB Red Core | 250 Min]</span></span></span></td>
</tr>
```

### 3-column pricing layout (pricing + phone + features)

When the pricing section is a 3-column layout (table left, phone centre, features box right):

**If cut-up images are provided for all three columns** — use images in a 3-cell row:
```html
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background:[BG_COLOR];" width="600">
    <tbody>
        <tr>
            <td style="width:200px; vertical-align:top;"><img alt="" height="[H]" src="[PRICING_CUTUP]" style="width:200px; height:[H]px; display:block;" width="200"></td>
            <td style="width:200px; vertical-align:top;"><img alt="" height="[H]" src="[PHONE_CUTUP]" style="width:200px; height:[H]px; display:block;" width="200"></td>
            <td style="width:200px; vertical-align:top;"><img alt="" height="[H]" src="[FEATURES_CUTUP]" style="width:200px; height:[H]px; display:block;" width="200"></td>
        </tr>
    </tbody>
</table>
```

**If only the pricing table needs to be built from HTML** (phone and features are cut-up images):

Use **5-column layout with left/right spacer TDs** to create the proper side padding visible in the design. Never let content run flush to the left edge of the email.

```html
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background:[BG_COLOR];" width="600">
    <tbody>
        <tr>
            <td colspan="5" height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
        <tr>
            <!-- Left spacer -->
            <td width="15">&nbsp;</td>
            <!-- Pricing table column: 185px holds a 180px table -->
            <td style="vertical-align:middle;" width="185">
                [PRICING TABLE HTML from above]
            </td>
            <!-- Phone image column: centred -->
            <td style="text-align:center; vertical-align:bottom;" width="205">
                <a href="[LINK]" target="_blank"><img alt="[PHONE ALT]" border="0" height="[H]" src="[PHONE_IMAGE]" style="display:block; margin:0 auto; width:[W]px; height:[H]px;" width="[W]"></a>
            </td>
            <!-- Features cut-up column: image sits at right with 15px breathing room from edge -->
            <td style="vertical-align:top;" width="180">
                <img alt="[FEATURES ALT]" height="[H]" src="[FEATURES_IMAGE]" style="display:block; width:180px; height:[H]px;" width="180">
            </td>
            <!-- Right spacer -->
            <td width="15">&nbsp;</td>
        </tr>
        <tr>
            <td colspan="5" height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
    </tbody>
</table>
```

Column widths: 15 + 185 + 205 + 180 + 15 = **600px** ✓

### Section separators between pricing rows

**Do NOT add coloured separator rows** (e.g. `height="1" background-color:#dddddd`) between pricing sections unless the design clearly shows a visible divider line. The top/bottom spacer rows (height=20) provide natural breathing room. Adding spurious separator lines creates visual artefacts that are not in the design.

### Pricing table model name — font size

The model name in the pricing table header (e.g. "Galaxy S26 Ultra") must fit on **one line**. The available text width inside the header is narrow (~115px after badge column and padding). Use **`font-size:11px`** for the model name to ensure it never wraps. If a particular model name is short, 12px may work — but 11px is the safe default.

```html
<td style="text-align:left; padding:4px 4px 4px 6px; vertical-align:middle; white-space:nowrap;">
    <span style="font-size:11px;"><span style="color:#FFFFFF;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[MODEL NAME]</span></strong></span></span>
</td>
```

Adding `white-space:nowrap` on the text TD also guarantees single-line rendering regardless of container width.

---

## CTA Buttons — ALWAYS Use Image Buttons

**CRITICAL RULE: Never create CSS or HTML text buttons.** HTML buttons (using `border-radius`, `background-color`, `padding` on an anchor or `<td>`) render as flat rectangles in Outlook and look unprofessional. **All CTA buttons must be `<img>` tags.**

### Use the CORRECT button for each section — read the design carefully

**Critical:** Each section's CTA button text must match exactly what is in the JPG design for that section. Do NOT reuse the same button image across all sections if the button texts differ. For example, if one section says "Learn More" and another says "Redeem Now" — those are different buttons requiring different images. Read each section's button text from the JPG individually.

### Duplicate button variants — pick one and reuse it

The design team often exports multiple copies of the same button (e.g. `Group 2479.png`, `Group 2480.png`, `Group 2481.png` — all saying "Learn more"). These are identical images. **Pick one and use it for every instance of that button text throughout the entire mailer.** Do not assign a different numbered variant to each section — the variants are not meaningful and using one consistently is preferred.

### If a button cut-up image is provided
Use it as a local image file (same flat output folder rule as all other images).

### If no button cut-up is provided
Use the standard Samsung SA CDN button images. Do NOT create a CSS button — **ASK for the button image instead**, or fall back to the CDN defaults below:

| Button text | CDN URL | Width | Height |
|-------------|---------|-------|--------|
| Learn more | `https://cdn19.mailercdn.net/users/assets/379/images/group_2418-402x.png` | 172 | 50 |
| Buy now | `https://cdn19.mailercdn.net/users/assets/379/images/group_2451-402x_1.png` | 136 | 50 |
| Compare now | `https://cdn19.mailercdn.net/users/assets/379/images/group_2438-402x.png` | 196 | 50 |
| Shop now | *(ask for image)* | — | — |
| Find out more | *(ask for image)* | — | — |

### Button HTML pattern
```html
<td align="center">
    <a href="[LINK]" target="_blank">
        <img alt="[BUTTON TEXT]" height="50" src="[BUTTON_IMG_URL_OR_FILENAME]" style="width:[W]px; height:50px; display:block; margin:auto;" width="[W]">
    </a>
</td>
```

**If you realise mid-build that a required button image is missing and no CDN fallback is listed above, stop and ask Danny for the image before proceeding.**

---

## Carrier Pricing Layout (3 Phone Pods Side-by-Side)

Some mailers (typically carrier deals — Vodacom, MTN, etc.) show three phone models side-by-side, each with its own pricing card beneath it. This is different from the 5-column FNB-style layout.

### Structure
- Outer table: 600px, white bg
- Inner table: `style="width:95%"` centred, no fixed pixel width
- 3 equal columns (`width:33%`, `width:34%`, `width:33%`)
- Row 1: phone pod images (180px each, `@2x` rule applies)
- Row 2: spacer
- Row 3: pricing cards (one per column — see pattern below)
- Row 4: spacer
- Row 5: Buy now buttons (one per column)

### Per-phone pricing card
Each card is a `<table>` with `border:1px solid #000; border-collapse:collapse; width:180px; cellpadding="5"`. Left card uses `align="left"`, centre uses `align="center"`, right uses `align="right"`.

**Carrier-style pricing card rows:**
| Row | Background | Notes |
|-----|-----------|-------|
| Header | `#000000` | Model name (right-aligned) + storage badge (float right, 40×19) |
| Price row | `#ffffff` | Has `border-bottom:1px solid #000`. Price bold 24px + "PM x 36" at 14px |
| Plan details | `#ffffff` | e.g. "6GB Red Core \| 250 Min" at 14px |

```html
<table align="left" border="0" cellpadding="5" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:180px;">
    <tbody>
        <tr>
            <td align="center" style="background-color:#000000;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:100%;">
                    <tbody>
                        <tr>
                            <td style="text-align:right;"><span style="font-size:14px;"><span style="color:#ffffff;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[MODEL NAME]</span></strong></span></span></td>
                            <td style="width:45px;"><img align="right" alt="[STORAGE]" height="19" src="[STORAGE_BADGE]" style="float:right;" width="40"></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td align="center" style="border-bottom:1px solid #000000; background-color:#ffffff; font-family:Samsung Sharp Sans,avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-align:center;">
                <span style="font-size:24px; color:#000000;"><strong>[PRICE]&nbsp;</strong></span><span style="font-family:Samsung Sharp Sans,avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; color:#000000;">PM x 36&nbsp;</span>
            </td>
        </tr>
        <tr>
            <td align="center" style="background-color:#ffffff; font-family:Samsung Sharp Sans,avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-align:center;">
                <span style="font-size:14px; color:#000000;">[PLAN DETAILS e.g. 6GB Red Core | 250 Min]</span>
            </td>
        </tr>
    </tbody>
</table>
```

**Storage badge CDN URL:** `https://cdn19.mailercdn.net/users/assets/379/images/512gb-402x.png` (40×19)

### Full 3-pod section outer wrapper
```html
<table border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr>
            <td style="text-align:center;"><br><br>&nbsp;&nbsp;
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:95%;">
                    <tbody>
                        <!-- Row 1: phone pods -->
                        <tr>
                            <td align="center" style="width:33%;"><img align="left" alt="[S26 Ultra]" height="[H]" src="[POD_1]" style="display:block; margin:auto; float:left; width:[W]px; height:[H]px;" width="[W]"></td>
                            <td align="center" style="width:34%;"><img alt="[S26+]" height="[H]" src="[POD_2]" style="display:block; border:0; margin:0 auto; width:[W]px; height:[H]px;" width="[W]"></td>
                            <td align="center" style="width:33%;"><img alt="[S26]" height="[H]" src="[POD_3]" style="display:block; border:0; margin:0 auto; width:[W]px; height:[H]px;" width="[W]"></td>
                        </tr>
                        <tr><td align="center"></td><td align="center">&nbsp;&nbsp;&nbsp;</td><td align="center"></td></tr>
                        <!-- Row 3: pricing cards -->
                        <tr>
                            <td align="center">[LEFT PRICING CARD — align="left"]</td>
                            <td align="center">[CENTRE PRICING CARD — align="center"]</td>
                            <td align="center">[RIGHT PRICING CARD — align="right"]</td>
                        </tr>
                        <tr><td align="center"></td><td align="center">&nbsp;&nbsp;</td><td align="center"></td></tr>
                        <!-- Row 5: buy now buttons -->
                        <tr>
                            <td align="center"><a href="[LINK_1]" target="_blank"><img alt="Buy now" height="50" src="[BUY_NOW_IMG]" style="width:136px; height:50px; display:block; margin:auto;" width="136"></a></td>
                            <td align="center"><a href="[LINK_2]" target="_blank"><img alt="Buy now" height="50" src="[BUY_NOW_IMG]" style="width:136px; height:50px; display:block; margin:auto;" width="136"></a></td>
                            <td align="center"><a href="[LINK_3]" target="_blank"><img alt="Buy now" height="50" src="[BUY_NOW_IMG]" style="width:136px; height:50px; display:block; margin:auto;" width="136"></a></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr><td style="text-align:center;">&nbsp;&nbsp;</td></tr>
        <tr><td style="text-align:center;"><br>&nbsp;&nbsp;</td></tr>
    </tbody>
</table>
```

---

## Lifestyle / CRM Product Section Structure

Some Samsung SA mailers (typically CRM or Lifestyle TV campaigns) use a **repeating product section pattern** instead of a single hero + pricing pod. Each product category gets its own identically-structured section. Identify this layout when the email has 3+ sections that all follow the same visual rhythm.

### Section sequence (repeated for each product)

1. **Section header** — 600px wide table, bg `#746D63`, centred bold text heading
2. **Section banner** — 534px wide image, centred in the 600px container, linked to product URL. Use 1x image (over 520px threshold — do NOT use @2x)
3. **Pricing area** — bg `#EDEAE3`, row of pricing blocks (see count per section — varies). Omit this step if the section has no pricing (e.g. a "Find out where to buy" section)
4. **"Key features at a glance:"** — centred text label on the `#EDEAE3` background. Omit if no pricing area
5. **Feature image** — transparent/light PNG showing icons + feature labels, centred, at its natural display width
6. **CTA button** — centred, below feature image, linked to product URL

**Exception — extra bottom image:** The first section (only) may have an additional standalone image at the very bottom after the feature image (e.g. "TV when it's On. Art when it's off."). This is section-specific — do not add it to other sections unless the JPG shows it.

### Full section outer table structure

Each product section is ONE outer 600px white table. The auto-width header and the 534px #EDEAE3 content card both live inside it. Do NOT break them into separate tables.

```html
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <!-- top spacer -->
        <tr><td colspan="3" height="20" style="font-size:1px;line-height:1px;">&nbsp;</td></tr>
        <!-- auto-width section header — NOT 600px wide, just fits the text -->
        <tr>
            <td colspan="3" style="text-align:center; padding-bottom:10px;">
                <table align="center" border="0" cellpadding="8" cellspacing="0" style="background-color:#746D63;">
                    <tbody>
                        <tr>
                            <td style="text-align:center; white-space:nowrap;">
                                <span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:18px; color:#ffffff;"><strong>[HEADING TEXT]</strong></span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <!-- 534px EDEAE3 card — 33px gutters each side -->
        <tr>
            <td width="33">&nbsp;</td>
            <td width="534">
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#EDEAE3;" width="534">
                    <tbody>
                        <!-- BANNER — fills card edge to edge, font-size:0 prevents gap -->
                        <tr>
                            <td style="text-align:center; font-size:0; line-height:0;">
                                <a href="[PRODUCT_URL]" target="_blank">
                                    <img alt="[ALT]" border="0" height="[H]" src="[BANNER_IMAGE]" style="display:block; width:534px; height:[H]px;" width="534">
                                </a>
                            </td>
                        </tr>
                        <!-- PRICING BLOCKS — centred inner table, 3px padding between blocks -->
                        <tr>
                            <td style="text-align:center; padding:12px 0;">
                                <table align="center" border="0" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr>
                                            <td style="padding:0 3px; vertical-align:top;">[BLOCK]</td>
                                            <td style="padding:0 3px; vertical-align:top;">[BLOCK]</td>
                                            <!-- repeat as needed -->
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <!-- BUY NOW BUTTON — comes BEFORE key features -->
                        <tr>
                            <td style="text-align:center; padding:10px 0;">
                                <a href="[PRODUCT_URL]" target="_blank">
                                    <img alt="Buy now" border="0" height="48" src="Group 722@2x.png" style="display:block; width:118px; height:48px; margin:auto;" width="118">
                                </a>
                            </td>
                        </tr>
                        <!-- KEY FEATURES LABEL — no colon -->
                        <tr>
                            <td style="text-align:center; padding:12px 0 6px 0;">
                                <span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; color:#000000;"><strong>Key features at a glance</strong></span>
                            </td>
                        </tr>
                        <!-- FEATURE PNG -->
                        <tr>
                            <td style="text-align:center; padding-bottom:15px;">
                                <img alt="Key features" height="[H]" src="[FEATURE_PNG]" style="display:block; margin:auto; width:[W]px; height:[H]px;" width="[W]">
                            </td>
                        </tr>
                        <!-- BOTTOM IMAGE — Section 1 ONLY — white bg row -->
                        <tr>
                            <td style="text-align:center; font-size:0; line-height:0; background-color:#ffffff;">
                                <img alt="TV when it's on. Art when it's off." height="[H]" src="Group 1345@2x.png" style="display:block; width:534px; height:[H]px;" width="534">
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
            <td width="33">&nbsp;</td>
        </tr>
        <!-- bottom spacer -->
        <tr><td colspan="3" height="20" style="font-size:1px;line-height:1px;">&nbsp;</td></tr>
    </tbody>
</table>
```

**Key rules:**
- The `#746D63` header is auto-width (`white-space:nowrap` on the inner td) — never 600px wide
- The 534px card sits inside a 3-column row: `33px | 534px | 33px`
- Banner fills to card edge (no padding on the banner td, `font-size:0; line-height:0` prevents gaps)
- Order inside card: banner → pricing → **Buy now button** → key features label → feature PNG → [optional bottom image]
- "Key features at a glance" — **no colon**
- Section 5 (no pricing): skip pricing row and Buy now; use "Where to buy" button instead

### Pricing blocks (Danny's template — sharp corners, 120px wide)

Danny's exact pricing block for this layout. Use for the standard 4-across (or 2-across) row. There is a ~5px gap between blocks.

```html
<table align="center" border="0" cellpadding="5" cellspacing="0" style="border-collapse:collapse;border:1px solid rgb(0, 0, 0);width:120px;">
    <tbody>
        <tr>
            <td style="line-height:12px; background-color: rgb(0, 0, 0); vertical-align: top; font-family: Samsung Sharp Sans, avant garde, avantgarde, century gothic, centurygothic, applegothic, sans-serif; color: rgb(255, 255, 255); font-size: 20px;">
                <strong><span style="font-size:10px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[PRODUCT NAME]</span></span></strong><br>
                <span style="font-size:10px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[MODEL NUMBER]</span></span>
            </td>
        </tr>
        <tr>
            <td style="border-bottom: 1px solid #000; background-color: rgb(255, 255, 255); font-family: Samsung Sharp Sans, avant garde, avantgarde, century gothic, centurygothic, applegothic, sans-serif; font-size: 20px;">
                <span style="font-size:10px; color:#000000;">Now&nbsp;</span><span style="font-size:20px; color:#000000;"><strong>&nbsp;[PRICE]</strong></span>
            </td>
        </tr>
        <tr>
            <td style="background-color: rgb(255, 255, 255); font-family: Samsung Sharp Sans, avant garde, avantgarde, century gothic, centurygothic, applegothic, sans-serif; font-size: 20px;">
                <span style="font-size:9px; color:#000000;">Save&nbsp;</span><span style="font-size:20px; color:#000000;"><strong>&nbsp;[SAVE AMOUNT]</strong></span>
            </td>
        </tr>
    </tbody>
</table>
```

**Row layout for multiple blocks** (wrap each block in a `<td style="padding:0 5px;">`):

```html
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#EDEAE3;" width="600">
    <tbody>
        <tr>
            <td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
        <tr>
            <td style="text-align:center;">
                <table align="center" border="0" cellpadding="0" cellspacing="0">
                    <tbody>
                        <tr>
                            <td style="padding:0 5px;">[PRICING BLOCK]</td>
                            <td style="padding:0 5px;">[PRICING BLOCK]</td>
                            <!-- repeat as needed -->
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
    </tbody>
</table>
```

**Single wide block:** Same 3-row structure (black header / white price row / white save row) — adjust `width` to suit (e.g. ~280px). Centre it in the `#EDEAE3` section.

**Block counts per section:** Read the JPG. Typical counts: 4 (standard row), 2 (two models), 1 (single featured product, use wider block).

### "Key features at a glance:" text

Centred, Samsung Sharp Sans, black, ~14px bold, on the `#EDEAE3` background:

```html
<tr>
    <td style="text-align:center; padding:10px 0 5px 0;">
        <span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; color:#000000;"><strong>Key features at a glance:</strong></span>
    </td>
</tr>
```

### Sharp corners

This section structure uses **sharp corners throughout** — no rounded border treatments. The `#EDEAE3` pricing area and feature blocks all have standard square `<table>` edges. Do not apply any border-radius or sliced-frame technique.

---

## White-Text Images on Dark Backgrounds

Some cut-up images contain **white text on a transparent background**. When you preview or view them, they will appear completely blank/invisible against a white background — but they are NOT empty. They are designed to sit on top of a dark-coloured section.

**Example:** `Group 1733` — appears blank/white when viewed, but contains white text "Compared with Galaxy S24 Ultra" intended to appear on a purple/dark background.

**Rule:** Never skip a cut-up image just because it appears blank. If a cut-up image appears blank/white and the corresponding section in the design has dark-coloured text or a subheading, check whether it's a white-text-on-transparent image and place it in the correct dark-background section.

---

## Nested Content Cards — Verifying Image vs HTML Text

### Blank background/rectangle images — IGNORE THEM

Designers sometimes supply files named `Rectangle_xxx.png` or similar that are **just a solid or gradient coloured background** with no content on them. They supply these because they expect HTML text/elements to be layered on top in the browser — but **this does not work in email clients**. CSS positioning and `background-image` layering is broken in Outlook and unreliable elsewhere.

**How to identify a useless background image:**
- The file is a `Rectangle_xxx.png` or similarly generic name
- When you open it, it is a plain coloured rectangle with no text, icons, or content
- It has rounded corners (a design-only affordance that we cannot reproduce in HTML anyway)

**What to do:** Discard the image entirely. Build the full section as an HTML table with the correct background colour and all content (icons, headline, body copy, CTA button) as HTML inside it. **Always read the full design JPG** to determine which card style to use:

### Card style variants — read the design to pick the right one

**Style 1 — Gray background card, no border** (most common in onboarding/CRM mailers):
The design shows a light gray card (`#F4F4F4` or `#EFEFEF`) with content inside and no visible border. The outer 600px table is white. Build it as a gray inner table with padding gutters.

```html
<!-- Outer white table -->
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td align="center" style="padding:0 30px;">
                <!-- Gray inner card — no border, sharp corners -->
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; width:540px;">
                    <tbody>
                        <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- icon -->
                        <tr>
                            <td style="text-align:center;">
                                <img alt="[ICON ALT]" height="[H]" src="[ICON_IMG]" style="display:block; margin:auto; width:[W]px; height:[H]px;" width="[W]">
                            </td>
                        </tr>
                        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- headline -->
                        <tr>
                            <td style="text-align:center; padding:0 30px;">
                                <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">[HEADLINE WITH &lt;br&gt; LINE BREAKS]</span></strong></span>
                            </td>
                        </tr>
                        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- body copy (if present) -->
                        <tr>
                            <td style="text-align:center; padding:0 30px;">
                                <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">[BODY COPY WITH &lt;br&gt; LINE BREAKS]</span>
                            </td>
                        </tr>
                        <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- CTA button -->
                        <tr>
                            <td style="text-align:center; padding-bottom:30px;">
                                <a href="[LINK]" target="_blank"><img alt="[BUTTON TEXT]" border="0" height="50" src="[BUTTON_IMG]" style="display:block; margin:auto; width:[W]px; height:50px;" width="[W]"></a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
    </tbody>
</table>
```

**Style 2 — White background card, black border** (used when the design shows a visible black/dark border around the card):

```html
<!-- Outer white table -->
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td align="center" style="padding:0 30px;">
                <!-- White inner card with black border, sharp corners -->
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; border:1px solid #000000; width:540px;">
                    <tbody>
                        <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- icon (if present in design) -->
                        <tr>
                            <td style="text-align:center;">
                                <img alt="[ICON ALT]" height="[H]" src="[ICON_IMG]" style="display:block; margin:auto; width:[W]px; height:[H]px;" width="[W]">
                            </td>
                        </tr>
                        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- headline -->
                        <tr>
                            <td style="text-align:center; padding:0 30px;">
                                <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">[HEADLINE]</span></strong></span>
                            </td>
                        </tr>
                        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- body copy -->
                        <tr>
                            <td style="text-align:center; padding:0 30px;">
                                <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">[BODY COPY WITH &lt;br&gt; LINE BREAKS]</span>
                            </td>
                        </tr>
                        <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- CTA button -->
                        <tr>
                            <td style="text-align:center; padding-bottom:30px;">
                                <a href="[LINK]" target="_blank"><img alt="[BUTTON TEXT]" border="0" height="50" src="[BUTTON_IMG]" style="display:block; margin:auto; width:[W]px; height:50px;" width="[W]"></a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
    </tbody>
</table>
```

Both styles sit inside the outer 600px white table with 30px gutters each side. **Both always use sharp corners — no `border-radius`.**

### Picking Style 1 vs Style 2 — check EACH card individually

**Critical:** A single mailer often contains BOTH styles — do not assume all card sections use the same style. Adjacent cards in the design frequently alternate between black-border (Style 2) and gray-fill (Style 1) for visual rhythm.

**For every card section, look at the design and ask these two questions in order:**

1. **Is the card background a different colour from the surrounding white?**
   - If the card area is clearly a light gray block (`#F4F4F4` / `#EFEFEF`) sitting on white → **Style 1 (gray fill, no border)**
   - If the card area is the same white as everything around it → go to question 2

2. **Is there a visible thin black/dark line around the card edge?**
   - If yes (a 1px dark rule traces the rectangle) → **Style 2 (white fill, 1px black border)**
   - If no visible edge at all → it's not a card; it's just a content block on white

**Quick visual cheat sheet:**

| What you see in the design | Style |
|---|---|
| Light gray block on white background, no border line | **Style 1** — `background-color:#F4F4F4` |
| White block on white background with thin black outline | **Style 2** — `background-color:#ffffff; border:1px solid #000000` |
| Two cards stacked in the same section, one gray and one bordered | **Mix both** — don't apply one style to both |

**Common mistake:** Using the same card style for two adjacent sections because they have similar layout (icon + headline + body + CTA). The layout being similar doesn't mean the visual treatment is the same — always look at the actual fill colour and presence of a border edge for each card separately.

---

### Side-by-side product pod cards — with a small gap between them

A very common Samsung pattern is **two product pod cards displayed side-by-side**, each on its own gray (`#F4F4F4`) card background, with a small visible gap (~5–10px) between the two cards. Each card typically contains: product image → product name → "Buy now" / "Learn more" button.

**How to spot this pattern in the design:**
- Two roughly equal-width blocks sitting next to each other across the 600px width
- Each block has a light gray fill that's clearly different from the surrounding white
- A thin **white strip** (the gap) is visible between the two blocks
- Each block contains its own image + label + button — they are NOT one merged image

**Critical mistakes to avoid:**
1. **Treating the two gray rectangles as a single image** — placeholder cut-ups like `Rectangle_xxxx_2x.png` next to `Rectangle_yyyy_2x.png` are blank gray boxes. They MUST be discarded and replaced with HTML cards.
2. **Building one wide gray card and putting both products inside** — the design clearly shows two separate cards with a gap; do not merge them.
3. **Placing product image + name + button without any gray background** — the gray fill is part of the design; build the gray card explicitly.
4. **Using `cellpadding` or `cellspacing` on the outer table to create the gap** — this often renders inconsistently in Outlook. Use an explicit empty spacer cell with a fixed width instead.

**Standard pod row template (2-up gray cards with 10px gap):**

```html
<!-- Pod row — 2 gray cards side-by-side with 10px gap -->
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr>
            <td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
        <tr>
            <td align="center" style="padding:0 30px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="540">
                    <tbody>
                        <tr valign="top">
                            <!-- Card 1 -->
                            <td bgcolor="#F4F4F4" style="background-color:#F4F4F4; width:265px; text-align:center; padding:25px 15px;" width="265">
                                <img alt="[PRODUCT 1]" border="0" height="[H]" src="[IMG1]" style="display:block; margin:auto; width:[W]px; height:[H]px;" width="[W]"><br>
                                <span style="font-size:18px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy [Product 1]</span></strong></span><br><br>
                                <a href="[LINK1]" target="_blank"><img alt="Buy now" border="0" height="50" src="[BUTTON_IMG]" style="display:block; margin:auto; width:144px; height:50px;" width="144"></a>
                            </td>
                            <!-- Spacer cell creates the visible gap between the two cards -->
                            <td style="width:10px; font-size:1px; line-height:1px;" width="10">&nbsp;</td>
                            <!-- Card 2 -->
                            <td bgcolor="#F4F4F4" style="background-color:#F4F4F4; width:265px; text-align:center; padding:25px 15px;" width="265">
                                <img alt="[PRODUCT 2]" border="0" height="[H]" src="[IMG2]" style="display:block; margin:auto; width:[W]px; height:[H]px;" width="[W]"><br>
                                <span style="font-size:18px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy [Product 2]</span></strong></span><br><br>
                                <a href="[LINK2]" target="_blank"><img alt="Buy now" border="0" height="50" src="[BUTTON_IMG]" style="display:block; margin:auto; width:144px; height:50px;" width="144"></a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
    </tbody>
</table>
```

**Why this works:** Both `bgcolor` and `style="background-color:..."` are set for Outlook compatibility. The middle empty `<td>` with a fixed width creates a reliable visible gap. Cards have sharp corners (no border-radius). The white outer table background shows through the spacer cell, producing the white strip you see in the design.

**Variants:**
- **3-up pods**: Same pattern but with 3 cards and 2 spacer cells. Card width ≈ 170px each (540 − 20 / 3).
- **Wider gap**: If the design shows a clearly larger gap (~15–20px), increase the spacer `width` accordingly. Always measure from the design.
- **No product label**: If the card only shows image + button, just remove the `<span>` and `<br>` lines.

---

### The golden rule: always check if text is IN the image or separate

Before building any section, look at the cut-up image for that section (if one is provided). Then compare it carefully against the same section in the full design JPG:

- **If the text is clearly rendered inside the cut-up image** (i.e. the text pixels are part of the image file) → use the image as-is; no HTML text needed for that content
- **If the text is NOT in the cut-up image** (the image only shows the product/photo and the text appears below/around it in the design JPG) → the text must be built as HTML, and the inner container table must also be built
- **If the cut-up is a blank coloured rectangle** (`Rectangle_xxx.png` with no content) → discard it entirely and build a full HTML card (Style 1 or Style 2 depending on the design)

**Never assume that a section is "just an image" without checking.** This mistake results in missing copy that looks like blank whitespace.

---

### Pattern A — White outer / Gray inner (image + text inside gray card)

The outer 600px table has a **white background**. Inside it sits a **smaller gray card** (`#F4F4F4` or similar) that contains both the section image AND the text copy below it.

**When you see this in the design:** do NOT just drop the image into the white outer table. You must build the full nested structure — gray inner table with the image row first, then the text rows beneath it.

```html
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr>
            <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
        <tr>
            <td align="center" style="padding:0 30px;">
                <!-- Gray inner card -->
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; width:100%;">
                    <tbody>
                        <!-- Image row -->
                        <tr>
                            <td style="text-align:center; font-size:0; line-height:0;">
                                <img alt="[ALT]" border="0" height="[H]" src="[IMAGE]" style="display:block; width:[W]px; height:[H]px;" width="[W]">
                            </td>
                        </tr>
                        <!-- Text copy row(s) — built as HTML if not in the image -->
                        <tr>
                            <td style="text-align:center; padding:20px 20px 10px 20px;">
                                <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:18px; color:#000000;">
                                    Use code <strong>PPX10</strong> to get <strong>10% off</strong> selected <strong>Galaxy Buds</strong>, <strong>Watch</strong> and <strong>Tablet</strong>
                                </span>
                            </td>
                        </tr>
                        <tr>
                            <td style="text-align:center; padding:0 20px 5px 20px;">
                                <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:12px; color:#000000;">Offer ends 30 June 2026</span>
                            </td>
                        </tr>
                        <!-- CTA Button -->
                        <tr>
                            <td style="text-align:center; padding:15px 20px 25px 20px;">
                                <a href="[LINK]" target="_blank"><img alt="[BUTTON TEXT]" border="0" height="50" src="[BUTTON_IMG]" style="display:block; margin:auto; width:[W]px; height:50px;" width="[W]"></a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
    </tbody>
</table>
```

---

### Pattern B — Gray outer / White inner (text-only card, no image)

Some sections contain **no image at all** — they are entirely text-based (headline + bullet list + CTA button). These can look like an empty white space at first glance. **Always read the design carefully before assuming a section is an image placeholder.**

### How to identify this pattern
- The section has a light-coloured outer background (e.g. light gray `#F4F4F4` or the campaign background colour)
- Inside sits a white (or near-white) content card
- The card contains a headline, a list of bullet points, and a CTA button
- The design may show rounded corners on the inner card — **always render with sharp/square corners** (no `border-radius`)

### HTML structure

Use a nested table: outer table sets the background colour and padding; inner table is the white content card.

```html
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:[OUTER_BG];" width="600">
    <tbody>
        <tr>
            <td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
        <tr>
            <td align="center" style="padding:0 30px;">
                <!-- White inner content card -->
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:100%;">
                    <tbody>
                        <tr>
                            <td style="padding:30px 30px 10px 30px; text-align:left;">
                                <!-- Headline -->
                                <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[HEADLINE TEXT]</span></strong></span>
                            </td>
                        </tr>
                        <!-- Bullet points — one row per bullet -->
                        <tr>
                            <td style="padding:8px 30px 0 30px;">
                                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                    <tbody>
                                        <tr>
                                            <td style="vertical-align:top; width:20px; padding-right:8px;"><span style="color:#1259C3; font-size:20px;">&#x25CF;</span></td>
                                            <td style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">[BULLET TEXT 1]</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding:8px 30px 0 30px;">
                                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                    <tbody>
                                        <tr>
                                            <td style="vertical-align:top; width:20px; padding-right:8px;"><span style="color:#1259C3; font-size:20px;">&#x25CF;</span></td>
                                            <td style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">[BULLET TEXT 2]</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <!-- Repeat bullet rows as needed -->
                        <!-- CTA Button -->
                        <tr>
                            <td style="text-align:center; padding:20px 30px 30px 30px;">
                                <a href="[LINK]" target="_blank"><img alt="[BUTTON TEXT]" border="0" height="50" src="[BUTTON_IMG]" style="display:block; margin:auto; width:[W]px; height:50px;" width="[W]"></a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
    </tbody>
</table>
```

**Key rules:**
- **Never assume a white section is a missing image.** If the JPG shows text, headlines, or bullet points — build it as HTML.
- **Bullet points:** Use a 2-column inner table per bullet (`&#x25CF;` dot in left cell, text in right cell). Do NOT use `<ul>`/`<li>` — these render inconsistently in Outlook.
- **Bullet colour:** Read from the JPG. Often Samsung blue `#1259C3`, but can vary per campaign.
- **Rounded corners on the design:** Always use sharp/square corners in HTML — no `border-radius`.
- **Outer background:** Use the section's background colour from the JPG (often the campaign colour or light gray).

---

## Common Layout Patterns

### Full-width image row
```html
<tr>
    <td><a href="[LINK_URL]" target="_blank"><img alt="[ALT]" border="0" height="[H]" src="[FILENAME]" style="display: block; width: 600px; height: [H]px;" width="600"></a></td>
</tr>
```

### Centred text block
```html
<tr>
    <td style="text-align: center;"><span style="color:#000000;"><span style="font-size:48px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">[HEADLINE]</span></strong></span></span></td>
</tr>
```

### Vertical spacer (between rows)
```html
<tr>
    <td><br>&nbsp; &nbsp; &nbsp;</td>
</tr>
```

### Two CTA buttons side by side
Use a 3-column inner table: right-aligned button | fixed spacer | left-aligned button. This is Danny's production pattern — it centres the button pair visually without needing fixed widths.

```html
<tr>
    <td style="text-align:center;">
        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:100%;">
            <tbody>
                <tr>
                    <td style="text-align:right; width:49%;">
                        <a href="[LINK_1]" target="_blank"><img align="right" alt="[BTN_1_TEXT]" border="0" height="50" src="[BUTTON_1_IMG]" style="height:50px; display:block; margin:auto; width:[W1]px; float:right;" width="[W1]"></a>
                    </td>
                    <td style="width:20px;">&nbsp;&nbsp;&nbsp;</td>
                    <td style="text-align:left; width:49%;">
                        <a href="[LINK_2]" target="_blank"><img align="left" alt="[BTN_2_TEXT]" border="0" height="50" src="[BUTTON_2_IMG]" style="height:50px; display:block; margin:auto; width:[W2]px; float:left;" width="[W2]"></a>
                    </td>
                </tr>
            </tbody>
        </table>
    </td>
</tr>
```

### Single centred CTA button
```html
<tr>
    <td style="text-align: center;"><a href="[LINK]" target="_blank"><img alt="" border="0" height="60" src="[BUTTON_IMG]" style="width: 168px; height: 60px; margin: auto;" width="168"></a></td>
</tr>
```

### Two-column alternating image/text rows

Some sections use a **repeating 2-column layout** where each feature/product gets its own row with an image on one side and text on the other — alternating left/right between rows. This is common in tips and feature sections.

**How to identify it in the design:**
- Multiple rows, each with a screenshot/photo AND a text description side by side
- Row 1: image left, text right
- Row 2: text left, image right
- Row 3: image left, text right (and so on)
- Each row is visually separate with spacing between them

**Critical:** Do NOT group all the images together in one row and all the text in another. Each image and its corresponding text belong together in the same `<tr>`.

**Pattern — image left, text right:**
```html
<tr>
    <td style="width:50%; vertical-align:middle; padding:10px;">
        <img alt="[ALT]" border="0" height="[H]" src="[IMAGE]" style="display:block; width:[W]px; height:[H]px;" width="[W]">
    </td>
    <td style="width:50%; vertical-align:middle; padding:10px 20px 10px 10px; text-align:left;">
        <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">
            [TEXT WITH &lt;br&gt; LINE BREAKS AND <strong>bold keywords</strong>]
        </span>
    </td>
</tr>
```

**Pattern — text left, image right (alternating row):**
```html
<tr>
    <td style="width:50%; vertical-align:middle; padding:10px 10px 10px 20px; text-align:left;">
        <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">
            [TEXT WITH &lt;br&gt; LINE BREAKS AND <strong>bold keywords</strong>]
        </span>
    </td>
    <td style="width:50%; vertical-align:middle; padding:10px;">
        <img alt="[ALT]" border="0" height="[H]" src="[IMAGE]" style="display:block; width:[W]px; height:[H]px;" width="[W]">
    </td>
</tr>
```

**Full section wrapper with 3 alternating rows:**
```html
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <!-- Row 1: image left, text right -->
                        <tr>
                            <td style="width:50%; vertical-align:middle; padding:10px;">
                                <img alt="[ALT 1]" border="0" height="[H]" src="[IMAGE_1]" style="display:block; width:[W]px; height:[H]px;" width="[W]">
                            </td>
                            <td style="width:50%; vertical-align:middle; padding:10px; text-align:left;">
                                <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">[TEXT 1 with <strong>bold</strong>]</span>
                            </td>
                        </tr>
                        <tr><td colspan="2" height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- Row 2: text left, image right -->
                        <tr>
                            <td style="width:50%; vertical-align:middle; padding:10px; text-align:left;">
                                <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">[TEXT 2 with <strong>bold</strong>]</span>
                            </td>
                            <td style="width:50%; vertical-align:middle; padding:10px;">
                                <img alt="[ALT 2]" border="0" height="[H]" src="[IMAGE_2]" style="display:block; width:[W]px; height:[H]px;" width="[W]">
                            </td>
                        </tr>
                        <tr><td colspan="2" height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <!-- Row 3: image left, text right -->
                        <tr>
                            <td style="width:50%; vertical-align:middle; padding:10px;">
                                <img alt="[ALT 3]" border="0" height="[H]" src="[IMAGE_3]" style="display:block; width:[W]px; height:[H]px;" width="[W]">
                            </td>
                            <td style="width:50%; vertical-align:middle; padding:10px; text-align:left;">
                                <span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:16px; color:#000000;">[TEXT 3 with <strong>bold</strong>]</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <!-- CTA button below the alternating rows -->
        <tr>
            <td style="text-align:center; padding-bottom:30px;">
                <a href="[LINK]" target="_blank"><img alt="[BUTTON TEXT]" border="0" height="50" src="[BUTTON_IMG]" style="display:block; margin:auto; width:[W]px; height:50px;" width="[W]"></a>
            </td>
        </tr>
    </tbody>
</table>
```

**Key rules:**
- Each image+text pair is ONE `<tr>` — never split them across separate rows
- Alternate the image/text sides row by row as shown in the design
- Add a spacer `<tr>` between each feature row (~15px)
- Text can contain `<strong>` for bold keywords — read from the design
- The CTA button sits below all the feature rows, centred, using the correct button image for that section

---

### Three-column icon grid (features / steps)
                    <td align="center" style="width:33%"><img alt="" height="55" src="[ICON_3]" style="width: 54px; height: 55px; margin: auto;" width="54"></td>
                </tr>
                <tr>
                    <td align="center"><span style="font-size:12px;"><strong><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">[LABEL_1]</span></span></strong></span></td>
                    <td align="center"><span style="font-size:12px;"><strong><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">[LABEL_2]</span></span></strong></span></td>
                    <td align="center"><span style="font-size:12px;"><strong><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">[LABEL_3]</span></span></strong></span></td>
                </tr>
                <tr>
                    <td align="center" style="vertical-align: top;"><span style="font-size:12px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">[BODY_1]</span></span></span></td>
                    <td align="center" style="vertical-align: top;"><span style="font-size:12px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">[BODY_2]</span></span></span></td>
                    <td align="center" style="vertical-align: top;"><span style="font-size:12px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">[BODY_3]</span></span></span></td>
                </tr>
            </tbody>
        </table>
    </td>
</tr>
```

---

## Fixed: Footer (always identical — copy exactly)

The footer is the same on every Samsung SA mailer. Social icon URLs, link URLs, and legal text are all fixed. The only things that change are the T&C body text (which can have campaign-specific additions) and the unsubscribe URL (which uses Adobe Campaign dynamic tags, always left as-is).

```html
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color: #ffffff;" width="600">
                            <tbody>
                                <tr style="background-color:#ffffff;">
                                    <td style="text-align:center;padding: 40px 0; background-color:#ffffff;">
                                        <table align="center" bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="100%">
                                            <tbody>
                                                <tr>
                                                    <td width="192"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://www.facebook.com/SamsungSouthAfrica" style="display:inline-block;" target="_blank"><img alt="Facebook" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_137.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="53"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://www.instagram.com/samsungsa/" style="display:inline-block;" target="_blank"><img alt="Instagram" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_138.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="53"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://twitter.com/SamsungSA" style="display:inline-block;" target="_blank"><img alt="X" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_139.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="53"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://www.youtube.com/user/samsungblog" style="display:inline-block;" target="_blank"><img alt="Youtube" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_140.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="53"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://www.linkedin.com/company/samsung-south-africa?trk=company_logo" style="display:inline-block;" target="_blank"><img alt="LinkedIn" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_141.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="53"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://www.samsung.com/za/apps/samsung-wallet/" style="display:inline-block;" target="_blank"><img alt="Samsung Wallet" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_143.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="53"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://www.samsung.com/za/apps/samsung-members/" style="display:inline-block;" target="_blank"><img alt="Samsung Members" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_142.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="53"></td>
                                                    <td align="center" style="text-align: center" width="53"><a href="https://www.samsung.com/za/offer/samsung-care-plus/" style="display:inline-block;" target="_blank"><img alt="Samsung Care Plus" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_144.png" style="width: 48px; height: 48px; display: block; border: 0px solid;" width="48"> </a></td>
                                                    <td width="193"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr style="background-color:#fff;">
                                    <td style="-webkit-hyphens:none;color:#939598;font-family:arial,sans-serif;font-weight:400;hyphens:none;font-size:12px;line-height:1.3;text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#fff;" width="100%">
                                            <tbody>
                                                <tr>
                                                    <td style="line-height: 18px; text-align: center;" valign="top">&nbsp; &nbsp;<br>&nbsp; &nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td align="center" height="16" style="-webkit-hyphens:none;color:#939598;font-family:arial,sans-serif;font-weight:400;hyphens:none;text-align:center;vertical-align:top;" width="600"><span style="font-size:16px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><strong><a _label="999_fold4flip4_footer_privacy" class="linkleft" href="https://www.samsung.com/za/info/legal/" style="display:inline-block;-webkit-hyphens:none;color:#808285;text-align:right;text-decoration:none;vertical-align:top;" target="_blank"><span style="color:#000000;">Legal</span></a></strong><span style="color:#000000;"> &nbsp;&nbsp;<strong>|</strong>&nbsp;&nbsp; </span><strong><a _label="999_fold4flip4_footer_legal" class="linkright" href="https://www.samsung.com/za/info/privacy/" style="display:inline-block;-webkit-hyphens:none;color:#808285;text-align:left;text-decoration:none;vertical-align:top;" target="_blank"><span style="color:#000000;"> Privacy Policy </span></a></strong></span></span><br>&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr style="background-color:#fff;">
                                    <td align="center" valign="top"></td>
                                </tr>
                                <!--olhide start-->
                                <tr style="background-color:#fff;">
                                    <td style="-webkit-hyphens:none;color:#939598;font-family:Samsung Sharp Sans, avant garde,avantgarde,arial,sans-serif;font-weight:400;hyphens:none;font-size:12px;line-height:1.3;text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">
                                            <tbody>
                                                <tr>
                                                    <td align="center" class="btmLink" style="-webkit-hyphens:none;padding:15px;color:#808285;font-family:Samsung Sharp Sans, avant garde,avantgarde,arial,sans-serif;font-weight:400;hyphens:none;text-align:center;vertical-align:top;font-size:13px;" valign="top"><span style="font-size:13px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;">Terms and Conditions apply. Offer valid whilst stocks last. E&amp;OE.<br>
We cannot be held liable for any misrepresentation caused by unintentional copy errors, typing errors, and/or omissions that may occur in any of our materials.<br>
&nbsp; &nbsp;<br>
This email has been sent to members who have requested to join the mailing list.<br>
To unsubscribe from receiving promotional and marketing information,<br>
click to&nbsp;<a _type="optout" data-sap-hpa-ceimo-link-type="EasyUnsubscribe" href="YYYYY" rel="noopener noreferrer" style="color: #696969;" target="_blank" title="Unsubscribe">Unsubscribe</a></span></span><span style="color:#000000;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">.</span></span></span></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr style="background-color:#fff;">
                                    <td align="center" valign="top">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0">
                                            <tbody>
                                                <tr>
                                                    <td height="30" style="font-size:1px;line-height:1px;"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <!--olhide end-->
                                <tr style="background-color:#fff;">
                                    <td style="-webkit-hyphens:none;color:#939598;font-family:Samsung Sharp Sans, avant garde,avantgarde,arial,sans-serif;font-weight:400;hyphens:none;font-size:12px;line-height:1.3;text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="100%">
                                            <tbody>
                                                <tr>
                                                    <td align="center" class="btmLink" style="-webkit-hyphens:none;color:#808285;font-family:Samsung Sharp Sans, avant garde,avantgarde,arial,sans-serif;font-weight:400;hyphens:none;text-align:center;vertical-align:top;font-size:13px;" valign="top"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#000000;"><span style="font-size:13px;">© Copyright 2017-2026 Samsung Electronics. All Rights Reserved.<br>
* Do not reply. This email address is for outgoing emails only.</span></span></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr style="background-color:#fff;">
                                    <td align="center" valign="top">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0">
                                            <tbody>
                                                <tr>
                                                    <td height="30" style="font-size:1px;line-height:1px;"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
```

---

---

## Email Client Compatibility — Critical Rules

This HTML is for **email clients**, not browsers. This is the single most important thing to keep in mind. Email clients — especially Outlook (which uses Microsoft Word's rendering engine, not a browser engine), but also Gmail, Apple Mail, Yahoo Mail, and mobile clients — have severe CSS and HTML limitations that don't exist on the web. Every decision you make must account for this.

### Layout: Tables, not divs

Always use `<table>` elements for layout. Avoid `<div>`, `<section>`, `<article>`, and other semantic HTML elements for structural layout — Outlook in particular renders these poorly or ignores them entirely. The Samsung SA mailers already follow this pattern, and you must maintain it.

- Every layout column, every spacing block, every structural element = a `<table>` or `<td>`
- Use `cellpadding="0" cellspacing="0" border="0"` on all layout tables
- Use explicit `width` attributes on `<td>` elements (not just CSS `width:`) — Outlook respects the HTML attribute more reliably

### CSS: Inline only

All CSS must be **inline** on each element. Do not use `<style>` blocks in `<head>` — Gmail strips them. Do not reference external stylesheets. Every style property must be on the element it affects:

```html
<td style="font-size: 16px; color: #000000; text-align: center;">
```

### No border-radius

`border-radius` does not work in Outlook at all. If the design has rounded corners on buttons, image frames, or containers, these must be achieved using **images** — a pre-cut image with the rounded corners baked in, not CSS. The Samsung mailers already do this for CTA buttons (they are image files, not styled `<a>` tags). Keep this approach for any rounded element.

### No CSS positioning

Avoid `position: absolute`, `position: relative`, `float`, `flexbox`, and `CSS grid` entirely. These are unreliable or broken in most email clients. Use table cells for positioning.

### No negative margins

Negative margins are not supported in most email clients. Use `cellpadding`, `cellspacing`, or spacer rows/columns instead.

### Background images

CSS `background-image` is not supported in Outlook. If a section has a background image:
- Use a solid background colour as a fallback (`background-color` on the `<td>`)
- If the background image is essential to the design, it must be a foreground `<img>` element instead
- For Outlook-specific background image support you would need VML (complex — avoid unless necessary)

### Font rendering

- Samsung Sharp Sans is a custom font that will **not** render in most email clients — this is expected and fine. The font stack fallbacks (century gothic, avant garde, etc.) are there for exactly this reason, and the email will still look correct.
- Web fonts via `@font-face` or Google Fonts links do **not** work reliably in email clients — do not add them.
- `font-size` should always be specified in `px`, never `em` or `rem`.
- Always specify `line-height` explicitly on text cells — email clients have inconsistent default line-heights.

### Image handling

- Images must have explicit `width` and `height` as both HTML attributes and inline style — Outlook uses the HTML attribute, other clients use the CSS.
- Always add `display: block` on images to prevent the 1–4px gap that appears beneath images in some clients (caused by inline baseline alignment).
- Always add `border="0"` on linked images (`<a><img ...></a>`) to prevent Outlook from adding a blue border.
- Email clients often **block images by default**. Always write meaningful `alt` text, especially on hero images and CTAs, so the email is readable even with images off.
- GIF animations work in most clients **except Outlook**, which only shows the first frame. If a GIF is used (like the Samsung L2 hero), design it so the first frame makes sense on its own.

### Spacing

Use `<br>` tags and `&nbsp;` characters for spacing within cells, and empty `<tr>` rows with explicit heights for spacing between sections. Avoid `padding` on `<td>` for critical spacing — it's unreliable in some versions of Outlook. Using spacer rows is safer:

```html
<tr>
    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
</tr>
```

### No JavaScript, no forms, no video

Email clients do not execute JavaScript. Do not include any `<script>` tags, `onclick` handlers, or form elements. `<video>` is not supported either — use a linked image with a play button icon instead.

### Dark mode

Some email clients (particularly Apple Mail on macOS/iOS) have a dark mode that can invert or adjust colours. The Samsung mailers are generally dark-coloured enough that this is less of an issue, but be aware that white text on a dark background can sometimes become invisible if a client force-inverts colours.

### Outlook conditional comments

For cases where Outlook needs special treatment (e.g. setting a minimum height, or hiding something from Outlook), you can use conditional HTML comments:

```html
<!--[if mso]>
  <table width="600"><tr><td>Outlook-only content here</td></tr></table>
<![endif]-->
<!--[if !mso]><!-- -->
  Non-Outlook content here
<!--<![endif]-->
```

The existing Samsung mailer boilerplate already uses `mso-hide: all` on the preheader span — preserve this. You can add `mso-hide: all` to other elements you want hidden from Outlook.

---

## Output

1. **Create an output folder** named after the job reference, in the same directory as the input JPGs: e.g. `ZAS26088076_output/`
2. **Copy all cut-up image files** into this folder (flat — no subfolders), **sanitizing filenames** (remove special chars like `@`, replace spaces with `_`)
3. **Save the HTML file** inside the same output folder, named to match the JPG: e.g. `ZAS26088076_SA.html`
4. **All image `src` paths** in the HTML should be just the **sanitized** filename (relative) — no CDN URL, no full path, no special characters
5. **Create a zip file** for that completed folder, naming it exactly the same as the HTML file but without the `.html` extension
6. After saving and zipping, **tell Danny**:
    - What the output folder is called
    - What the zip file is called
    - Any sections where images were missing (placeholder comments left in HTML)
    - Any text that was unclear or ambiguous in the JPG
    - The folder and zip are ready to import into Everlytic

## Quality checks before saving

- All `<table>` tags properly opened and closed
- All images have explicit `width` and `height` as both HTML attributes and inline style
- All images have `display: block` in their style
- All linked images have `border="0"`
- Image `src` values are **sanitized** relative filenames only — no spaces, no `@`, no special chars (no CDN URLs for content images)
- Footer social icons still use full CDN URLs (they stay on the CDN)
- No text accidentally left out from any section of the JPG
- Footer HTML is complete and unmodified
- Preheader text is set and matches the email's main message
- **Body background colour** is `#555555` unless the JPG canvas clearly shows otherwise — never use `#dddddd`
- **Section gap / outer wrapper colour** was read from the JPG — not defaulted to `#3B3B4A`
- **Content card background colour** was read from the JPG — not defaulted to `#ffffff`
- **2-column alternating rows** — when the design shows image+text pairs stacked vertically and alternating sides, each pair is ONE `<tr>` with 2 `<td>`s. Never group all images together and all text separately
- **Blank Rectangle images discarded** — `Rectangle_xxx.png` files that are just plain coloured backgrounds are never used; full HTML card built instead
- **Spacing matches the design** — generous top/bottom padding inside cards, visible gaps between elements (20–30px spacer rows). Do not compress elements together
- **Text line breaks use `<br>` tags** — multi-line text blocks match the line-break positions in the JPG exactly; do not let text reflow freely
- **Font sizes** are 48px for major headlines, 20px for body copy — not 42px / 16px
- **Decorative frame cards** use the sliced-border table technique — if only a single unsliced frame image is in the cut-ups, stop and ask Danny to slice it
- **Zip created** — each completed output folder also contains one `.zip` file named exactly after the HTML file (without `.html`), and that archive contains the folder's HTML + image files only
- **GIF sections and missing images** use a blank `placeholder.png` at the correct dimensions — never omitted, never a CSS workaround
- **Footer file for SA** uses `footer_ssa.txt` — there is no `footer_sa.txt`
- **All images use the 1x (standard) version** — never @2x. File sizes over 600KB are unacceptable in email
- **Duplicate button variants** — one button image is picked and reused consistently throughout; numbered variants (Group 2479, 2480, 2481 etc.) are interchangeable
- **ZZZZZ and YYYYY** are in place — never the actual Adobe Campaign `<%@ ... %>` syntax
- **Font sizes** match the visual weight of text in the main design image — not hardcoded to a single value
- **Each distinct visual block** in the JPG is a separate `<table>` — except contiguous same-background opening blocks which share the mailcont table
- No `border-radius`, `float`, `position`, `flexbox`, or `grid` CSS used (note: `float` on left/right border strip images in the sliced-border technique is acceptable)
- **Lifestyle/CRM section structure** — if the email uses the repeating product section pattern: section header (`#746D63`) → 534px banner → `#EDEAE3` pricing area → "Key features at a glance:" → feature PNG → CTA button. Sharp corners throughout — no sliced-frame technique
- **534px banners** — use the 1x image file (over 520px threshold, do NOT use @2x)
- **Pricing block count** — matches the JPG per section (4, 2, or 1). Single-block sections use a wider version of the same 3-row template
- **1200px source JPG** — all image display dimensions halved; email still renders at 600px; always use 1x cut-up images
