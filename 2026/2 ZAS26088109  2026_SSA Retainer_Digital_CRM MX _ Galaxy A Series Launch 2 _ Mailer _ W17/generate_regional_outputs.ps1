$ErrorActionPreference = 'Stop'

$jobPath = 'C:\Users\user\OneDrive\digidanWork\Mailers\2026\2 ZAS26088109  2026_SSA Retainer_Digital_CRM MX _ Galaxy A Series Launch 2 _ Mailer _ W17'
$publishedPath = Join-Path $jobPath 'Published'
$cutupsPath = Join-Path $jobPath 'Cutups'
$footersPath = 'C:\Users\user\OneDrive\digidanWork\Mailers\footers'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$regions = @(
    @{ Suffix = 'GH_ROA'; Code = 'gh'; Title = 'Samsung Ghana'; Language = 'en'; TryGalaxy = $false },
    @{ Suffix = 'KE_SEEA'; Code = 'ke'; Title = 'Samsung Kenya'; Language = 'en'; TryGalaxy = $true },
    @{ Suffix = 'MU'; Code = 'mu'; Title = 'Samsung Mauritius'; Language = 'en'; TryGalaxy = $false },
    @{ Suffix = 'NG'; Code = 'ng'; Title = 'Samsung Nigeria'; Language = 'en'; TryGalaxy = $false },
    @{ Suffix = 'TZ_SEEA'; Code = 'tz'; Title = 'Samsung Tanzania'; Language = 'en'; TryGalaxy = $true },
    @{ Suffix = 'SN_French'; Code = 'sn'; Title = 'Samsung Senegal'; Language = 'fr'; TryGalaxy = $false },
    @{ Suffix = 'CI_French'; Code = 'ci'; Title = 'Samsung Côte d''Ivoire'; Language = 'fr'; TryGalaxy = $false }
)

$links = @{
    en = @{
        M3 = @{
            product = 'https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a37-5g-awesome-graygreen-128gb-sm-a376bdgmafb/'
        }
        M4 = @{
            a57 = 'https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/'
            a37 = 'https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a37-5g-awesome-graygreen-128gb-sm-a376bdgmafb/'
            watch8 = 'https://www.samsung.com/africa_en/watches/galaxy-watch/galaxy-watch8-44mm-silver-bluetooth-sm-l330nzsamea/'
            buds3fe = 'https://www.samsung.com/africa_en/audio-sound/galaxy-buds/galaxy-buds3-fe-black-sm-r420nzkamea/'
            adapter = 'https://www.samsung.com/africa_en/mobile-accessories/45w-power-adapter-black-ep-t4510xbegww/'
            cases = 'https://www.samsung.com/africa_en/mobile-accessories/all-mobile-accessories/?smartphones+galaxy-a57'
            s25fe = 'https://www.samsung.com/africa_en/smartphones/galaxy-s/galaxy-s25-fe-navy-256gb-sm-s731bdbvafb/'
        }
    }
    fr = @{
        M3 = @{
            product = 'https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a37-5g-awesome-graygreen-128gb-sm-a376bdgmafb/'
        }
        M4 = @{
            a57 = 'https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/'
            a37 = 'https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a37-5g-awesome-graygreen-128gb-sm-a376bdgmafb/'
            watch8 = 'https://www.samsung.com/africa_fr/watches/galaxy-watch/galaxy-watch8-44mm-silver-bluetooth-sm-l330nzsamea/'
            buds3fe = 'https://www.samsung.com/africa_fr/audio-sound/galaxy-buds/galaxy-buds3-fe-black-sm-r420nzkamea/'
            adapter = 'https://www.samsung.com/africa_fr/mobile-accessories/45w-power-adapter-black-ep-t4510xbegww/'
            cases = 'https://www.samsung.com/africa_fr/mobile-accessories/all-mobile-accessories/?smartphones+galaxy-a57'
            s25fe = 'https://www.samsung.com/africa_fr/smartphones/galaxy-s/galaxy-s25-fe-navy-256gb-sm-s731bdbvafb/'
        }
    }
}

