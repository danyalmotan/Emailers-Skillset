#requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$HeadingFont = 'Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$BodyFont = 'avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'

$JobRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$MailersRoot = Split-Path -Parent (Split-Path -Parent $JobRoot)
$PublishedRoot = Join-Path $JobRoot 'Published'
$ExportsRoot = Join-Path $JobRoot 'ZAS26113043_images export'
$FrenchRoot = Join-Path $ExportsRoot 'French'
$FrenchComparisonRoot = (Get-ChildItem -LiteralPath $FrenchRoot -Directory | Where-Object { $_.Name -like 'Au*' } | Select-Object -First 1).FullName
$FrenchCameraRoot = (Get-ChildItem -LiteralPath $FrenchRoot -Directory | Where-Object { $_.Name -like 'Capturez*' } | Select-Object -First 1).FullName

$EnglishLinks = [ordered]@{
    A57  = 'https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/'
    A37  = 'https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a37-5g-awesome-graygreen-128gb-sm-a376bdgmafb/'
    S26  = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26-ultra/buy/'
    Care = 'https://www.samsung.com/africa_en/offer/samsung-care-plus/'
}

$FrenchLinks = [ordered]@{
    A57 = 'https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a57-5g-awesome-navy-128gb-sm-a576bdbmafb/'
    A37 = 'https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a37-5g-awesome-graygreen-128gb-sm-a376bdgmafb/'
    S26 = 'https://www.samsung.com/africa_fr/smartphones/galaxy-s26-ultra/buy/'
}

$EnglishCopy = [ordered]@{
    Preheader           = 'The new Galaxy A57 5G'
    IntroHeadline       = 'Premium feel,<br>awesome price'
    IntroBody           = 'Don''t wait to level up and get the premium<br>Galaxy experience you''ve been looking for.'
    CompareHeadline     = 'Beyond expectation.<br>Truly awesome'
    CameraHeadline      = 'Shoot, edit and share<br>special moments'
    CameraSubheadline   = 'Three lenses.<br>Every moment counts'
    CameraBody          = 'Let you take photos and<br>videos bright and crisp.'
    FinalHeadline       = 'Final recommendation.<br>Might be the one?<br>Galaxy S26 Ultra'
    FinalLinkText       = 'Buy now &gt;'
    HeroAlt             = 'Samsung - The new Galaxy A57 5G'
    CompareAlt          = 'Galaxy A57 5G and Galaxy A37 5G side-by-side comparison'
    CameraAlt           = 'Galaxy A57 5G camera highlights'
    RecommendationAlt   = 'Galaxy S26 series'
    CareAlt             = 'Certified care by Samsung experts'
}

