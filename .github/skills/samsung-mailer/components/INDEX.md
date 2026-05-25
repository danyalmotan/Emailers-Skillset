# Samsung Mailer Component Library

All components extracted from production HTML. Replace `[PLACEHOLDER]` markers with real content. All style attributes are preserved exactly as-is from source files.

---

## Components

| File | Description | When to use |
|------|-------------|-------------|
| `kv-hero.html` | KV / hero opening section | **Variant A**: Full-width logo strip + hero image (Miracle Launch, CE). **Variant B**: Logo strip + black background GIF hero with headline (Micro RGB). **Variant C**: Sliced border-frame offer card on campaign-colour background (pre-order / double storage). |
| `pricing-block-120px.html` | 120px pricing block — black header / Now price / Save row | 4-across CE layouts (Lifestyle TV, washing machines, fridges). Danny's template. Drop 4 of these inside `pricing-row-wrapper.html`. |
| `pricing-block-180px.html` | 180px pricing block — two variants | **Variant A**: Brandstore outright purchase (model number + Now + Save + buy button image). **Variant B**: Carrier/contract (storage badge + purple plan name + once-off + PM x 36). Use in `three-pod-carrier.html`. |
| `pricing-row-wrapper.html` | #EDEAE3 outer wrapper for a row of 4× 120px pricing blocks | CE / Lifestyle TV mailers. Wrap after a `section-header-colored.html` label. Includes 5px gap columns and 10px top/bottom spacers. |
| `section-header-colored.html` | Coloured section heading table — 4 variants | **A**: #746D63 warm grey label (CE category headers). **B**: Black banner heading (launch / offer callouts). **C**: Blue image label strip (#0C4CA3, Blue Tag Sale). **D**: Full-width campaign-colour headline block (S26 purple, dark navy, Buds lavender). |
| `banner-534px.html` | Centred 534px or 520px banner inside 600px container | Feature images that need side breathing room. 33px spacers each side for 534px; 40px each side for 520px (sliced-border-frame inner width). |
| `banner-600px.html` | Full-width 600px linked or non-linked banner row | Full-bleed product photography, GIF animations, decorative divider strips. Three variants: linked image, non-linked image, linked GIF. |
| `cta-button-single.html` | Single centred CTA button row | Any section needing one call-to-action. **Variant A**: plain centred. **Variant B**: with br spacers above/below. **Variant C**: with copy text above button. |
| `cta-button-pair.html` | Two CTA buttons side by side | **Variant A**: 49%/spacer/49% float layout (Buy now + Compare). **Variant B**: Two 300px half-column image buttons. **Variant C**: Fixed 250px/30px gap layout (Shop online + Find a store). |
| `feature-icons-3col.html` | Icon + label + sub-copy feature grid | **Variant A**: Horizontal 4-icon bar with dividers on purple background (S26 feature strip below hero). **Variant B**: Vertical stacked icon rows with divider lines inside a 180px purple card (right column of three-pod-carrier rows). |
| `three-pod-carrier.html` | Three stacked handset rows — pricing LEFT, phone image CENTRE, features card RIGHT | Carrier / channel mailers (FNB, MTN, Vodacom). One outer table per handset. Columns: 15 + 185 + 205 + 180 + 15 = 600px. Swap Variant B pricing block for Variant A (brandstore) when no carrier plan is needed. |
| `three-column-spec-compare.html` | Two live-text spec columns flanking a centre handset image | Upgrade / comparison mailers where the left and right columns are HTML text and colour swatches, with one tall centre cutup image and an optional CTA below. |
| `sliced-border-frame.html` | Decorative frame with top/bottom corner image strips | Pre-order / offer callout cards floating inside a campaign-colour background. Uses `rgtfdss-0001.png` (top) and `rgtfdss-0002.png` (bottom) from CDN. Inner content area is always white (#fff). |
| `channel-featured-offer-card.html` | White rounded featured channel offer card with live pricing table, promo bolt-on strip and CTA | Vodacom / carrier deal highlights where one handset image sits left, a compact pricing table sits right, and the bottom row carries an add-on strip plus a buy button. |
| `why-samsung-card-518px.html` | 518px rounded Samsung content card with sliced top/bottom cap images | Why Samsung / Vision AI feature blocks that use local `card_top` + `card_bottom` assets and a #F4F4F4 middle row for live text and one 518px image. |
| `key-features-label.html` | Label / subheading text rows — 3 variants | **Variant A**: "Key features at a glance:" on #EDEAE3 — above a pricing-row-wrapper. **Variant B**: Section subheading + feature name + body copy on dark background (CE feature sections). **Variant C**: "Deals valid [date range]" centred text above a CTA button. |
| `partner-footer-white.html` | White footer with offer-valid row, partner lockup, social icons, legal links and unsubscribe copy | Channel / partner mailers that keep Samsung social/legal links but add a partner logo above the footer. Replace the unsubscribe href with `YYYYY` in output HTML. |
| `spacer-row.html` | Spacer rows: 10px, 20px, 30px + inline br variants | Use standalone `<table>` spacers between major sections; use inline `<tr><td>` br variants for breathing room inside an existing table cell. |
| `three-pod-tv-cards-156px.html` | Three 156px product pods in a 518px row with image, live copy and button image CTA | TV comparison / category rows with 156px top cutups, live-text headings, short benefit copy and pill CTA image buttons. |

---

## Common CDN Assets (reusable across mailers)

| Asset | URL | Usage |
|-------|-----|-------|
| Top frame corner strip | `https://cdn19.mailercdn.net/users/assets/379/images/rgtfdss-0001.png` | Top of sliced-border-frame |
| Bottom frame corner strip | `https://cdn19.mailercdn.net/users/assets/379/images/rgtfdss-0002.png` | Bottom of sliced-border-frame |
| Vertical divider line | `https://cdn19.mailercdn.net/users/assets/379/images/line_22.png` | Between icons in horizontal feature bar |
| Horizontal divider line | `https://cdn19.mailercdn.net/users/assets/379/images/line_28.png` | Between rows in vertical feature card |
| 512GB storage badge | `https://cdn19.mailercdn.net/users/assets/379/images/group_2574-402x.png` | Storage badge in 180px pricing block header |
| Facebook icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_137.png` | Footer social row |
| Instagram icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_138.png` | Footer social row |
| X (Twitter) icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_139.png` | Footer social row |
| YouTube icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_140.png` | Footer social row |
| LinkedIn icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_141.png` | Footer social row |
| Samsung Wallet icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_143.png` | Footer social row |
| Samsung Members icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_142.png` | Footer social row |
| Samsung Care+ icon | `https://cdn19.mailercdn.net/users/assets/379/images/group_144.png` | Footer social row |

---

## Samsung Sharp Sans font stack

All text spans must use this exact font-family value:

```
Samsung Sharp Sans, avant garde, avantgarde, century gothic, centurygothic, applegothic, sans-serif
```

---

## Standard font sizes

| Use | Size |
|-----|------|
| Hero headline | 48px |
| Section headline | 36px |
| Sub-headline | 28px |
| Feature name / plan name | 20px or 18px |
| Body copy | 14–15px |
| Pricing (large) | 24px |
| Pricing (small block) | 20px |
| Model number / small label | 10–11px |
| Legal / disclaimer | 8–9px |
| Footer legal | 13px |
