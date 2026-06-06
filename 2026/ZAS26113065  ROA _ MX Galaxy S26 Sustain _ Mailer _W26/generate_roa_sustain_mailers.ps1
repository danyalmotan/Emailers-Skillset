$ErrorActionPreference = 'Stop'

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

$jobRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113065  ROA _ MX Galaxy S26 Sustain _ Mailer _W26'
$sourceHtml = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26088169  2026_SSA Retainer_Digital_CRM MX_Galaxy S26_Sustain_Mailer + Banner _ W23\Published\SA_ZAS26088169_Galaxy_S26_Sustain_Mailer_W23\SA_ZAS26088169_Galaxy_S26_Sustain_Mailer_W23.html'
$assetsRoot = Join-Path $jobRoot 'ZAS26088169 _ 2026_SSA Retainer_Digital_CRM MX_Galaxy S26_Sustain_Mailer _ W23_Assets'
$publishedRoot = Join-Path $jobRoot 'Published'
$footerRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\footers'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$productLink = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26/'

$regions = @(
    @{ Code = 'GH'; Country = 'Ghana'; Footer = 'footer_gh.txt'; BaseName = 'GH_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26' },
    @{ Code = 'NG'; Country = 'Nigeria'; Footer = 'footer_ng.txt'; BaseName = 'NG_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26' },
    @{ Code = 'KE'; Country = 'Kenya'; Footer = 'footer_ke.txt'; BaseName = 'KE_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26' },
    @{ Code = 'TZ'; Country = 'Tanzania'; Footer = 'footer_tz.txt'; BaseName = 'TZ_ZAS26113065_Galaxy_S26_Sustain_Mailer_W26' }
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
                    <a href="$productLink"
                      target="_blank"><img alt="Learn more"
                        src="Group 1.png" style="display:block;
                        width:180px; height:58px; margin:auto;"
                        width="180" height="58" border="0"></a>
"@

$removeExclusiveSectionBlock = @'
                <tr>
                  <td style="font-size:1px; line-height:1px;"
                    height="34">&nbsp;</td>
                </tr>
              </tbody>
            </table>
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

$source = [regex]::Replace($source, 'https://www\.samsung\.com/za/smartphones/galaxy-s26(?:/buy)?/', $productLink)

foreach ($region in $regions) {
    $content = $source.Replace('<title>Samsung South Africa</title>', "<title>Samsung $($region.Country)</title>")

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
    [System.IO.File]::WriteAllText($htmlPath, $content, $utf8NoBom)
}