$FrenchCopy = [ordered]@{
    Preheader           = 'Le nouveau Galaxy A57 5G'
    IntroHeadline       = 'Un feeling premium,<br>&agrave; un prix incroyable'
    IntroBody           = 'N''attendez plus pour passer au niveau<br>sup&eacute;rieur et profiter de l''exp&eacute;rience Galaxy<br>premium que vous attendiez.'
    CompareHeadline     = 'Au-del&agrave; de vos attentes.<br>Vraiment Magnifique.'
    CameraHeadline      = 'Capturez, sublimez et<br>partagez vos plus<br>beaux moments.'
    CameraSubheadline   = 'Trois objectifs. Chaque instant<br>devient exceptionnel.'
    CameraBody          = 'Des photos et vid&eacute;os &eacute;clatantes,<br>d''une nettet&eacute; remarquable.'
    FinalHeadline       = 'Recommendation finale.<br>Et si c''&eacute;tait le bon choix ?<br>S&eacute;rie Galaxy S26'
    FinalLinkText       = 'En savoir plus &gt;'
    HeroAlt             = 'Samsung - Le nouveau Galaxy A57 5G'
    CompareAlt          = 'Comparatif Galaxy A57 5G et Galaxy A37 5G'
    CameraAlt           = 'Points forts de l''appareil photo du Galaxy A57 5G'
    RecommendationAlt   = 'S&eacute;rie Galaxy S26'
    CareAlt             = 'Samsung Care+'
}

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Write-Utf8File {
    param(
        [string]$Path,
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}

function Escape-AssetPath {
    param([string]$Value)

    return ($Value -replace '\\', '/') -replace ' ', '%20'
}

function Copy-Asset {
    param(
        [string]$SourcePath,
        [string]$DestinationFolder,
        [string]$DestinationName
    )

    $destinationPath = Join-Path $DestinationFolder $DestinationName
    Copy-Item -LiteralPath $SourcePath -Destination $destinationPath -Force
    return $DestinationName
}

function Get-ColorDistance {
    param(
        [System.Drawing.Color]$A,
        [System.Drawing.Color]$B
    )

    return [math]::Abs($A.A - $B.A) +
        [math]::Abs($A.R - $B.R) +
        [math]::Abs($A.G - $B.G) +
        [math]::Abs($A.B - $B.B)
}

function Get-SamplePoints {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [int]$TargetCount = 14
    )

    $background = $Bitmap.GetPixel(0, 0)
    $candidates = New-Object System.Collections.Generic.List[object]
    $stepX = [math]::Max(1, [int]($Bitmap.Width / 26))
    $stepY = [math]::Max(1, [int]($Bitmap.Height / 26))

    for ($y = 0; $y -lt $Bitmap.Height; $y += $stepY) {
        for ($x = 0; $x -lt $Bitmap.Width; $x += $stepX) {
            $pixel = $Bitmap.GetPixel($x, $y)
            if ($pixel.A -lt 20) {
                continue
            }
            if ((Get-ColorDistance -A $pixel -B $background) -lt 75) {
                continue
            }
            $candidates.Add([pscustomobject]@{ X = $x; Y = $y; Color = $pixel })
        }
    }

    if ($candidates.Count -eq 0) {
        $fallbackPoints = @(
            @{ X = [int]($Bitmap.Width * 0.15); Y = [int]($Bitmap.Height * 0.15) },
            @{ X = [int]($Bitmap.Width * 0.50); Y = [int]($Bitmap.Height * 0.20) },
            @{ X = [int]($Bitmap.Width * 0.80); Y = [int]($Bitmap.Height * 0.20) },
            @{ X = [int]($Bitmap.Width * 0.20); Y = [int]($Bitmap.Height * 0.70) },
            @{ X = [int]($Bitmap.Width * 0.65); Y = [int]($Bitmap.Height * 0.65) }
        )
        foreach ($point in $fallbackPoints) {
            $pixel = $Bitmap.GetPixel($point.X, $point.Y)
            $candidates.Add([pscustomobject]@{ X = $point.X; Y = $point.Y; Color = $pixel })
        }
    }

    $selected = New-Object System.Collections.Generic.List[object]
    $stride = [math]::Max(1, [int][math]::Floor($candidates.Count / $TargetCount))
    for ($index = 0; $index -lt $candidates.Count -and $selected.Count -lt $TargetCount; $index += $stride) {
        $selected.Add($candidates[$index])
    }

    return $selected
}

function Test-MatchAt {
    param(
        [System.Drawing.Bitmap]$Haystack,
        [int]$OffsetX,
        [int]$OffsetY,
        [object[]]$Samples,
        [int]$Tolerance = 50
    )

    foreach ($sample in $Samples) {
        $haystackPixel = $Haystack.GetPixel($OffsetX + $sample.X, $OffsetY + $sample.Y)
        if ((Get-ColorDistance -A $haystackPixel -B $sample.Color) -gt $Tolerance) {
            return $false
        }
    }

    return $true
}

function Find-FullWidthMatchY {
    param(
        [System.Drawing.Bitmap]$Haystack,
        [System.Drawing.Bitmap]$Needle,
        [int]$StartY,
        [int]$EndY
    )

    $samples = Get-SamplePoints -Bitmap $Needle -TargetCount 18
    $maxY = [math]::Min($EndY, $Haystack.Height - $Needle.Height)

    for ($y = $StartY; $y -le $maxY; $y++) {
        if (Test-MatchAt -Haystack $Haystack -OffsetX 0 -OffsetY $y -Samples $samples -Tolerance 60) {
            return $y
        }
    }

    throw "Could not locate full-width section in $StartY..$EndY."
}

function Find-SubImage {
    param(
        [System.Drawing.Bitmap]$Haystack,
        [System.Drawing.Bitmap]$Needle,
        [int]$StartX,
        [int]$EndX,
        [int]$StartY,
        [int]$EndY,
        [int]$Tolerance = 55
    )

    $samples = Get-SamplePoints -Bitmap $Needle -TargetCount 16
    $maxX = [math]::Min($EndX, $Haystack.Width - $Needle.Width)
    $maxY = [math]::Min($EndY, $Haystack.Height - $Needle.Height)

    for ($y = $StartY; $y -le $maxY; $y++) {
        for ($x = $StartX; $x -le $maxX; $x++) {
            if (Test-MatchAt -Haystack $Haystack -OffsetX $x -OffsetY $y -Samples $samples -Tolerance $Tolerance) {
                return [System.Drawing.Point]::new($x, $y)
            }
        }
    }

    throw "Could not locate sub-image in x=$StartX..$EndX, y=$StartY..$EndY."
}

