$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Replace-Once {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Replacement,
        [string]$Label
    )

    $regex = [regex]::new($Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $matches = $regex.Matches($Text)
    if ($matches.Count -ne 1) {
        throw "Expected 1 match for $Label, found $($matches.Count)."
    }

    return $regex.Replace($Text, $Replacement, 1)
}

function Replace-AllExact {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Replacement,
        [int]$ExpectedCount,
        [string]$Label
    )

    $regex = [regex]::new($Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $matches = $regex.Matches($Text)
    if ($matches.Count -ne $ExpectedCount) {
        throw "Expected $ExpectedCount matches for $Label, found $($matches.Count)."
    }

    return $regex.Replace($Text, $Replacement)
}

  function Write-Utf8NoBom {
    param(
      [string]$Path,
      [string]$Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
  }

$jobRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113065  ROA _ MX Galaxy S26 Sustain _ Mailer _W26'
$sourceHtml = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26088169  2026_SSA Retainer_Digital_CRM MX_Galaxy S26_Sustain_Mailer + Banner _ W23\Published\SA_ZAS26088169_Galaxy_S26_Sustain_Mailer_W23\SA_ZAS26088169_Galaxy_S26_Sustain_Mailer_W23.html'
$assetsRoot = Join-Path $jobRoot 'ZAS26088169 _ 2026_SSA Retainer_Digital_CRM MX_Galaxy S26_Sustain_Mailer _ W23_Assets'
$publishedRoot = Join-Path $jobRoot 'Published'
$footerRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\footers'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$productLinkPlaceholder = '__PRODUCT_LINK__'

$regions = @(
  @{ Code = 'GH'; Country = 'Ghana'; Footer = 'footer_gh.txt'; BaseName = 'GH_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26'; Language = 'en'; ProductLink = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26/' },
  @{ Code = 'NG'; Country = 'Nigeria'; Footer = 'footer_ng.txt'; BaseName = 'NG_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26'; Language = 'en'; ProductLink = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26/' },
  @{ Code = 'KE'; Country = 'Kenya'; Footer = 'footer_ke.txt'; BaseName = 'KE_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26'; Language = 'en'; ProductLink = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26/' },
  @{ Code = 'TZ'; Country = 'Tanzania'; Footer = 'footer_tz.txt'; BaseName = 'TZ_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26'; Language = 'en'; ProductLink = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26/' },
  @{ Code = 'SN'; Country = 'Senegal'; Footer = 'footer_sn.txt'; BaseName = 'SN_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26'; Language = 'fr'; ProductLink = 'https://www.samsung.com/africa_fr/smartphones/galaxy-s26/' },
  @{ Code = 'CIV'; Country = 'C&ocirc;te d''Ivoire'; Footer = 'footer_ci.txt'; BaseName = 'CIV_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26'; Language = 'fr'; ProductLink = 'https://www.samsung.com/africa_fr/smartphones/galaxy-s26/' }
)

$heroQuoteBlock = @'
                <tr>
                  <td style="padding:14px 44px 0 44px; text-align:left;">
                    <table width="512" cellspacing="0" cellpadding="0"
                      border="0" align="center"
                      style="border:1px solid #ffffff; width:512px;">
                      <tbody>
                        <tr>
                          <td style="width:170px; text-align:center; padding:20px 0;"
                            valign="middle"><img alt="BGR Best of 2026"
                              src="Image 3.png" style="display:block;
                              width:110px; height:88px; margin:auto;"
                              width="110" height="88" border="0"></td>
                          <td style="padding:20px 24px 20px 0;"
                            valign="middle"><span style="font-size:25px;
                              line-height:31px;"><strong><span
                                  style="font-family:Samsung Sharp Sans,
                                  avant garde,avantgarde,century
                                  gothic,centurygothic,applegothic,sans-serif;
                                  color:#ffffff;">&quot;...outstanding cameras,<br>
                                  gorgeous displays and solid<br>
                                  battery life.&quot;</span></strong></span><br>
                              <br>
                              <span style="font-size:16px; line-height:20px;"><span
                                  style="font-family:Samsung Sharp Sans,
                                  avant garde,avantgarde,century
                                  gothic,centurygothic,applegothic,sans-serif;
                                  color:#b7bac8;">BGR, 03/2026</span></span></td>
                        </tr>
                      </tbody>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td style="font-size:1px; line-height:1px;"
                    height="30">&nbsp;</td>
                </tr>
'@

$singleLearnMoreBlock = @"
                    <a href="$productLinkPlaceholder"
                      target="_blank"><img alt="Learn more"
                        src="Group 1.png" style="display:block;
                        width:180px; height:58px; margin:auto;"
                        width="180" height="58" border="0"></a>
"@

$singleLearnMoreBlockFr = @"
                    <a href="$productLinkPlaceholder"
                      target="_blank" style="display:inline-block;
                      text-decoration:none;">
                      <table align="center" border="0" cellpadding="0"
                        cellspacing="0"
                        style="background-color:#ffffff;
                        border-radius:29px;" width="180">
                        <tbody>
                          <tr>
                            <td height="58" style="text-align:center;">
                              <span style="font-size:18px;
                                line-height:22px;"><strong><span
                                    style="font-family:Samsung Sharp Sans,
                                    avant garde,avantgarde,century
                                    gothic,centurygothic,applegothic,sans-serif;
                                    color:#000000;">En savoir plus</span></strong></span></td>
                          </tr>
                        </tbody>
                      </table>
                    </a>
"@

$removeExclusiveSectionBlock = @'
                <tr>
                  <td style="font-size:1px; line-height:1px;"
                    height="34">&nbsp;</td>
                </tr>
              </tbody>
            </table>
'@

$heroQuoteBlockFr = @'
                <tr>
                  <td style="padding:14px 44px 0 44px; text-align:left;">
                    <table width="512" cellspacing="0" cellpadding="0"
                      border="0" align="center"
                      style="border:1px solid #ffffff; width:512px;">
                      <tbody>
                        <tr>
                          <td style="width:170px; text-align:center; padding:20px 0;"
                            valign="middle"><img alt="BGR Best of 2026"
                              src="Image 3.png" style="display:block;
                              width:110px; height:88px; margin:auto;"
                              width="110" height="88" border="0"></td>
                          <td style="padding:20px 24px 20px 0;"
                            valign="middle"><span style="font-size:25px;
                              line-height:31px;"><strong><span
                                  style="font-family:Samsung Sharp Sans,
                                  avant garde,avantgarde,century
                                  gothic,centurygothic,applegothic,sans-serif;
                                  color:#ffffff;">&quot;... des appareils photo<br>
                                  remarquables, des &eacute;crans<br>
                                  magnifiques et une autonomie<br>
                                  remarquable.&quot;</span></strong></span><br>
                              <br>
                              <span style="font-size:16px; line-height:20px;"><span
                                  style="font-family:Samsung Sharp Sans,
                                  avant garde,avantgarde,century
                                  gothic,centurygothic,applegothic,sans-serif;
                                  color:#b7bac8;">BGR, 02/2026</span></span></td>
                        </tr>
                      </tbody>
                    </table>
                  </td>
                </tr>
                <tr>
                  <td style="font-size:1px; line-height:1px;"
                    height="30">&nbsp;</td>
                </tr>
'@

$mainAssetFiles = Get-ChildItem -Path $assetsRoot -Recurse -File | Where-Object {
    $_.Name -notmatch '@2x' -and $_.Name -ne '.DS_Store'
}

$source = [System.IO.File]::ReadAllText($sourceHtml, [System.Text.Encoding]::UTF8)

$source = Replace-Once -Text $source -Pattern '<span style="color:#000000;"><% if .*? %></span>' -Replacement '<span style="color:#000000;">ZZZZZ</span>' -Label 'mirror placeholder'

$source = Replace-Once -Text $source -Pattern '<tr>\s*<td style="padding:14px 36px 0 36px; text-align:left;">.*?<tr>\s*<td style="font-size:1px; line-height:1px;"\s*height="24">&nbsp;</td>\s*</tr>' -Replacement $heroQuoteBlock -Label 'hero quote block'

$source = Replace-Once -Text $source -Pattern '<table width="100%" cellspacing="0" cellpadding="0"\s*border="0" align="center">\s*<tbody>\s*<tr>\s*<td style="text-align:right; width:49%;"><a\s*href="https://www\.samsung\.com/za/smartphones/galaxy-s26/"\s*target="_blank"><img alt="Learn more"\s*src="Group 1\.png".*?href="https://www\.samsung\.com/za/smartphones/galaxy-s26/buy/"\s*target="_blank"><img alt="Shop now"\s*src="Group 2\.png".*?</table>' -Replacement $singleLearnMoreBlock -Label 'compact CTA pair'

$source = Replace-AllExact -Text $source -Pattern '<table width="100%" cellspacing="0" cellpadding="0"\s*border="0" align="center">\s*<tbody>\s*<tr>\s*<td style="text-align:right; width:49%;"><a\s*href="https://www\.samsung\.com/za/smartphones/galaxy-s26/"\s*target="_blank"><img alt="Learn more"\s*src="Group 1\.png".*?href="https://www\.samsung\.com/za/smartphones/galaxy-s26/buy/"\s*target="_blank"><img alt="Shop now"\s*src="Group 4\.png".*?</table>' -Replacement $singleLearnMoreBlock -ExpectedCount 2 -Label 'comparison CTA pairs'

$source = Replace-Once -Text $source -Pattern '<tr>\s*<td style="font-size:1px; line-height:1px;"\s*height="34">&nbsp;</td>\s*</tr>\s*<tr>\s*<td style="text-align:center; padding:0 40px;"><span\s*style="font-size:36px; line-height:44px;">.*?Color availability may vary depending on country or carrier\.</span></span></td>\s*</tr>\s*</tbody>\s*</table>' -Replacement $removeExclusiveSectionBlock -Label 'exclusive colours section'

$source = [regex]::Replace($source, 'https://www\.samsung\.com/za/smartphones/galaxy-s26(?:/buy)?/', $productLinkPlaceholder)

foreach ($region in $regions) {
    $content = $source.Replace('<title>Samsung South Africa</title>', "<title>Samsung $($region.Country)</title>")
  $content = $content.Replace($productLinkPlaceholder, $region.ProductLink)

  if ($region.Language -eq 'fr') {
    $currentSingleLearnMoreBlock = $singleLearnMoreBlock.Replace($productLinkPlaceholder, $region.ProductLink)
    $content = $content.Replace($currentSingleLearnMoreBlock, $singleLearnMoreBlockFr.Replace($productLinkPlaceholder, $region.ProductLink))
    $content = [regex]::Replace($content, '<span class="preheader".*?>.*?</span>', '<span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;">Compact. Puissant. Sans compromis.</span>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $content = $content.Replace($heroQuoteBlock, $heroQuoteBlockFr)
    $content = $content.Replace('Outstanding camera,
                generous battery and solid battery life.', 'Des appareils photo remarquables,
                une batterie g&eacute;n&eacute;reuse et une autonomie remarquable.')
    $content = $content.Replace('Compact in size,', 'Compact. Puissant.')
    $content = $content.Replace(' packed with power', 'Sans compromis.')
    $content = $content.Replace('Expand what''s possible with Galaxy S26.
Meet the next-level innovation with
a compact design and powerful battery.<br><br>', 'Repoussez les limites du possible avec le Galaxy S26.
D&eacute;couvrez une innovation de pointe, avec
un design compact et une batterie puissante.<br><br>')
    $content = [regex]::Replace($content, 'Everyday slimness,<br>\s*long-lasting battery', 'Finesse. Autonomie<br>longue dur&eacute;e.')
    $content = [regex]::Replace($content, 'Enjoy refined comfort in a slim\s*design that fits effortlessly in your hand and a\s*battery that keeps your day uninterrupted\.', 'Profitez d''un design fin et &eacute;l&eacute;gant qui tient naturellement en main, avec une batterie con&ccedil;ue pour vous accompagner tout au long de la journ&eacute;e.')
    $content = [regex]::Replace($content, '"Galaxy S26 remains\s*one of the most compact and\s*lightweight ''flagship'' phones\.\.\."', '&quot;Le Galaxy S26 reste l''un des smartphones haut de gamme les plus compacts et l&eacute;gers du march&eacute;.&quot;')
    $content = $content.Replace('Compared with Galaxy S24', 'Compar&eacute; au Galaxy S24')
    $content = [regex]::Replace($content, '\*Actual battery lite va ries by network environment, features and apps used, frequency of calls and messages, the number of times charged, and many othertactors\. Estimated against the average usage profile compiied by UX Connect Resea rch\. ind ependently assessed by UX Connect Research between 2026\.1\.8-2026\.1\.30 in US and Ui\( with pre-release versions of SNI—5942, SM-S924 and SM-S948 under default setting using LTE and 5G Sub6 networks-NOT tested under 5G mm Wave network\.', '*L''autonomie r&eacute;elle de la batterie varie selon l''environnement r&eacute;seau, les fonctionnalit&eacute;s et applications utilis&eacute;es, la fr&eacute;quence des appels et messages, le nombre de recharges ainsi que de nombreux autres facteurs. Estimation &eacute;tablie &agrave; partir du profil d''utilisation moyen compil&eacute; par UX Connect Research. &Eacute;valuation ind&eacute;pendante men&eacute;e par UX Connect Research du 08/01/2026 au 30/01/2026 aux &Eacute;tats-Unis et au Royaume-Uni avec des versions pr&eacute;commerciales du SM-S942, du SM-S924 et du SM-S948 selon les param&egrave;tres par d&eacute;faut sur r&eacute;seaux LTE et 5G Sub6, hors 5G mmWave.')
    $content = [regex]::Replace($content, 'Super Steady Video\.<br>\s*Now even steadier\.', 'Vid&eacute;o Super Stable.<br>Encore plus stable.')
    $content = [regex]::Replace($content, 'Shoot smoother, stabilized\s*videos every time with Super Steady''s new\s*Horizontal Lock feature\.', 'Dites adieu aux vid&eacute;os tremblantes gr&acirc;ce au mode Super Stable, qui maintient vos prises de vue &agrave; l''horizontale.')
    $content = $content.Replace('See how they compare', 'Voyez la diff&eacute;rence')
    $content = $content.Replace('*Super Steady results may vary depending on editing method and/or shooting conditions.', '*Les r&eacute;sultats de Super Stable peuvent varier selon la m&eacute;thode de montage et/ou les conditions de prise de vue.')
    $content = [regex]::Replace($content, 'Your Galaxy S26\.<br>\s*Your style\.', 'Votre singularit&eacute;.<br>Votre Galaxy S26.')
    $content = [regex]::Replace($content, 'Discover the hue of Galaxy S26\s*that feels distinctly yours\. Explore the\s*selection of colors and choose one that defines\s*you\.', 'D&eacute;couvrez le coloris du Galaxy S26 qui vous correspond. Explorez une s&eacute;lection de couleurs originales et choisissez celle qui exprime le mieux votre style.')
    $content = $content.Replace('alt="Learn more"', 'alt="En savoir plus"')
  }

    $footer = [System.IO.File]::ReadAllText((Join-Path $footerRoot $region.Footer), [System.Text.Encoding]::UTF8)
    $footer = $footer.Replace('https://samsung-mena-mkt-prod6-m.adobe-campaign.com/webApp/smgUnsub?id=<%= escapeUrl(recipient.cryptedId) %>&lang=en&unsub=true', 'YYYYY')
    $footer = $footer.Replace('&copy;', '©')
    $footer = $footer.Replace('©', '&copy;')

    $footerStart = $content.LastIndexOf('<table style="background-color: #ffffff;" width="600"')
    if ($footerStart -lt 0) {
        throw 'Could not find footer start in transformed HTML.'
    }

    $content = $content.Substring(0, $footerStart) + $footer

    $outputDir = Join-Path $publishedRoot $region.BaseName
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null

    foreach ($asset in $mainAssetFiles) {
        Copy-Item -Path $asset.FullName -Destination (Join-Path $outputDir $asset.Name) -Force
    }

    $htmlPath = Join-Path $outputDir ($region.BaseName + '.html')
    $rootHtmlPath = Join-Path $publishedRoot ($region.BaseName + '.html')
    $zipPath = Join-Path $outputDir ($region.BaseName + '.zip')

    Write-Utf8NoBom -Path $htmlPath -Content $content

    $rootContent = $content
    foreach ($asset in $mainAssetFiles) {
      $rootContent = $rootContent.Replace('src="' + $asset.Name + '"', 'src="' + $region.BaseName + '/' + $asset.Name + '"')
    }
    Write-Utf8NoBom -Path $rootHtmlPath -Content $rootContent

    if (Test-Path $zipPath) {
      Remove-Item $zipPath -Force
    }

    $filesToZip = Get-ChildItem -Path $outputDir -File | Where-Object { $_.Extension -ne '.zip' }
    $archive = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
      foreach ($file in $filesToZip) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $file.Name, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
      }
    }
    finally {
      $archive.Dispose()
    }
}