$learnMoreButtonSrc = 'https://cdn19.mailercdn.net/users/assets/379/images/138131/4fc4x2Q5agryS9m7/Button_Learn_More.png?v=1777935474'
$tryGalaxyImageSrc = 'https://cdn19.mailercdn.net/users/assets/379/images/trygalaxy.jpg'
$m3BaseHtml = [System.IO.File]::ReadAllText((Join-Path $publishedPath 'ZAS26088109_Galaxy A Series L2_W17_M3_SA.html'))
$m4BaseHtml = [System.IO.File]::ReadAllText((Join-Path $publishedPath 'ZAS26088109_Galaxy A Series L2_W17_M4_SA.html'))

function Get-BaseCdnSrc {
    param(
        [string]$Html,
        [string]$Key
    )

    $pattern = 'src="([^"]*' + [regex]::Escape($Key) + '[^"]*)"'.Replace('\"','"')
    $match = [regex]::Match($Html, $pattern)
    if (-not $match.Success) {
        throw "Could not find CDN src for $Key."
    }

    return $match.Groups[1].Value
}

function Copy-OrderedMap {
    param([System.Collections.IDictionary]$Source)

    $copy = [ordered]@{}
    foreach ($key in $Source.Keys) {
        $copy[$key] = $Source[$key]
    }

    return $copy
}

$englishM3SrcMap = [ordered]@{
    'KV_Group_2654.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'KV_Group_2654.png'
    'Button_Buy_Now.png' = $learnMoreButtonSrc
    'Button_Learn_More.png' = $learnMoreButtonSrc
    'rwrtdghfyjng-00001.jpg' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'rwrtdghfyjng-00001.jpg'
    'Metric_Icon_1.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Metric_Icon_1.png'
    'Metric_Icon_2.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Metric_Icon_2.png'
    'Metric_Icon_3.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Metric_Icon_3.png'
    'Metric_Icon_4.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Metric_Icon_4.png'
    'Metric_Icon_5.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Metric_Icon_5.png'
    'Metric_Icon_6.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Metric_Icon_6.png'
    'KeyTakeaways_Camera.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'KeyTakeaways_Camera.png'
    'Tab_1_IP68.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Tab_1_IP68.png'
    'Durability_IP68.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Durability_IP68.png'
    'Tab_2_Security.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Tab_2_Security.png'
    'Durability_Security.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Durability_Security.png'
    'Tab_3_OS_Upgrades.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Tab_3_OS_Upgrades.png'
    'Durability_OS_Upgrades.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Durability_OS_Upgrades.png'
    'Awesome_Intelligence.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Awesome_Intelligence.png'
    'Eco_Image_595.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Eco_Image_595.png'
    'Eco_Image_594.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Eco_Image_594.png'
    'Eco_Image_600.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Eco_Image_600.png'
    'Eco_Image_599.png' = Get-BaseCdnSrc -Html $m3BaseHtml -Key 'Eco_Image_599.png'
}

$frenchM3SrcMap = Copy-OrderedMap -Source $englishM3SrcMap

$englishM4SrcMap = [ordered]@{
    'KV_Group_2657.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'KV_Group_2657.png'
    'Button_Buy_Galaxy_A57.png' = $learnMoreButtonSrc
    'Button_Buy_Galaxy_A37.png' = $learnMoreButtonSrc
    'Button_Buy_Now.png' = $learnMoreButtonSrc
    'Button_Learn_More.png' = $learnMoreButtonSrc
    'FindPerfect_Comparison.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'FindPerfect_Comparison.png'
    'Comparison_Design_Side.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Comparison_Design_Side.png'
    'Comparison_Line.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Comparison_Line.png'
    'Comparison_Camera_Module.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Comparison_Camera_Module.png'
    'Comparison_Front_Display.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Comparison_Front_Display.png'
    'Durability_Durable_Tab.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Durability_Durable_Tab.png'
    'Durability_IP68.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Durability_IP68.png'
    'Durability_Reliable_Tab.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Durability_Reliable_Tab.png'
    'Durability_Reliable.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Durability_Reliable.png'
    'Awesome_Intelligence.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Awesome_Intelligence.png'
    'Switch_Quick_Share.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Switch_Quick_Share.png'
    'Switch_Smart_Switch.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Switch_Smart_Switch.png'
    'Switch_One_UI.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Switch_One_UI.png'
    'Eco_Image_595.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Eco_Image_595.png'
    'Eco_Image_594.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Eco_Image_594.png'
    'Eco_Image_600.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Eco_Image_600.png'
    'Eco_Image_599.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Eco_Image_599.png'
    'Recommendation_Image.png' = Get-BaseCdnSrc -Html $m4BaseHtml -Key 'Recommendation_Image.png'
}