function Get-HalfBitmap {
    param([string]$Path)

    $source = [System.Drawing.Bitmap]::new($Path)
    try {
        $targetWidth = [int]($source.Width / 2)
        $targetHeight = [int]($source.Height / 2)
        $target = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($target)
        try {
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $graphics.DrawImage($source, 0, 0, $targetWidth, $targetHeight)
        }
        finally {
            $graphics.Dispose()
        }
        return $target
    }
    finally {
        $source.Dispose()
    }
}

function Crop-Bitmap {
    param(
        [System.Drawing.Bitmap]$Source,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )

    $cropArea = New-Object System.Drawing.Rectangle($X, $Y, $Width, $Height)
    return $Source.Clone($cropArea, $Source.PixelFormat)
}

function Save-Png {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [string]$Path
    )

    $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
}

function Get-FooterHtml {
    param([string]$FooterCode)

    $footerPath = Join-Path $MailersRoot (Join-Path 'footers' ("footer_{0}.txt" -f $FooterCode))
    $footerHtml = [System.IO.File]::ReadAllText($footerPath, [System.Text.Encoding]::UTF8)
    $footerHtml = $footerHtml -replace 'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^"]*"', 'href="YYYYY"'
    $footerHtml = $footerHtml -replace '©', '&copy;'
    return $footerHtml
}

