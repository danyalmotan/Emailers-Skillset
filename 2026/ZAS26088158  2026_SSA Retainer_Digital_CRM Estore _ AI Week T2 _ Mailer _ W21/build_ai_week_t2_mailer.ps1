$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$headingFont = 'Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$bodyFont = 'avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$sectionOuterBg = '#E7EBF7'

$jobRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetRoot = Join-Path $jobRoot 'ZAS26088158 _ 2026_SSA Retainer_Digital_CRM Estore _ AI Week T2 _ Mailer _ W21_Assets'
$footerPath = 'c:\Users\user\OneDrive\digidanWork\Mailers\footers\footer_ssa.txt'
$publishedRoot = Join-Path $jobRoot 'Published'

if (-not (Test-Path -LiteralPath $publishedRoot)) {
    New-Item -ItemType Directory -Path $publishedRoot | Out-Null
}

$imageInfoCache = @{}

function Join-Html {
    param([string[]]$Parts)

    return ($Parts | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join "`r`n"
}

function Get-ImageInfo {
    param([string]$Path)

    if ($imageInfoCache.ContainsKey($Path)) {
        return $imageInfoCache[$Path]
    }

    $image = [System.Drawing.Image]::FromFile($Path)
    try {
        $info = [ordered]@{
            Width = $image.Width
            Height = $image.Height
        }
    }
    finally {
        $image.Dispose()
    }

    $imageInfoCache[$Path] = $info
    return $info
}

function Sanitize-FileName {
    param([string]$Name)

    $clean = $Name -replace ' ', '_'
    $clean = $clean -replace '[^A-Za-z0-9._-]', ''
    if ([string]::IsNullOrWhiteSpace($clean)) {
        throw "Unable to sanitize filename: $Name"
    }
    return $clean
}

function New-MailerContext {
    param(
        [string]$MailerName,
        [string]$DesignFileName
    )

    $outputDir = Join-Path $publishedRoot $MailerName
    if (-not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir | Out-Null
    }

    return [ordered]@{
        MailerName = $MailerName
        DesignFileName = $DesignFileName
        DesignPath = Join-Path $jobRoot $DesignFileName
        HtmlFileName = [System.IO.Path]::ChangeExtension($DesignFileName, '.html')
        OutputDir = $outputDir
        AssetMap = @{}
        NameMap = @{}
    }
}

function Resolve-DestinationName {
    param(
        $Context,
        [string]$SourceKey,
        [string]$ProposedName
    )

    $fileName = Sanitize-FileName $ProposedName
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $extension = [System.IO.Path]::GetExtension($fileName)
    $counter = 2

    while ($Context.NameMap.ContainsKey($fileName) -and $Context.NameMap[$fileName] -ne $SourceKey) {
        $fileName = '{0}_{1}{2}' -f $stem, $counter, $extension
        $counter += 1
    }

    $Context.NameMap[$fileName] = $SourceKey
    return $fileName
}

function Resolve-Asset {
    param(
        $Context,
        [string]$RelativePath,
        [string]$PreferredName
    )

    $sourcePath = if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        $RelativePath
    }
    elseif ($RelativePath.StartsWith('Live Shopping Event Pod\')) {
        Join-Path $jobRoot $RelativePath
    }
    else {
        Join-Path $assetRoot $RelativePath
    }

    $sourceKey = "copy::$sourcePath"
    if ($Context.AssetMap.ContainsKey($sourceKey)) {
        return $Context.AssetMap[$sourceKey]
    }

    $baseName = if ($PreferredName) { $PreferredName } else { [System.IO.Path]::GetFileName($sourcePath) }
    $fileName = Resolve-DestinationName -Context $Context -SourceKey $sourceKey -ProposedName $baseName
    $destinationPath = Join-Path $Context.OutputDir $fileName

    Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force

    $info = Get-ImageInfo $sourcePath
    $asset = [ordered]@{
        FileName = $fileName
        FullPath = $destinationPath
        Width = $info.Width
        Height = $info.Height
    }
    $Context.AssetMap[$sourceKey] = $asset
    return $asset
}

function Crop-DesignAsset {
    param(
        $Context,
        [string]$OutputName,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )

    $sourceKey = "crop::$($Context.DesignPath)::$OutputName::$X::$Y::$Width::$Height"
    if ($Context.AssetMap.ContainsKey($sourceKey)) {
        return $Context.AssetMap[$sourceKey]
    }

    $fileName = Resolve-DestinationName -Context $Context -SourceKey $sourceKey -ProposedName $OutputName
    $destinationPath = Join-Path $Context.OutputDir $fileName

    $sourceImage = [System.Drawing.Bitmap]::FromFile($Context.DesignPath)
    try {
        $rect = New-Object System.Drawing.Rectangle $X, $Y, $Width, $Height
        $cropped = $sourceImage.Clone($rect, $sourceImage.PixelFormat)
        try {
            $cropped.Save($destinationPath, [System.Drawing.Imaging.ImageFormat]::Png)
        }
        finally {
            $cropped.Dispose()
        }
    }
    finally {
        $sourceImage.Dispose()
    }

    $info = Get-ImageInfo $destinationPath
    $asset = [ordered]@{
        FileName = $fileName
        FullPath = $destinationPath
        Width = $info.Width
        Height = $info.Height
    }
    $Context.AssetMap[$sourceKey] = $asset
    return $asset
}

function Render-ImageTag {
    param(
        $Asset,
        [string]$Alt,
        [string]$ExtraStyle = ''
    )

    $style = 'display:block; width:{0}px; height:{1}px; margin:auto; border:0; {2}' -f $Asset.Width, $Asset.Height, $ExtraStyle
    return '<img alt="{0}" border="0" height="{1}" src="{2}" style="{3}" width="{4}">' -f $Alt, $Asset.Height, $Asset.FileName, $style, $Asset.Width
}

function Render-LinkedImage {
    param(
        $Asset,
        [string]$Href,
        [string]$Alt,
        [string]$ExtraStyle = ''
    )

    return '<a href="{0}" target="_blank">{1}</a>' -f $Href, (Render-ImageTag -Asset $Asset -Alt $Alt -ExtraStyle $ExtraStyle)
}

function Render-ProductTag {
    param(
        $Context,
        $Product
    )

    if ($Product.TagRel) {
        $tagAsset = Resolve-Asset -Context $Context -RelativePath $Product.TagRel
        return @"
<table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tbody>
        <tr>
            <td style="text-align:left; vertical-align:top;">$(Render-ImageTag -Asset $tagAsset -Alt $Product.TagAlt)</td>
        </tr>
    </tbody>
</table>
"@
    }

    if ($Product.TagTextHtml) {
        return @"
<table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tbody>
        <tr>
            <td style="text-align:left; vertical-align:top;">
                <span style="background-color:#98A7D8; border-radius:16px 0 16px 0; color:#ffffff; display:inline-block; font-family:$bodyFont; font-size:12px; line-height:16px; padding:10px 14px 8px 14px;">$($Product.TagTextHtml)</span>
            </td>
        </tr>
    </tbody>
</table>
"@
    }

    return ''
}

function Render-PriceBlock {
    param(
        $Product,
        [int]$Columns
    )

    if ($Product.NowPriceHtml) {
        $priceSize = if ($Columns -eq 3) { 18 } else { 20 }
        $saveHtml = if ($Product.SavePriceHtml) {
@"
<br><span style="color:#4C4C4C; font-family:$bodyFont; font-size:13px; line-height:18px;">Save <span style="color:#000000; font-family:$headingFont; font-size:17px; font-weight:bold; line-height:18px;">$($Product.SavePriceHtml)</span></span>
"@
        }
        else {
            ''
        }

        return @"
<span style="color:#4C4C4C; font-family:$bodyFont; font-size:13px; line-height:18px;">Now <span style="color:#000000; font-family:$headingFont; font-size:${priceSize}px; font-weight:bold; line-height:${priceSize}px;">$($Product.NowPriceHtml)</span></span>$saveHtml
"@
    }

    $singlePriceSize = if ($Columns -eq 3) { 20 } else { 22 }
    return '<span style="color:#000000; font-family:{0}; font-size:{1}px; font-weight:bold; line-height:{1}px;">{2}</span>' -f $headingFont, $singlePriceSize, $Product.PriceHtml
}

function Render-ProductCard {
    param(
        $Context,
        $Product,
        [int]$CardWidth,
        [int]$Columns
    )

    $imageAsset = Resolve-Asset -Context $Context -RelativePath $Product.ImageRel
    $buttonRel = if ($Product.ButtonRel) { $Product.ButtonRel } else { 'Buttons\Group 875.png' }
    $buttonAsset = Resolve-Asset -Context $Context -RelativePath $buttonRel
    $tagHtml = Render-ProductTag -Context $Context -Product $Product
    $nameFontSize = if ($Columns -eq 3) { 14 } else { 16 }
    $nameLineHeight = if ($Columns -eq 3) { 18 } else { 20 }
    $modelSize = 11
    $imageBoxHeight = if ($Columns -eq 3) { 130 } else { 150 }
    $titlePadding = if ($Columns -eq 3) { '8px 10px 0 10px' } else { '8px 16px 0 16px' }
    $buttonAlt = if ($Product.ButtonAlt) { $Product.ButtonAlt } else { 'Buy now' }

    return @"
<table border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; border-radius:22px; overflow:hidden; width:${CardWidth}px;" width="$CardWidth">
    <tbody>
        <tr>
            <td style="padding:0; vertical-align:top;">
                $tagHtml
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr>
                            <td align="center" height="$imageBoxHeight" style="padding:18px 12px 0 12px; vertical-align:middle;" valign="middle"><a href="$($Product.Link)" target="_blank">$(Render-ImageTag -Asset $imageAsset -Alt $Product.ImageAlt)</a></td>
                        </tr>
                        <tr>
                            <td align="center" style="padding:$titlePadding; color:#000000; font-family:$headingFont; font-size:${nameFontSize}px; font-weight:bold; line-height:${nameLineHeight}px;">$($Product.NameHtml)<br><span style="color:#4C4C4C; font-size:${modelSize}px; font-weight:normal; line-height:14px;">$($Product.ModelHtml)</span></td>
                        </tr>
                        <tr>
                            <td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td>
                        </tr>
                        <tr>
                            <td align="center" style="text-align:center;">$(Render-PriceBlock -Product $Product -Columns $Columns)</td>
                        </tr>
                        <tr>
                            <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                        </tr>
                        <tr>
                            <td align="center" style="padding:0 0 24px 0;"><a href="$($Product.Link)" target="_blank">$(Render-ImageTag -Asset $buttonAsset -Alt $buttonAlt)</a></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Render-GridBlock {
    param(
        $Context,
        $Cards,
        [int]$Columns
    )

    $cardWidth = if ($Columns -eq 2) { 251 } else { 166 }
    $gapWidth = if ($Columns -eq 2) { 18 } else { 11 }
    $rowParts = @()

    for ($rowIndex = 0; $rowIndex -lt $Cards.Count; $rowIndex += $Columns) {
        $cells = @()
        for ($columnIndex = 0; $columnIndex -lt $Columns; $columnIndex += 1) {
            if ($columnIndex -gt 0) {
                $cells += '<td width="{0}"></td>' -f $gapWidth
            }

            $cardIndex = $rowIndex + $columnIndex
            if ($cardIndex -lt $Cards.Count) {
                $cells += '<td valign="top" width="{0}">{1}</td>' -f $cardWidth, (Render-ProductCard -Context $Context -Product $Cards[$cardIndex] -CardWidth $cardWidth -Columns $Columns)
            }
            else {
                $cells += '<td width="{0}"></td>' -f $cardWidth
            }
        }

        $rowParts += '<tr>{0}</tr>' -f ($cells -join '')
        if (($rowIndex + $Columns) -lt $Cards.Count) {
            $rowParts += '<tr><td colspan="{0}" height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>' -f (($Columns * 2) - 1)
        }
    }

    return @"
<table border="0" cellpadding="0" cellspacing="0" width="520">
    <tbody>
        $(Join-Html $rowParts)
    </tbody>
</table>
"@
}

function Render-TwoOfferPrice {
    param($Product)

    if ($Product.NowPriceHtml) {
        $saveHtml = if ($Product.SavePriceHtml) {
@"
<br><span style="color:#4C4C4C; font-family:$bodyFont; font-size:13px; line-height:18px;">Save <span style="color:#000000; font-family:$headingFont; font-size:17px; font-weight:bold; line-height:18px;">$($Product.SavePriceHtml)</span></span>
"@
        }
        else {
            ''
        }

        return @"
<span style="color:#4C4C4C; font-family:$bodyFont; font-size:13px; line-height:18px;">Now <span style="color:#000000; font-family:$headingFont; font-size:20px; font-weight:bold; line-height:26px;">$($Product.NowPriceHtml)</span></span>$saveHtml
"@
    }

    return '<span style="color:#000000; font-family:{0}; font-size:20px; font-weight:bold; line-height:26px;">{1}</span>' -f $headingFont, $Product.PriceHtml
}

function Render-TwoOfferColumns {
    param(
        $LeftProduct,
        $RightProduct
    )

    $leftPriceHtml = Render-TwoOfferPrice -Product $LeftProduct
    $rightPriceHtml = Render-TwoOfferPrice -Product $RightProduct

    return @"
<table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tbody>
        <tr>
            <td align="center" style="padding:0 14px 0 18px; vertical-align:top;" valign="top" width="240">
                <span style="color:#000000; font-family:$headingFont; font-size:14px; font-weight:bold; line-height:20px;">$($LeftProduct.NameHtml)</span><br>
                <span style="color:#4C4C4C; font-family:$bodyFont; font-size:11px; line-height:14px;">$($LeftProduct.ModelHtml)</span><br>
                $leftPriceHtml<br><br>
                <a href="$($LeftProduct.Link)" target="_blank">$($LeftProduct.ButtonHtml)</a>
            </td>
            <td style="background-color:#D8D8D8; width:1px; font-size:1px; line-height:1px;" width="1">&nbsp;</td>
            <td align="center" style="padding:0 18px 0 14px; vertical-align:top;" valign="top" width="239">
                <span style="color:#000000; font-family:$headingFont; font-size:14px; font-weight:bold; line-height:20px;">$($RightProduct.NameHtml)</span><br>
                <span style="color:#4C4C4C; font-family:$bodyFont; font-size:11px; line-height:14px;">$($RightProduct.ModelHtml)</span><br>
                $rightPriceHtml<br><br>
                <a href="$($RightProduct.Link)" target="_blank">$($RightProduct.ButtonHtml)</a>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Render-TVWideBlock {
    param(
        $Context,
        [string]$TagRel,
        [string]$TagAlt,
        [string]$ImageRel,
        [string]$ImageAlt,
        $LeftProduct,
        $RightProduct
    )

    $tagProduct = [ordered]@{ TagRel = $TagRel; TagAlt = $TagAlt }
    $tagHtml = Render-ProductTag -Context $Context -Product $tagProduct
    $imageAsset = Resolve-Asset -Context $Context -RelativePath $ImageRel
    $buyButton = Resolve-Asset -Context $Context -RelativePath 'Buttons\Group 922.png'
    $left = [ordered]@{}
    $left.NameHtml = $LeftProduct.NameHtml
    $left.ModelHtml = $LeftProduct.ModelHtml
    $left.PriceHtml = $LeftProduct.PriceHtml
    $left.NowPriceHtml = $LeftProduct.NowPriceHtml
    $left.SavePriceHtml = $LeftProduct.SavePriceHtml
    $left.Link = $LeftProduct.Link
    $left.ButtonHtml = Render-ImageTag -Asset $buyButton -Alt 'Buy now'
    $right = [ordered]@{}
    $right.NameHtml = $RightProduct.NameHtml
    $right.ModelHtml = $RightProduct.ModelHtml
    $right.PriceHtml = $RightProduct.PriceHtml
    $right.NowPriceHtml = $RightProduct.NowPriceHtml
    $right.SavePriceHtml = $RightProduct.SavePriceHtml
    $right.Link = $RightProduct.Link
    $right.ButtonHtml = Render-ImageTag -Asset $buyButton -Alt 'Buy now'

    return @"
<table border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; border-radius:22px; overflow:hidden; width:520px;" width="520">
    <tbody>
        <tr>
            <td style="padding:0;">
                $tagHtml
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr>
                            <td align="center" style="padding:18px 18px 8px 18px;"><a href="$($LeftProduct.Link)" target="_blank">$(Render-ImageTag -Asset $imageAsset -Alt $ImageAlt)</a></td>
                        </tr>
                        <tr>
                            <td style="padding:0 0 24px 0;">$(Render-TwoOfferColumns -LeftProduct $left -RightProduct $right)</td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Render-HorizontalCardBlock {
    param(
        $Context,
        $Product,
        [int]$CardWidth = 520
    )

    $imageAsset = Resolve-Asset -Context $Context -RelativePath $Product.ImageRel
    $buttonRel = if ($Product.ButtonRel) { $Product.ButtonRel } else { 'Buttons\Group 875.png' }
    $buttonAsset = Resolve-Asset -Context $Context -RelativePath $buttonRel
    $tagHtml = Render-ProductTag -Context $Context -Product $Product
    $priceHtml = Render-PriceBlock -Product $Product -Columns 2

    return @"
<table border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; border-radius:22px; overflow:hidden; width:${CardWidth}px;" width="$CardWidth">
    <tbody>
        <tr>
            <td style="padding:0;">
                $tagHtml
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr>
                            <td align="center" style="padding:22px 16px 18px 20px; vertical-align:middle;" valign="middle" width="240"><a href="$($Product.Link)" target="_blank">$(Render-ImageTag -Asset $imageAsset -Alt $Product.ImageAlt)</a></td>
                            <td style="padding:16px 24px 16px 4px; text-align:center; vertical-align:middle;" valign="middle">
                                <span style="color:#000000; font-family:$headingFont; font-size:16px; font-weight:bold; line-height:20px;">$($Product.NameHtml)</span><br>
                                <span style="color:#4C4C4C; font-family:$bodyFont; font-size:12px; line-height:16px;">$($Product.ModelHtml)</span><br><br>
                                $priceHtml<br><br>
                                <a href="$($Product.Link)" target="_blank">$(Render-ImageTag -Asset $buttonAsset -Alt $(if ($Product.ButtonAlt) { $Product.ButtonAlt } else { 'Buy now' }))</a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Render-DecorationRow {
    param(
        $Context,
        [string]$ImageRel,
        [string]$ImageAlt,
        [string]$Align = 'center'
    )

    if (-not $ImageRel) {
        return ''
    }

    $asset = Resolve-Asset -Context $Context -RelativePath $ImageRel
    return @"
<tr>
    <td style="padding:8px 20px 0 20px; text-align:$Align;">$(Render-ImageTag -Asset $asset -Alt $ImageAlt)</td>
</tr>
"@
}

function Render-SectionWrapper {
    param(
        [string]$InnerHtml,
        [string]$DecorationRow
    )

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:$sectionOuterBg; width:600px;" width="600">
    <tbody>
        <tr>
            <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
        <tr>
            <td style="padding:0 20px;">$InnerHtml</td>
        </tr>
        $DecorationRow
        <tr>
            <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
        </tr>
    </tbody>
</table>
"@
}

function Render-SupportCopySection {
    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr>
            <td style="padding:34px 28px 10px 28px; color:#000000; font-family:$bodyFont; font-size:22px; line-height:30px; text-align:center;">Get up to <strong>25% off</strong>, plus spend your rewards points<br>and we will match their value in cart</td>
        </tr>
        <tr>
            <td style="padding:0 28px 28px 28px; color:#000000; font-family:$bodyFont; font-size:14px; line-height:20px; text-align:center;">Applies on selected products.<br>Ts &amp; Cs apply.</td>
        </tr>
    </tbody>
</table>
"@
}

function Render-CouponSection {
    param(
        $Context,
        [string]$ClaimLink
    )

    $claimButton = Resolve-Asset -Context $Context -RelativePath 'Buttons\Group 1371.png'
    $couponImage = Resolve-Asset -Context $Context -RelativePath 'Dicount Price Tags\dbb3a78b74df69e063de7f89eb2d5899.png'

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr><td height="32" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#000000; font-family:$headingFont; font-size:36px; font-weight:bold; line-height:42px; text-align:center;">Your unique savings voucher is here!</td>
        </tr>
        <tr><td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#000000; font-family:$bodyFont; font-size:20px; line-height:28px; text-align:center;">Get a special discount on your next purchase with this offer!</td>
        </tr>
        <tr><td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;"><a href="$ClaimLink" target="_blank">$(Render-ImageTag -Asset $claimButton -Alt 'Claim now')</a></td>
        </tr>
        <tr><td height="32" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;"><a href="$ClaimLink" target="_blank">$(Render-ImageTag -Asset $couponImage -Alt 'Gift coupon 5 percent')</a></td>
        </tr>
        <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#000000; font-family:$headingFont; font-size:24px; font-weight:bold; line-height:30px; text-align:center;">Here&rsquo;s your code: SW01</td>
        </tr>
        <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#9A9A9A; font-family:$bodyFont; font-size:11px; line-height:16px; padding:0 60px 8px 60px; text-align:center;">*Discount applies only on selected products.<br>This offer cannot be combined with any other promotional code.</td>
        </tr>
        <tr><td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
    </tbody>
</table>
"@
}

function Render-TimerSection {
    param(
        $Context,
        [string]$ShopLink
    )

    $shopButton = Resolve-Asset -Context $Context -RelativePath 'Buttons\Group 1372.png'
    $timerUrl = 'https://samsungsa.online/timer/countdown.php?time=2026-05-31+22:59:00&width=450&height=120&boxColor=7588E7&font=BebasNeue&fontColor=ffffff&fontSize=90&xOffset=0&yOffset=85&labelOffsets=0.5,3.5,6,8.5'

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; width:600px;" width="600">
    <tbody>
        <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#000000; font-family:$headingFont; font-size:28px; font-weight:bold; line-height:36px; text-align:center;">Boost your rewards before<br>AI Week ends</td>
        </tr>
        <tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#000000; font-family:$bodyFont; font-size:18px; line-height:28px; text-align:center;">Receive extra savings when using your points<br>to purchase during AI Week!</td>
        </tr>
        <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#7588E7; border-radius:8px; width:470px;" width="470">
                    <tbody>
                        <tr>
                            <td style="padding:10px; text-align:center;"><img alt="AI Week countdown timer" border="0" height="120" src="$timerUrl" style="display:block; width:450px; height:120px; margin:auto; border:0;" width="450"></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;"><a href="$ShopLink" target="_blank">$(Render-ImageTag -Asset $shopButton -Alt 'Shop now')</a></td>
        </tr>
        <tr><td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
    </tbody>
</table>
"@
}

function Render-AccessoriesSection {
    param(
        $Context,
        [string]$AccessoriesLink
    )

    $bannerAsset = Resolve-Asset -Context $Context -RelativePath 'Dicount Price Tags\Group 1375.png'

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; width:600px;" width="600">
    <tbody>
        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;"><a href="$AccessoriesLink" target="_blank">$(Render-ImageTag -Asset $bannerAsset -Alt 'Save up to 25 percent on selected accessories')</a></td>
        </tr>
        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
    </tbody>
</table>
"@
}

function Render-SmartThingsSection {
    param(
        $Context,
        [string]$SmartThingsLink
    )

    $learnMoreButton = Resolve-Asset -Context $Context -RelativePath 'Buttons\Group 1374.png'
    $smartThingsIcon = Resolve-Asset -Context $Context -RelativePath 'SmartThings Icon\Image 208.png'

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#DCE8FA; width:600px;" width="600">
    <tbody>
        <tr>
            <td style="padding:28px 34px 22px 34px;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr>
                            <td style="vertical-align:middle;" valign="middle" width="250">
                                <span style="color:#000000; font-family:$headingFont; font-size:28px; font-weight:bold; line-height:36px;">A new way to<br>enjoy your home</span><br><br>
                                <span style="color:#000000; font-family:$bodyFont; font-size:18px; line-height:28px;">SmartThings connects your appliances<br>to help automate your everyday routine.</span><br><br>
                                <a href="$SmartThingsLink" target="_blank">$(Render-ImageTag -Asset $learnMoreButton -Alt 'Learn more')</a>
                            </td>
                            <td width="12"></td>
                            <td align="center" style="text-align:center; vertical-align:bottom;" valign="bottom" width="270"><a href="$SmartThingsLink" target="_blank">$(Render-ImageTag -Asset $smartThingsIcon -Alt 'SmartThings')</a></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Render-LiveShoppingSection {
    param(
        $Context,
        [string]$LiveLink
    )

    $podAsset = Resolve-Asset -Context $Context -RelativePath 'Live Shopping Event Pod\Group 1366.png'

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;"><a href="$LiveLink" target="_blank">$(Render-ImageTag -Asset $podAsset -Alt 'Live Shopping Event')</a></td>
        </tr>
        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
    </tbody>
</table>
"@
}

function Render-DealsValidSection {
    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr>
            <td style="color:#000000; font-family:$bodyFont; font-size:16px; line-height:24px; padding:0 20px 24px 20px; text-align:center;">Deals Valid until 31 May 2026</td>
        </tr>
    </tbody>
</table>
"@
}

function Get-FooterHtml {
    $footerHtml = Get-Content -LiteralPath $footerPath -Raw -Encoding UTF8
    $footerHtml = $footerHtml -replace 'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^"]*"', 'href="YYYYY"'
    $footerHtml = $footerHtml -replace '©', '&copy;'
    return $footerHtml
}

function Build-DocumentHtml {
    param(
        [string[]]$Sections,
        [string]$FooterHtml,
        [string]$PreheaderText
    )

    $contentHtml = Join-Html $Sections
    return @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>Samsung South Africa</title>
    </head>
    <body style="background-color:#555555;"><!-- Preheader START =========================================================================== --><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> $PreheaderText </span> <!-- Preheader END =========================================================================== -->
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
$contentHtml
$FooterHtml
"@
}

function Write-MailerHtml {
    param(
        $Context,
        [string]$Html
    )

    $htmlPath = Join-Path $Context.OutputDir $Context.HtmlFileName
    Set-Content -LiteralPath $htmlPath -Value $Html -Encoding UTF8
    return $htmlPath
}

function Write-MailerZip {
    param($Context)

    $zipPath = Join-Path $Context.OutputDir ([System.IO.Path]::GetFileNameWithoutExtension($Context.HtmlFileName) + '.zip')
    $zipStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::Create)
    $archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create, $false)

    try {
        $filesToZip = Get-ChildItem -LiteralPath $Context.OutputDir -File | Where-Object { $_.Extension -ne '.zip' }
        foreach ($file in $filesToZip) {
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $file.Name) | Out-Null
        }
    }
    finally {
        $archive.Dispose()
        $zipStream.Dispose()
    }

    $archiveRead = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $expectedCount = (Get-ChildItem -LiteralPath $Context.OutputDir -File | Where-Object { $_.Extension -ne '.zip' }).Count
        if ($archiveRead.Entries.Count -ne $expectedCount) {
            throw "Zip validation failed for $($Context.MailerName): expected $expectedCount files, found $($archiveRead.Entries.Count)"
        }
    }
    finally {
        $archiveRead.Dispose()
    }

    return $zipPath
}

function Build-StandardProduct {
    param(
        [string]$NameHtml,
        [string]$ModelHtml,
        [string]$PriceHtml,
        [string]$Link,
        [string]$ImageRel,
        [string]$ImageAlt,
        [string]$TagRel,
        [string]$TagAlt,
        [string]$TagTextHtml,
        [string]$NowPriceHtml,
        [string]$SavePriceHtml
    )

    return [ordered]@{
        NameHtml = $NameHtml
        ModelHtml = $ModelHtml
        PriceHtml = $PriceHtml
        Link = $Link
        ImageRel = $ImageRel
        ImageAlt = $ImageAlt
        TagRel = $TagRel
        TagAlt = $TagAlt
        TagTextHtml = $TagTextHtml
        NowPriceHtml = $NowPriceHtml
        SavePriceHtml = $SavePriceHtml
        ButtonRel = 'Buttons\Group 922.png'
        ButtonAlt = 'Buy now'
    }
}

$downloadLink = 'https://www.samsung.com/za/apps/samsung-shop-app/'
$shopLink = 'https://www.samsung.com/za/offer/samsung-week/'
$tv75Link = 'https://www.samsung.com/za/tvs/neo-qled/qn1ef-75-inch-neo-qled-4k-mini-led-smart-tv-qa75qn1efauxxa/'
$tv65Link = 'https://www.samsung.com/za/tvs/neo-qled/qn1ef-65-inch-neo-qled-4k-mini-led-smart-tv-qa65qn1efauxxa/'
$monitorLink = 'https://www.samsung.com/za/monitors/gaming/odyssey-g5-g55c-32-inch-165hz-curved-qhd-ls32cg552eaxxa/'
$soundbarLink = 'https://www.samsung.com/za/audio-devices/soundbar/q990f-black-hw-q990f-xa/'
$s26UltraLink = 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/'
$s25FeLink = 'https://www.samsung.com/za/smartphones/galaxy-s25/buy/'
$tabS10FeLink = 'https://www.samsung.com/za/tablets/galaxy-tab-s/galaxy-tab-s10-fe-blue-126gb-sm-x520nlbaafa/'
$fridge564Link = 'https://www.samsung.com/za/refrigerators/side-by-side/rs4000dc-sbside-with-large-capacity-rs4000dc-side-by-side-with-large-capacity-564l-black-rs57dg4000b4fa/'
$fridge617Link = 'https://www.samsung.com/za/refrigerators/side-by-side/refrigerator-sbs-rs90f-basic-617l-black-rs70f65k2ffa/'
$washerLink = 'https://www.samsung.com/za/washers-and-dryers/washing-machines/ww7400t-11kg-black-ww11cgp44dsbfa/'
$claimLink = 'https://www.samsung.com/za/offer/samsung-week/'
$accessoriesLink = 'https://www.samsung.com/za/accessories/'
$smartThingsLink = 'https://www.samsung.com/za/smartthings/'
$footerHtml = Get-FooterHtml

$mailerBaseName = 'ZAS26088158  2026_SSA Retainer_Digital_CRM Estore _ AI Week T2 _ Mailer _ W21'
$context = New-MailerContext -MailerName $mailerBaseName -DesignFileName ($mailerBaseName + '.jpg')

$appBarAsset = Resolve-Asset -Context $context -RelativePath 'Shop App\Group 1376.png'
$heroAsset = Crop-DesignAsset -Context $context -OutputName 'hero_block.png' -X 0 -Y 80 -Width 600 -Height 790
$heroSection = @"
<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr>
            <td>$(Render-LinkedImage -Asset $appBarAsset -Href $downloadLink -Alt 'Samsung Shop App')</td>
        </tr>
        <tr>
            <td>$(Render-LinkedImage -Asset $heroAsset -Href $shopLink -Alt 'AI Week hero')</td>
        </tr>
    </tbody>
</table>
"@

$tvLeft = [ordered]@{
    NameHtml = '75&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
    ModelHtml = 'QA75QN1EFAUXXA'
    Link = $tv75Link
    NowPriceHtml = 'R19 999'
    SavePriceHtml = 'R4 800'
}
$tvRight = [ordered]@{
    NameHtml = '65&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
    ModelHtml = 'QA65QN1EFAUXXA'
    Link = $tv65Link
    NowPriceHtml = 'R14 999'
    SavePriceHtml = 'R2 800'
}
$monitor = Build-StandardProduct -NameHtml '32&rdquo; Odyssey G55C QHD, 1ms<br>MPRT, 165Hz Gaming Monitor' -ModelHtml 'LS32CG552EAXXA' -Link $monitorLink -ImageRel 'Products\Mask Group 36.png' -ImageAlt '32 inch Odyssey G55C gaming monitor' -NowPriceHtml 'R5 199' -SavePriceHtml 'R800'
$soundbar = Build-StandardProduct -NameHtml 'Q-Series Soundbar 11.1.4 ch<br>Subwoofer &amp; Rear Speaker' -ModelHtml 'HW-Q990F/XA' -Link $soundbarLink -ImageRel 'Products\Mask Group 14.png' -ImageAlt 'Q-Series Soundbar 11.1.4 channel' -NowPriceHtml 'R17 999' -SavePriceHtml 'R3 999'

$topInner = Join-Html @(
    (Render-TVWideBlock -Context $context -TagRel 'Dicount Price Tags\Group 927.png' -TagAlt 'Earn 5 percent bonus Samsung Rewards' -ImageRel 'Products\Mask Group 32.png' -ImageAlt 'Neo QLED TV' -LeftProduct $tvLeft -RightProduct $tvRight),
    '<table border="0" cellpadding="0" cellspacing="0" width="520"><tbody><tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>',
    (Render-GridBlock -Context $context -Cards @($monitor, $soundbar) -Columns 2)
)
$topSection = Render-SectionWrapper -InnerHtml $topInner -DecorationRow (Render-DecorationRow -Context $context -ImageRel 'Images\Image 198.png' -ImageAlt 'AI Week TV character' -Align 'center')

$s26Ultra = Build-StandardProduct -NameHtml 'Galaxy S26 Ultra (512GB)<br>Samsung.com Exclusive' -ModelHtml 'SM-S948BZSOAFA' -PriceHtml 'R35 999' -Link $s26UltraLink -ImageRel 'Products\Mask Group 28.png' -ImageAlt 'Galaxy S26 Ultra 512GB' -TagRel 'Dicount Price Tags\Group 925.png' -TagAlt 'Sign in or use code LSV50 to save up to R5 000 off cart'
$s25Fe = Build-StandardProduct -NameHtml 'Galaxy S25 FE (256GB)' -ModelHtml 'SM-S731BDBVAFA' -PriceHtml 'R15 999' -Link $s25FeLink -ImageRel 'Products\Group 921.png' -ImageAlt 'Galaxy S25 FE 256GB' -TagRel 'Dicount Price Tags\Group 975.png' -TagAlt 'Sign in and get up to R4 500 off cart'
$tabS10Fe = Build-StandardProduct -NameHtml 'Galaxy Tab S10 FE Wi-Fi' -ModelHtml 'SM-X520NLBAAFA' -PriceHtml 'R11 499' -Link $tabS10FeLink -ImageRel 'Products\Mask Group 29.png' -ImageAlt 'Galaxy Tab S10 FE Wi-Fi' -TagRel 'Dicount Price Tags\Group 976.png' -TagAlt 'Sign in and get up to R2 296 off cart'

$mobileInner = Join-Html @(
    (Render-GridBlock -Context $context -Cards @($s26Ultra, $s25Fe) -Columns 2),
    '<table border="0" cellpadding="0" cellspacing="0" width="520"><tbody><tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>',
    (Render-HorizontalCardBlock -Context $context -Product $tabS10Fe)
)
$mobileSection = Render-SectionWrapper -InnerHtml $mobileInner -DecorationRow (Render-DecorationRow -Context $context -ImageRel 'Images\Image 203.png' -ImageAlt 'AI Week mobile character' -Align 'center')

$fridge564 = Build-StandardProduct -NameHtml '564L Side-by-Side<br>Refrigerator' -ModelHtml 'RS57DG4000B4FA' -Link $fridge564Link -ImageRel 'Products\Mask Group 37.png' -ImageAlt '564L side-by-side refrigerator' -NowPriceHtml 'R14 999'
$fridge617 = Build-StandardProduct -NameHtml '617L Side-by-Side<br>Refrigerator' -ModelHtml 'RS70F65K2FFA' -Link $fridge617Link -ImageRel 'Products\Mask Group 30.png' -ImageAlt '617L side-by-side refrigerator' -NowPriceHtml 'R23 999' -SavePriceHtml 'R3 000'
$washer = Build-StandardProduct -NameHtml '11kg AI Front Load with<br>EcoBubble&trade;' -ModelHtml 'WW11CGP44DSBFA' -Link $washerLink -ImageRel 'Products\Mask Group 31.png' -ImageAlt '11kg AI front load washer' -NowPriceHtml 'R10 999' -SavePriceHtml 'R1 000'

$applianceSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $context -Cards @($fridge564, $fridge617, $washer) -Columns 3) -DecorationRow (Render-DecorationRow -Context $context -ImageRel 'Images\Image 202.png' -ImageAlt 'AI Week appliance characters' -Align 'center')

$sections = @(
    $heroSection,
    (Render-SupportCopySection),
    $topSection,
    $mobileSection,
    $applianceSection,
    (Render-CouponSection -Context $context -ClaimLink $claimLink),
    (Render-AccessoriesSection -Context $context -AccessoriesLink $accessoriesLink),
    (Render-TimerSection -Context $context -ShopLink $shopLink),
    (Render-SmartThingsSection -Context $context -SmartThingsLink $smartThingsLink),
    (Render-DealsValidSection)
)

$html = Build-DocumentHtml -Sections $sections -FooterHtml $footerHtml -PreheaderText 'Last chance to get the AI Week offers!'
$htmlPath = Write-MailerHtml -Context $context -Html $html
$zipPath = Write-MailerZip -Context $context

[PSCustomObject]@{
    Mailer = $mailerBaseName
    Html = $htmlPath
    Zip = $zipPath
} | Format-Table -AutoSize | Out-String