$frenchM4SrcMap = Copy-OrderedMap -Source $englishM4SrcMap

function Read-Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path)
}

function Write-Text {
    param(
        [string]$Path,
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Get-FooterContent {
    param([string]$Code)

    $footer = Read-Text (Join-Path $footersPath ("footer_{0}.txt" -f $Code))
    return [regex]::Replace($footer, 'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^"]*"'.Replace('\"','"'), 'href="YYYYY"'.Replace('\"','"'))
}

function Get-FooterStartIndex {
    param([string]$Html)

    foreach ($needle in @('https://www.facebook.com/SamsungSouthAfrica', 'https://www.instagram.com/samsungsa/')) {
        $anchorIndex = $Html.IndexOf($needle)
        if ($anchorIndex -ge 0) {
            $tableIndex = $Html.LastIndexOf('<table', $anchorIndex)
            if ($tableIndex -ge 0) {
                return $tableIndex
            }
        }
    }

    throw 'Could not find the South Africa footer start.'
}

function Replace-Title {
    param(
        [string]$Html,
        [string]$Title
    )

    return [regex]::Replace($Html, '<title>.*?</title>', ('<title>{0}</title>' -f $Title))
}

function Replace-Sources {
    param(
        [string]$Html,
        [hashtable]$Map
    )

    foreach ($key in $Map.Keys) {
        $pattern = 'src="[^"]*' + [regex]::Escape($key) + '[^"]*"'.Replace('\"','"')
        $replacement = 'src="' + $Map[$key] + '"'.Replace('\"','"')
        $Html = [regex]::Replace($Html, $pattern, $replacement)
    }

    return $Html
}

function Replace-HrefsByOrder {
    param(
        [string]$Html,
        [string[]]$Hrefs
    )

    $pattern = '<a\b([^>]*?)href="([^"]+)"([^>]*)>'.Replace('\\b','\b').Replace('\"','"')
    $matches = [regex]::Matches($Html, $pattern)
    if ($matches.Count -ne $Hrefs.Count) {
        throw ('Expected {0} anchors but found {1}.' -f $Hrefs.Count, $matches.Count)
    }

    $offset = 0
    for ($i = 0; $i -lt $matches.Count; $i++) {
        $match = $matches[$i]
        $replacement = ('<a{0}href="{1}"{2}>'.Replace('\"','"') -f $match.Groups[1].Value, $Hrefs[$i], $match.Groups[3].Value)
        $index = $match.Index + $offset
        $Html = $Html.Substring(0, $index) + $replacement + $Html.Substring($index + $match.Length)
        $offset += $replacement.Length - $match.Length
    }

    return $Html
}

function Normalize-ButtonImages {
    param(
        [string]$Html,
        [string]$ButtonSrc,
        [string]$AltText,
        [int]$Width
    )

    $escapedSrc = [regex]::Escape($ButtonSrc)
    $pattern = ('<img alt="[^"]*" border="0" height="50" src="' + $escapedSrc + '" style="width:\d+px; height:50px; display:block; margin:auto;" width="\d+">').Replace('\"','"')
    $replacement = ('<img alt="{0}" border="0" height="50" src="{1}" style="width:{2}px; height:50px; display:block; margin:auto;" width="{2}">'.Replace('\"','"') -f $AltText, $ButtonSrc, $Width)
    return [regex]::Replace($Html, $pattern, $replacement)
}

function Replace-VisibleCtaText {
    param(
        [string]$Html,
        [string]$Language
    )

    if ($Language -eq 'fr') {
        $Html = $Html.Replace('Buy now &gt;', 'En savoir plus &gt;')
        $Html = $Html.Replace('Learn more &gt;', 'En savoir plus &gt;')
        $Html = $Html.Replace('Buy now >', 'En savoir plus >')
        $Html = $Html.Replace('Learn more >', 'En savoir plus >')
    }
    else {
        $Html = $Html.Replace('Buy now &gt;', 'Learn more &gt;')
        $Html = $Html.Replace('Buy now >', 'Learn more >')
    }

    return $Html
}

function Get-TryGalaxyHtml {
    param([string]$ImageSrc)

    return @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><a href="https://trygalaxy.com/" target="_blank"><img alt="Try Galaxy AI" border="0" height="279" src="$ImageSrc" style="width:600px; height:279px; display:block;" width="600"></a></td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Copy-NonRetinaPngs {
    param(
        [string]$SourceDir,
        [string]$DestinationDir
    )

    New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
    Get-ChildItem -LiteralPath $SourceDir -File -Filter '*.png' |
        Where-Object { $_.Name -notmatch '@2x' } |
        ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $DestinationDir $_.Name) -Force }
}

function Prepare-FrenchAssets {
    param(
        [string]$Mailer,
        [string]$OutputDir
    )

    if (Test-Path -LiteralPath $OutputDir) {
        Remove-Item -LiteralPath $OutputDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $OutputDir 'Buttons') -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $OutputDir 'Save on') -Force | Out-Null

    if ($Mailer -eq 'M3') {
        Copy-NonRetinaPngs -SourceDir (Join-Path $cutupsPath 'French\3') -DestinationDir $OutputDir
        Copy-NonRetinaPngs -SourceDir (Join-Path $cutupsPath '3\Save on') -DestinationDir (Join-Path $OutputDir 'Save on')
    }
    else {
        Copy-NonRetinaPngs -SourceDir (Join-Path $cutupsPath 'French\4') -DestinationDir $OutputDir
        Copy-NonRetinaPngs -SourceDir (Join-Path $cutupsPath '4\Save on') -DestinationDir (Join-Path $OutputDir 'Save on')
        Copy-Item -LiteralPath (Join-Path $cutupsPath '4\Image 601.png') -Destination (Join-Path $OutputDir 'Image 601.png') -Force
    }

    Copy-Item -LiteralPath (Join-Path $cutupsPath 'French\Buttons\Group 2633.png') -Destination (Join-Path $OutputDir 'Buttons\Group 2633.png') -Force
}