function Get-EnglishTabsHtml {
    return @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="465">
                            <tbody>
                                <tr>
                                    <td align="center" style="background-color:#156CE8; border-radius:11px; color:#ffffff; font-family:$HeadingFont; font-size:18px; line-height:22px; padding:16px 18px;" width="268">01 Triple Camera</td>
                                    <td width="13"></td>
                                    <td align="center" style="background-color:#F4F4F4; border-radius:11px; color:#000000; font-family:$BodyFont; font-size:18px; line-height:22px; padding:16px 0;" width="56">02</td>
                                    <td width="13"></td>
                                    <td align="center" style="background-color:#F4F4F4; border-radius:11px; color:#000000; font-family:$BodyFont; font-size:18px; line-height:22px; padding:16px 0;" width="56">03</td>
                                    <td width="13"></td>
                                    <td align="center" style="background-color:#F4F4F4; border-radius:11px; color:#000000; font-family:$BodyFont; font-size:18px; line-height:22px; padding:16px 0;" width="56">04</td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Get-ComparisonHtml {
    param(
        [hashtable]$Config,
        [string]$AssetPrefix,
        [string]$A57Swatches,
        [string]$A37Swatches,
        [string]$CenterImage,
        [string]$ButtonImage
    )

    $leftLabelThickness = if ($Config.Language -eq 'fr') { '&Eacute;paisseur :' } else { 'Thickness' }
    $leftLabelWeight = if ($Config.Language -eq 'fr') { 'Poids :' } else { 'Weight' }
    $leftLabelCamera = if ($Config.Language -eq 'fr') { 'Appareil photo' } else { 'Camera' }
    $leftLabelDisplay = if ($Config.Language -eq 'fr') { '&Eacute;cran :' } else { 'Display' }
    $ultraWide = if ($Config.Language -eq 'fr') { 'Ultra Grand-angle' } else { 'Ultra Wide' }
    $wide = if ($Config.Language -eq 'fr') { 'Grand Angle' } else { 'Wide' }
    $leftColumnWidth = if ($Config.Language -eq 'fr') { 178 } else { 151 }
    $centerColumnWidth = if ($Config.Language -eq 'fr') { 164 } else { 217 }
    $rightColumnWidth = if ($Config.Language -eq 'fr') { 178 } else { 152 }
    $centerHeight = if ($Config.Language -eq 'fr') { 566 } else { 750 }

    return @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4;" width="600">
                            <tbody>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:48px; line-height:52px;"><strong><span style="font-family:$HeadingFont; color:#000000;">$($Config.Copy.CompareHeadline)</span></strong></span></td>
                                </tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="$leftColumnWidth">
                                                        <table align="left" border="0" cellpadding="0" cellspacing="0" width="$leftColumnWidth">
                                                            <tbody>
                                                                <tr>
                                                                    <td style="text-align:left;"><a href="$($Config.Links.A57)" style="color:#000000; text-decoration:none;" target="_blank"><span style="font-size:24px; line-height:28px;"><strong><span style="font-family:$HeadingFont; color:#000000;">Galaxy<br>A57 5G</span></strong></span></a></td>
                                                                </tr>
                                                                <tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr>
                                                                    <td style="text-align:left;"><a href="$($Config.Links.A57)" target="_blank"><img alt="Galaxy A57 5G colours" border="0" height="26" src="$($AssetPrefix)$A57Swatches" style="display:block; width:110px; height:26px;" width="110"></a></td>
                                                                </tr>
                                                                <tr><td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelThickness</span></span></td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#000000;">6.9 mm</span></strong></span></td></tr>
                                                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelWeight</span></span></td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#000000;">176 g</span></strong></span></td></tr>
                                                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelCamera</span></span></td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#000000;">12 MP</span></strong></span></td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:14px; line-height:18px;"><span style="font-family:$BodyFont; color:#5A5A5F;">$ultraWide</span></span></td></tr>
                                                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#000000;">50 MP</span></strong></span></td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:14px; line-height:18px;"><span style="font-family:$BodyFont; color:#5A5A5F;">$wide</span></span></td></tr>
                                                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#000000;">5 MP</span></strong></span></td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:14px; line-height:18px;"><span style="font-family:$BodyFont; color:#5A5A5F;">Macro</span></span></td></tr>
                                                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelDisplay</span></span></td></tr>
                                                                <tr><td style="text-align:left;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#000000;">Super<br>AMOLED+</span></strong></span></td></tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td valign="top" width="$centerColumnWidth">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="$centerColumnWidth">
                                                            <tbody>
                                                                <tr><td height="42" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:center;"><img alt="$($Config.Copy.CompareAlt)" border="0" height="$centerHeight" src="$($AssetPrefix)$CenterImage" style="display:block; width:${centerColumnWidth}px; height:${centerHeight}px; margin:auto;" width="$centerColumnWidth"></td></tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td valign="top" width="$rightColumnWidth">
                                                        <table align="right" border="0" cellpadding="0" cellspacing="0" width="$rightColumnWidth">
                                                            <tbody>
                                                                <tr>
                                                                    <td style="text-align:right;"><a href="$($Config.Links.A37)" style="color:#000000; text-decoration:none;" target="_blank"><span style="font-size:24px; line-height:28px;"><strong><span style="font-family:$HeadingFont; color:#000000;">Galaxy<br>A37 5G</span></strong></span></a></td>
                                                                </tr>
                                                                <tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr>
                                                                    <td style="text-align:right;"><a href="$($Config.Links.A37)" target="_blank"><img alt="Galaxy A37 5G colours" border="0" height="26" src="$($AssetPrefix)$A37Swatches" style="display:block; width:109px; height:26px; margin-left:auto;" width="109"></a></td>
                                                                </tr>
                                                                <tr><td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelThickness</span></span></td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#5A5A5F;">7.4 mm</span></strong></span></td></tr>
                                                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelWeight</span></span></td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#5A5A5F;">196 g</span></strong></span></td></tr>
                                                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelCamera</span></span></td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#5A5A5F;">8 MP</span></strong></span></td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:14px; line-height:18px;"><span style="font-family:$BodyFont; color:#5A5A5F;">$ultraWide</span></span></td></tr>
                                                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#5A5A5F;">50 MP</span></strong></span></td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:14px; line-height:18px;"><span style="font-family:$BodyFont; color:#5A5A5F;">$wide</span></span></td></tr>
                                                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#5A5A5F;">5 MP</span></strong></span></td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:14px; line-height:18px;"><span style="font-family:$BodyFont; color:#5A5A5F;">Macro</span></span></td></tr>
                                                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:16px; line-height:20px;"><span style="font-family:$BodyFont; color:#2189FF;">$leftLabelDisplay</span></span></td></tr>
                                                                <tr><td style="text-align:right;"><span style="font-size:22px; line-height:26px;"><strong><span style="font-family:$HeadingFont; color:#5A5A5F;">Super<br>AMOLED+</span></strong></span></td></tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$($Config.Links.A57)" target="_blank"><img alt="Learn more" border="0" height="50" src="$($AssetPrefix)$ButtonImage" style="display:block; margin:auto; width:$($Config.ButtonWidth)px; height:50px;" width="$($Config.ButtonWidth)"></a></td>
                                </tr>
                                <tr><td height="38" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
"@
}

function Get-CameraTabsHtml {
    param(
        [hashtable]$Config,
        [string]$AssetPrefix,
        [string]$TabsImage
    )

    if ($Config.Language -eq 'fr') {
        return @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0">
                            <tbody>
                                <tr>
                                    <td style="text-align:center;"><img alt="Tabs" border="0" height="56" src="$($AssetPrefix)$TabsImage" style="display:block; margin:auto; width:465px; height:56px;" width="465"></td>
                                </tr>
                            </tbody>
                        </table>
"@
    }

    return Get-EnglishTabsHtml
}

function Get-FinalRecommendationHtml {
    param(
        [hashtable]$Config,
        [string]$AssetPrefix,
        [string]$RecommendationImage
    )

    return @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#D8DCF1;" width="600">
                            <tbody>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 20px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="560">
                                            <tbody>
                                                <tr>
                                                    <td style="vertical-align:middle; text-align:left; padding-left:20px;" width="240">
                                                        <span style="font-size:18px; line-height:24px;"><strong><span style="font-family:$HeadingFont; color:#000000;">$($Config.Copy.FinalHeadline)</span></strong></span><br><br>
                                                        <a href="$($Config.Links.S26)" style="text-decoration:none;" target="_blank"><span style="font-size:16px;"><strong><span style="font-family:$HeadingFont; color:#000000; text-decoration:underline;">$($Config.Copy.FinalLinkText)</span></strong></span></a>
                                                    </td>
                                                    <td style="text-align:right; vertical-align:bottom;" width="320">
                                                        <a href="$($Config.Links.S26)" target="_blank"><img alt="$($Config.Copy.RecommendationAlt)" border="0" height="278" src="$($AssetPrefix)$RecommendationImage" style="display:block; width:300px; height:278px; margin-left:auto;" width="300"></a>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
"@
}

function Get-CareHtml {
    param(
        [hashtable]$Config,
        [string]$AssetPrefix,
        [string]$CareImage
    )

    return @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center;"><a href="$($Config.Links.Care)" target="_blank"><img alt="$($Config.Copy.CareAlt)" border="0" height="277" src="$($AssetPrefix)$CareImage" style="display:block; width:600px; height:277px;" width="600"></a></td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Get-MailerHtml {
    param(
        [hashtable]$Config,
        [hashtable]$Assets,
        [string]$FooterHtml,
        [switch]$RootCopy
    )

    $assetPrefix = ''
    if ($RootCopy) {
        $assetPrefix = (Escape-AssetPath -Value ($Config.BaseName + '/'))
    }

    $tabsHtml = Get-CameraTabsHtml -Config $Config -AssetPrefix $assetPrefix -TabsImage $Assets.CameraTabs
    $comparisonHtml = Get-ComparisonHtml -Config $Config -AssetPrefix $assetPrefix -A57Swatches $Assets.CompareA57 -A37Swatches $Assets.CompareA37 -CenterImage $Assets.CompareCenter -ButtonImage $Assets.Button

    $endingHtml = if ($Config.Ending -eq 'care') {
        Get-CareHtml -Config $Config -AssetPrefix $assetPrefix -CareImage $Assets.Care
    }
    else {
        Get-FinalRecommendationHtml -Config $Config -AssetPrefix $assetPrefix -RecommendationImage $Assets.Recommendation
    }

    return @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>$($Config.Title)</title>
    </head>
    <body style="background-color:#555;"><!-- Preheader START =========================================================================== --><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> $($Config.Copy.Preheader) </span> <!-- Preheader END =========================================================================== -->
        <table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">
            <tbody>
                <tr>
                    <td align="center" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"><br>
                                        <span style="color:#000000;">ZZZZZ</span><br>
                                        &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"></td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>

                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><a href="$($Config.Links.A57)" target="_blank"><img alt="$($Config.Copy.HeroAlt)" border="0" height="$($Config.HeroHeight)" src="$($assetPrefix)$($Assets.Hero)" style="display:block; width:600px; height:$($Config.HeroHeight)px;" width="600"></a></td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="32" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:48px; line-height:52px;"><strong><span style="font-family:$HeadingFont; color:#000000;">$($Config.Copy.IntroHeadline)</span></strong></span></td>
                                </tr>
                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:24px; line-height:28px;"><span style="font-family:$BodyFont; color:#000000;">$($Config.Copy.IntroBody)</span></span></td>
                                </tr>
                                <tr><td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$($Config.Links.A57)" target="_blank"><img alt="Learn more" border="0" height="50" src="$($assetPrefix)$($Assets.Button)" style="display:block; margin:auto; width:$($Config.ButtonWidth)px; height:50px;" width="$($Config.ButtonWidth)"></a></td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$comparisonHtml
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 34px;"><span style="font-size:48px; line-height:52px;"><strong><span style="font-family:$HeadingFont; color:#000000;">$($Config.Copy.CameraHeadline)</span></strong></span></td>
                                </tr>
                                <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center;">$tabsHtml</td>
                                </tr>
                                <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border:2px solid #32F05E;" width="600">
                                            <tbody>
                                                <tr>
                                                    <td style="font-size:0; line-height:0;"><a href="$($Config.Links.A57)" target="_blank"><img alt="$($Config.Copy.CameraAlt)" border="0" height="379" src="$($assetPrefix)$($Assets.Camera)" style="display:block; width:600px; height:379px;" width="600"></a></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:36px; line-height:40px;"><strong><span style="font-family:$HeadingFont; color:#000000;">$($Config.Copy.CameraSubheadline)</span></strong></span></td>
                                </tr>
                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:24px; line-height:28px;"><span style="font-family:$BodyFont; color:#000000;">$($Config.Copy.CameraBody)</span></span></td>
                                </tr>
                                <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$($Config.Links.A57)" target="_blank"><img alt="Learn more" border="0" height="50" src="$($assetPrefix)$($Assets.Button)" style="display:block; margin:auto; width:$($Config.ButtonWidth)px; height:50px;" width="$($Config.ButtonWidth)"></a></td>
                                </tr>
                                <tr><td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>

$endingHtml$FooterHtml
"@
}

function New-FlatZip {
    param(
        [string]$FolderPath,
        [string]$ZipBaseName
    )

    $tempZip = Join-Path ([System.IO.Path]::GetTempPath()) (([System.Guid]::NewGuid()).ToString() + '.zip')
    $destinationZip = Join-Path $FolderPath ($ZipBaseName + '.zip')

    if (Test-Path -LiteralPath $destinationZip) {
        Remove-Item -LiteralPath $destinationZip -Force
    }

    $archive = [System.IO.Compression.ZipFile]::Open($tempZip, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        $files = Get-ChildItem -LiteralPath $FolderPath -File | Where-Object { $_.Extension -ne '.zip' }
        foreach ($file in $files) {
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $file.Name, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
    }
    finally {
        $archive.Dispose()
    }

    Move-Item -LiteralPath $tempZip -Destination $destinationZip -Force

    $expectedCount = @(Get-ChildItem -LiteralPath $FolderPath -File | Where-Object { $_.Extension -ne '.zip' }).Count
    $zip = [System.IO.Compression.ZipFile]::OpenRead($destinationZip)
    try {
        if ($zip.Entries.Count -ne $expectedCount) {
            throw "Zip entry count mismatch for $ZipBaseName. Expected $expectedCount, found $($zip.Entries.Count)."
        }
        if ($zip.Entries | Where-Object { $_.FullName -match '[\\/]' }) {
            throw "Zip contains nested paths for $ZipBaseName."
        }
    }
    finally {
        $zip.Dispose()
    }
}

Ensure-Directory -Path $PublishedRoot

$englishFull = $null
$frenchFull = $null
$frenchCameraNeedle = $null
$frenchRecommendationNeedle = $null
$englishRecommendationNeedle = $null
$englishCameraCrop = $null

$englishFull = Get-HalfBitmap -Path (Join-Path $JobRoot 'ZAS26113043_2026_SEWA Retainer_MX A Series Sustain Mailer 1 ROA.png')
$frenchFull = Get-HalfBitmap -Path (Join-Path $JobRoot 'ZAS26113043_2026_SEWA Retainer_MX A Series Sustain Mailer 1 French.png')
$frenchCameraNeedle = [System.Drawing.Bitmap]::new((Join-Path $FrenchCameraRoot '30b4dbaf6538f9082095f220a4c402a1.png'))
$frenchRecommendationNeedle = [System.Drawing.Bitmap]::new((Join-Path $FrenchCameraRoot 'Mask Group 1.png'))
$englishRecommendationNeedle = [System.Drawing.Bitmap]::new((Join-Path $ExportsRoot 'SEWA\Mask Group 1.png'))

try {
    $frenchCameraY = Find-FullWidthMatchY -Haystack $frenchFull -Needle $frenchCameraNeedle -StartY 2200 -EndY 3200
    $frenchRecommendationPoint = Find-SubImage -Haystack $frenchFull -Needle $frenchRecommendationNeedle -StartX 230 -EndX 330 -StartY 2950 -EndY 3550 -Tolerance 70
    $cameraPositionRatio = $frenchCameraY / [double]($frenchFull.Height - $frenchCameraNeedle.Height)
    $englishCameraY = [int][math]::Round($cameraPositionRatio * ($englishFull.Height - $frenchCameraNeedle.Height))
    $englishCameraY = [math]::Max(0, [math]::Min($englishCameraY, $englishFull.Height - $frenchCameraNeedle.Height))
    $englishCameraCrop = Crop-Bitmap -Source $englishFull -X 0 -Y $englishCameraY -Width 600 -Height 379

    $regions = @(
        [ordered]@{
            RegionCode  = 'GH'
            FooterCode  = 'gh'
            Title       = 'Samsung Ghana'
            BaseName    = 'GH_ZAS26113043  2026_SEWA Retainer_MX A Series Sustain _ Mailer _ W21'
            Language    = 'en'
            Copy        = $EnglishCopy
            Links       = $EnglishLinks
            HeroPath    = Join-Path $ExportsRoot 'GH\Group 2717.png'
            HeroHeight  = 929
            ButtonPath  = Join-Path $ExportsRoot 'SEWA\Buttons\Group 2667.png'
            ButtonWidth = 184
            CompareA57  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 627.png'
            CompareA37  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 628.png'
            CompareCenter = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 629.png'
            CameraPath  = $null
            CameraTabsPath = $null
            Ending      = 'care'
            RecommendationPath = $null
            CarePath    = Join-Path $ExportsRoot 'GH\Certified care\Group 2719.png'
        },
        [ordered]@{
            RegionCode  = 'NG'
            FooterCode  = 'ng'
            Title       = 'Samsung Nigeria'
            BaseName    = 'NG_ZAS26113043  2026_SEWA Retainer_MX A Series Sustain _ Mailer _ W21'
            Language    = 'en'
            Copy        = $EnglishCopy
            Links       = $EnglishLinks
            HeroPath    = Join-Path $ExportsRoot 'SEWA\Group 2716.png'
            HeroHeight  = 757
            ButtonPath  = Join-Path $ExportsRoot 'SEWA\Buttons\Group 2667.png'
            ButtonWidth = 184
            CompareA57  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 627.png'
            CompareA37  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 628.png'
            CompareCenter = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 629.png'
            CameraPath  = $null
            CameraTabsPath = $null
            Ending      = 'recommendation'
            RecommendationPath = Join-Path $ExportsRoot 'SEWA\Mask Group 1.png'
            CarePath    = $null
        },
        [ordered]@{
            RegionCode  = 'KE'
            FooterCode  = 'ke'
            Title       = 'Samsung Kenya'
            BaseName    = 'KE_ZAS26113043  2026_SEWA Retainer_MX A Series Sustain _ Mailer _ W21'
            Language    = 'en'
            Copy        = $EnglishCopy
            Links       = $EnglishLinks
            HeroPath    = Join-Path $ExportsRoot 'SEWA\Group 2716.png'
            HeroHeight  = 757
            ButtonPath  = Join-Path $ExportsRoot 'SEWA\Buttons\Group 2667.png'
            ButtonWidth = 184
            CompareA57  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 627.png'
            CompareA37  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 628.png'
            CompareCenter = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 629.png'
            CameraPath  = $null
            CameraTabsPath = $null
            Ending      = 'recommendation'
            RecommendationPath = Join-Path $ExportsRoot 'SEWA\Mask Group 1.png'
            CarePath    = $null
        },
        [ordered]@{
            RegionCode  = 'TZ'
            FooterCode  = 'tz'
            Title       = 'Samsung Tanzania'
            BaseName    = 'TZ_ZAS26113043  2026_SEWA Retainer_MX A Series Sustain _ Mailer _ W21'
            Language    = 'en'
            Copy        = $EnglishCopy
            Links       = $EnglishLinks
            HeroPath    = Join-Path $ExportsRoot 'SEWA\Group 2716.png'
            HeroHeight  = 757
            ButtonPath  = Join-Path $ExportsRoot 'SEWA\Buttons\Group 2667.png'
            ButtonWidth = 184
            CompareA57  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 627.png'
            CompareA37  = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 628.png'
            CompareCenter = Join-Path $ExportsRoot 'SEWA\Beyond expectation\Image 629.png'
            CameraPath  = $null
            CameraTabsPath = $null
            Ending      = 'recommendation'
            RecommendationPath = Join-Path $ExportsRoot 'SEWA\Mask Group 1.png'
            CarePath    = $null
        },
        [ordered]@{
            RegionCode  = 'SN'
            FooterCode  = 'sn'
            Title       = 'Samsung Senegal'
            BaseName    = 'SN_ZAS26113043  2026_SEWA Retainer_MX A Series Sustain _ Mailer _ W21'
            Language    = 'fr'
            Copy        = $FrenchCopy
            Links       = $FrenchLinks
            HeroPath    = Join-Path $ExportsRoot 'French\Group 2720.png'
            HeroHeight  = 757
            ButtonPath  = Join-Path $ExportsRoot 'French\Buttons\Group 2715.png'
            ButtonWidth = 196
            CompareA57  = Join-Path $FrenchComparisonRoot 'Image 627.png'
            CompareA37  = Join-Path $FrenchComparisonRoot 'Image 628.png'
            CompareCenter = Join-Path $FrenchComparisonRoot 'Image 629.png'
            CameraPath  = Join-Path $FrenchCameraRoot '30b4dbaf6538f9082095f220a4c402a1.png'
            CameraTabsPath = Join-Path $FrenchCameraRoot 'Group 2721.png'
            Ending      = 'recommendation'
            RecommendationPath = Join-Path $FrenchCameraRoot 'Mask Group 1.png'
            CarePath    = $null
        },
        [ordered]@{
            RegionCode  = 'CIV'
            FooterCode  = 'ci'
            Title       = 'Samsung C&ocirc;te d''Ivoire'
            BaseName    = 'CIV_ZAS26113043  2026_SEWA Retainer_MX A Series Sustain _ Mailer _ W21'
            Language    = 'fr'
            Copy        = $FrenchCopy
            Links       = $FrenchLinks
            HeroPath    = Join-Path $ExportsRoot 'French\Group 2720.png'
            HeroHeight  = 757
            ButtonPath  = Join-Path $ExportsRoot 'French\Buttons\Group 2715.png'
            ButtonWidth = 196
            CompareA57  = Join-Path $FrenchComparisonRoot 'Image 627.png'
            CompareA37  = Join-Path $FrenchComparisonRoot 'Image 628.png'
            CompareCenter = Join-Path $FrenchComparisonRoot 'Image 629.png'
            CameraPath  = Join-Path $FrenchCameraRoot '30b4dbaf6538f9082095f220a4c402a1.png'
            CameraTabsPath = Join-Path $FrenchCameraRoot 'Group 2721.png'
            Ending      = 'recommendation'
            RecommendationPath = Join-Path $FrenchCameraRoot 'Mask Group 1.png'
            CarePath    = $null
        }
    )

    foreach ($region in $regions) {
        $folderPath = Join-Path $PublishedRoot $region.BaseName
        Ensure-Directory -Path $folderPath

        $assets = [ordered]@{}
        $assets.Hero = Copy-Asset -SourcePath $region.HeroPath -DestinationFolder $folderPath -DestinationName 'Hero_KV.png'
        $assets.Button = Copy-Asset -SourcePath $region.ButtonPath -DestinationFolder $folderPath -DestinationName 'Button_Learn_More.png'
        $assets.CompareA57 = Copy-Asset -SourcePath $region.CompareA57 -DestinationFolder $folderPath -DestinationName 'Comparison_Swatches_A57.png'
        $assets.CompareA37 = Copy-Asset -SourcePath $region.CompareA37 -DestinationFolder $folderPath -DestinationName 'Comparison_Swatches_A37.png'
        $assets.CompareCenter = Copy-Asset -SourcePath $region.CompareCenter -DestinationFolder $folderPath -DestinationName 'Comparison_Center.png'

        if ($region.Language -eq 'fr') {
            $assets.Camera = Copy-Asset -SourcePath $region.CameraPath -DestinationFolder $folderPath -DestinationName 'Camera_Image.png'
            $assets.CameraTabs = Copy-Asset -SourcePath $region.CameraTabsPath -DestinationFolder $folderPath -DestinationName 'Camera_Tabs.png'
        }
        else {
            $cameraPath = Join-Path $folderPath 'Camera_Image.png'
            Save-Png -Bitmap $englishCameraCrop -Path $cameraPath
            $assets.Camera = 'Camera_Image.png'
            $assets.CameraTabs = $null
        }

        if ($region.Ending -eq 'care') {
            $assets.Care = Copy-Asset -SourcePath $region.CarePath -DestinationFolder $folderPath -DestinationName 'Care_Block.png'
            $assets.Recommendation = $null
        }
        else {
            $assets.Recommendation = Copy-Asset -SourcePath $region.RecommendationPath -DestinationFolder $folderPath -DestinationName 'Recommendation_Image.png'
            $assets.Care = $null
        }

        $footerHtml = Get-FooterHtml -FooterCode $region.FooterCode
        $htmlContent = Get-MailerHtml -Config $region -Assets $assets -FooterHtml $footerHtml
        $folderHtmlPath = Join-Path $folderPath ($region.BaseName + '.html')
        Write-Utf8File -Path $folderHtmlPath -Content $htmlContent

        $rootHtmlPath = Join-Path $PublishedRoot ($region.BaseName + '.html')
        $rootHtmlContent = Get-MailerHtml -Config $region -Assets $assets -FooterHtml $footerHtml -RootCopy
        Write-Utf8File -Path $rootHtmlPath -Content $rootHtmlContent

        New-FlatZip -FolderPath $folderPath -ZipBaseName $region.BaseName
    }
}
finally {
    if ($englishCameraCrop) { $englishCameraCrop.Dispose() }
    if ($englishFull) { $englishFull.Dispose() }
    if ($frenchFull) { $frenchFull.Dispose() }
    if ($frenchCameraNeedle) { $frenchCameraNeedle.Dispose() }
    if ($frenchRecommendationNeedle) { $frenchRecommendationNeedle.Dispose() }
    if ($englishRecommendationNeedle) { $englishRecommendationNeedle.Dispose() }
}

Write-Host 'Generated Published outputs for GH, NG, KE, TZ, SN, and CIV.'