function Get-M3HrefSequence {
    param([string]$Language)

    return @(
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product,
        $links[$Language].M3.product
    )
}

function Get-M4HrefSequence {
    param([string]$Language)

    return @(
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.a37,
        $links[$Language].M4.a57,
        $links[$Language].M4.a37,
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.a57,
        $links[$Language].M4.watch8,
        $links[$Language].M4.watch8,
        $links[$Language].M4.buds3fe,
        $links[$Language].M4.buds3fe,
        $links[$Language].M4.adapter,
        $links[$Language].M4.adapter,
        $links[$Language].M4.cases,
        $links[$Language].M4.cases,
        $links[$Language].M4.s25fe,
        $links[$Language].M4.s25fe
    )
}

function Build-M3Variant {
    param($Region)

    $basePath = Join-Path $publishedPath 'ZAS26088109_Galaxy A Series L2_W17_M3_SA.html'
    $html = Read-Text $basePath
    $html = Replace-Title -Html $html -Title $Region.Title

    $footerStart = Get-FooterStartIndex $html
    $content = $html.Substring(0, $footerStart)
    $content = Replace-HrefsByOrder -Html $content -Hrefs (Get-M3HrefSequence -Language $Region.Language)

    if ($Region.Language -eq 'fr') {
        $content = Replace-Sources -Html $content -Map $frenchM3SrcMap
        $content = Normalize-ButtonImages -Html $content -ButtonSrc $learnMoreButtonSrc -AltText 'En savoir plus' -Width 196
        $content = $content.Replace('height="44" src="Group 2670.png" style="width:239px; height:44px; display:block; margin:auto;" width="239"', 'height="44" src="Group 2670.png" style="width:521px; height:44px; display:block; margin:auto;" width="521"')
    }
    else {
        $content = Replace-Sources -Html $content -Map $englishM3SrcMap
        $content = Normalize-ButtonImages -Html $content -ButtonSrc $learnMoreButtonSrc -AltText 'Learn more' -Width 172
    }

    $content = Replace-VisibleCtaText -Html $content -Language $Region.Language

    if ($Region.TryGalaxy) {
        $content += "`r`n" + (Get-TryGalaxyHtml -ImageSrc $tryGalaxyImageSrc) + "`r`n"
    }

    $finalHtml = $content + "`r`n" + (Get-FooterContent -Code $Region.Code)
    $fileName = 'ZAS26088109_Galaxy A Series L2_W17_M3_{0}.html' -f $Region.Suffix

    if ($Region.Language -eq 'fr') {
        $outputDir = Join-Path $publishedPath ([System.IO.Path]::GetFileNameWithoutExtension($fileName))
        Prepare-FrenchAssets -Mailer 'M3' -OutputDir $outputDir
        Write-Text -Path (Join-Path $outputDir $fileName) -Content $finalHtml
        return Join-Path $outputDir $fileName
    }

    Write-Text -Path (Join-Path $publishedPath $fileName) -Content $finalHtml
    return Join-Path $publishedPath $fileName
}

function Build-M4Variant {
    param($Region)

    $basePath = Join-Path $publishedPath 'ZAS26088109_Galaxy A Series L2_W17_M4_SA.html'
    $html = Read-Text $basePath
    $html = Replace-Title -Html $html -Title $Region.Title

    $footerStart = Get-FooterStartIndex $html
    $content = $html.Substring(0, $footerStart)
    $content = Replace-HrefsByOrder -Html $content -Hrefs (Get-M4HrefSequence -Language $Region.Language)

    if ($Region.Language -eq 'fr') {
        $content = Replace-Sources -Html $content -Map $frenchM4SrcMap
        $content = Normalize-ButtonImages -Html $content -ButtonSrc $learnMoreButtonSrc -AltText 'En savoir plus' -Width 196
    }
    else {
        $content = Replace-Sources -Html $content -Map $englishM4SrcMap
        $content = Normalize-ButtonImages -Html $content -ButtonSrc $learnMoreButtonSrc -AltText 'Learn more' -Width 172
    }

    $content = Replace-VisibleCtaText -Html $content -Language $Region.Language

    if ($Region.TryGalaxy) {
        $content += "`r`n" + (Get-TryGalaxyHtml -ImageSrc $tryGalaxyImageSrc) + "`r`n"
    }

    $finalHtml = $content + "`r`n" + (Get-FooterContent -Code $Region.Code)
    $fileName = 'ZAS26088109_Galaxy A Series L2_W17_M4_{0}.html' -f $Region.Suffix

    if ($Region.Language -eq 'fr') {
        $outputDir = Join-Path $publishedPath ([System.IO.Path]::GetFileNameWithoutExtension($fileName))
        Prepare-FrenchAssets -Mailer 'M4' -OutputDir $outputDir
        Write-Text -Path (Join-Path $outputDir $fileName) -Content $finalHtml
        return Join-Path $outputDir $fileName
    }

    Write-Text -Path (Join-Path $publishedPath $fileName) -Content $finalHtml
    return Join-Path $publishedPath $fileName
}

$createdFiles = New-Object System.Collections.Generic.List[string]
foreach ($region in $regions) {
    $createdFiles.Add((Build-M3Variant -Region $region))
    $createdFiles.Add((Build-M4Variant -Region $region))
}

$createdFiles