$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

$headingFont = 'Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$bodyFont = 'avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$sectionOuterBg = '#E7EBF7'

$jobRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetRoot = Join-Path $jobRoot 'ZAS26088135 _ Estore _ Samsung AI Week T1 _ Mailer + Banners _ W21_Assets'
$livePodRoot = Join-Path $jobRoot 'Live Shopping Event Pod'
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
        return @"
<span style="color:#4C4C4C; font-family:$bodyFont; font-size:13px; line-height:18px;">Now <span style="color:#000000; font-family:$headingFont; font-size:${priceSize}px; font-weight:bold; line-height:${priceSize}px;">$($Product.NowPriceHtml)</span></span><br>
<span style="color:#4C4C4C; font-family:$bodyFont; font-size:13px; line-height:18px;">Save <span style="color:#000000; font-family:$headingFont; font-size:17px; font-weight:bold; line-height:18px;">$($Product.SavePriceHtml)</span></span>
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

function Render-TwoOfferColumns {
    param(
        $LeftProduct,
        $RightProduct
    )

    return @"
<table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tbody>
        <tr>
            <td align="center" style="padding:0 14px 0 18px; vertical-align:top;" valign="top" width="240">
                <span style="color:#000000; font-family:$headingFont; font-size:14px; font-weight:bold; line-height:20px;">$($LeftProduct.NameHtml)</span><br>
                <span style="color:#4C4C4C; font-family:$bodyFont; font-size:11px; line-height:14px;">$($LeftProduct.ModelHtml)</span><br>
                <span style="color:#000000; font-family:$headingFont; font-size:20px; font-weight:bold; line-height:26px;">$($LeftProduct.PriceHtml)</span><br><br>
                <a href="$($LeftProduct.Link)" target="_blank">$($LeftProduct.ButtonHtml)</a>
            </td>
            <td style="background-color:#D8D8D8; width:1px; font-size:1px; line-height:1px;" width="1">&nbsp;</td>
            <td align="center" style="padding:0 18px 0 14px; vertical-align:top;" valign="top" width="239">
                <span style="color:#000000; font-family:$headingFont; font-size:14px; font-weight:bold; line-height:20px;">$($RightProduct.NameHtml)</span><br>
                <span style="color:#4C4C4C; font-family:$bodyFont; font-size:11px; line-height:14px;">$($RightProduct.ModelHtml)</span><br>
                <span style="color:#000000; font-family:$headingFont; font-size:20px; font-weight:bold; line-height:26px;">$($RightProduct.PriceHtml)</span><br><br>
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
    $buyButton = Resolve-Asset -Context $Context -RelativePath 'Buttons\Group 875.png'
    $left = [ordered]@{}
    $left.NameHtml = $LeftProduct.NameHtml
    $left.ModelHtml = $LeftProduct.ModelHtml
    $left.PriceHtml = $LeftProduct.PriceHtml
    $left.Link = $LeftProduct.Link
    $left.ButtonHtml = Render-ImageTag -Asset $buyButton -Alt 'Buy now'
    $right = [ordered]@{}
    $right.NameHtml = $RightProduct.NameHtml
    $right.ModelHtml = $RightProduct.ModelHtml
    $right.PriceHtml = $RightProduct.PriceHtml
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
            <td style="padding:34px 28px 28px 28px; color:#000000; font-family:$bodyFont; font-size:22px; line-height:30px; text-align:center;">Get up to <strong>25% off</strong>, plus spend your rewards points<br>and we will match their value in cart</td>
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

    $claimButton = Resolve-Asset -Context $Context -RelativePath 'Buttons\Group 881.png'
    $couponImage = Resolve-Asset -Context $Context -RelativePath 'Gift Coupon\dbb3a78b74df69e063de7f89eb2d5899.png'

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

    $shopButton = Resolve-Asset -Context $Context -RelativePath 'Buttons\Group 882.png'
    $timerUrl = 'https://samsungsa.online/timer/countdown.php?time=2026-05-31+22:59:00&width=450&height=120&boxColor=7588E7&font=BebasNeue&fontColor=ffffff&fontSize=90&xOffset=0&yOffset=85&labelOffsets=0.5,3.5,6,8.5'

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4; width:600px;" width="600">
    <tbody>
        <tr><td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#000000; font-family:$headingFont; font-size:36px; font-weight:bold; line-height:42px; text-align:center;">Your unique savings voucher is here!</td>
        </tr>
        <tr><td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="color:#000000; font-family:$bodyFont; font-size:20px; line-height:28px; text-align:center;">Get a special discount on your next purchase with this offer!</td>
        </tr>
        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#7588E7; width:540px;" width="540">
                    <tbody>
                        <tr>
                            <td style="padding:10px; text-align:center;"><img alt="AI Week countdown timer" border="0" height="120" src="$timerUrl" style="display:block; width:450px; height:120px; margin:auto; border:0;" width="450"></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
        <tr>
            <td style="text-align:center;"><a href="$ShopLink" target="_blank">$(Render-ImageTag -Asset $shopButton -Alt 'Shop now')</a></td>
        </tr>
        <tr><td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
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
        ButtonRel = 'Buttons\Group 875.png'
        ButtonAlt = 'Buy now'
    }
}

$downloadLink = 'https://www.samsung.com/za/apps/samsung-shop-app/'
$shopLink = 'https://www.samsung.com/za/'
$claimLink = 'https://www.samsung.com/za/'
$liveLink = 'https://www.samsung.com/za/samsung-live/'
$footerHtml = Get-FooterHtml

$mailers = @(
    [ordered]@{
        MailerName = 'DA Owner'
        DesignFileName = 'DA Owner.jpg'
        HeroAlt = 'AI Week hero'
        HeroCropHeight = 850
        Sections = {
            param($Context)

            $topCards = @(
                (Build-StandardProduct -NameHtml 'Galaxy S26' -ModelHtml 'SM-S942BZVPAFA' -PriceHtml 'R20 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26/buy/' -ImageRel 'Products\DA Owner\Group 13.png' -ImageAlt 'Galaxy S26' -TagRel 'Discount Tags\Group 923.png' -TagAlt 'Sign in & get up to R1 000 off'),
                (Build-StandardProduct -NameHtml 'Galaxy Watch8' -ModelHtml 'SM-L320NZSAXFA' -PriceHtml 'R6 999' -Link 'https://www.samsung.com/za/watches/galaxy-watch/galaxy-watch8-40mm-silver-bluetooth-sm-l320nzsaxfa/buy/?modelCode=SM-L320NZSAXFA' -ImageRel 'Products\DA Owner\Mask Group 3.png' -ImageAlt 'Galaxy Watch8' -TagRel 'Discount Tags\Group 924.png' -TagAlt 'Sign in & get up to 14% off'),
                (Build-StandardProduct -NameHtml 'Galaxy S26 Ultra' -ModelHtml 'SM-S948BZSOAFA' -PriceHtml 'R35 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/' -ImageRel 'Products\DA Owner\Mask Group 4.png' -ImageAlt 'Galaxy S26 Ultra' -TagRel 'Discount Tags\Group 925.png' -TagAlt 'Use code LSV50 to save up to R5 000 off'),
                (Build-StandardProduct -NameHtml 'Galaxy Tab S10 Lite Wi-Fi' -ModelHtml 'SM-X400NZSOAFA' -PriceHtml 'R8 799' -Link 'https://www.samsung.com/za/tablets/galaxy-tab-s/galaxy-tab-s10-lite-gray-128gb-sm-x400nzaaafa/' -ImageRel 'Products\DA Owner\Mask Group 5.png' -ImageAlt 'Galaxy Tab S10 Lite Wi-Fi' -TagRel 'Discount Tags\Group 926.png' -TagAlt 'Sign in & get up to 20% off')
            )

            $tvLeft = [ordered]@{
                NameHtml = '55&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA55QN90FAUXXA'
                PriceHtml = 'R19 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-55-inch-neo-qled-4k-mini-led-smart-tv-qa55qn90fauxxa/'
            }
            $tvRight = [ordered]@{
                NameHtml = '65&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA65QN90FAUXXA'
                PriceHtml = 'R34 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-65-inch-neo-qled-4k-mini-led-smart-tv-qa65qn90fauxxa/'
            }

            $washer = Build-StandardProduct -NameHtml '12kg Bespoke AI Washer Dryer<br>with EcoBubble&trade;' -ModelHtml 'WD12BB944DGBFA' -PriceHtml 'R15 999' -Link 'https://www.samsung.com/za/washers-and-dryers/washer-dryer-combo/wd9400b-washer-dryer-combo-ai-ecobubble-ai-wash-quickdrive-12kg-plus-8kg-black-wd12bb944dgbfa/' -ImageRel 'Products\DA Owner\Mask Group 2.png' -ImageAlt '12kg Bespoke AI Washer Dryer' -TagRel 'Discount Tags\Group 928.png' -TagAlt 'Spend your Samsung Rewards and we will match their value in cart'
            $fridge = Build-StandardProduct -NameHtml '594L Bespoke AI Side-by-Side<br>Refrigerator AI Home 9&quot; Screen' -ModelHtml 'RS90F64D2FFA' -Link 'https://www.samsung.com/za/refrigerators/side-by-side/refrigerator-sbs-9-inch-ai-home-594l-black-rs90f64d2ffa/' -ImageRel 'Products\DA Owner\Mask Group 33.png' -ImageAlt '594L Bespoke AI Side-by-Side Refrigerator' -NowPriceHtml 'R39 999' -SavePriceHtml 'R2 999'

            $firstSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $Context -Cards $topCards -Columns 2) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 25.png' -ImageAlt 'AI Week character' -Align 'center')
            $tvSection = Render-SectionWrapper -InnerHtml (Render-TVWideBlock -Context $Context -TagRel 'Discount Tags\Group 983.png' -TagAlt 'Earn 5% bonus Samsung Rewards' -ImageRel 'Products\DA Owner\Mask Group 32.png' -ImageAlt 'Neo QLED TV' -LeftProduct $tvLeft -RightProduct $tvRight) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 169.png' -ImageAlt 'AI Week TV character' -Align 'left')
            $applianceSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $Context -Cards @($washer, $fridge) -Columns 2) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image -1.png' -ImageAlt 'AI Week appliance characters' -Align 'center')

            return @($firstSection, $tvSection, $applianceSection, (Render-CouponSection -Context $Context -ClaimLink $claimLink), (Render-TimerSection -Context $Context -ShopLink $shopLink))
        }
    },
    [ordered]@{
        MailerName = 'MX Owner'
        DesignFileName = 'MX Owner.jpg'
        HeroAlt = 'AI Week hero'
        HeroCropHeight = 850
        Sections = {
            param($Context)

            $tvLeft = [ordered]@{
                NameHtml = '55&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA55QN90FAUXXA'
                PriceHtml = 'R19 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-55-inch-neo-qled-4k-mini-led-smart-tv-qa55qn90fauxxa/'
            }
            $tvRight = [ordered]@{
                NameHtml = '65&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA65QN90FAUXXA'
                PriceHtml = 'R34 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-65-inch-neo-qled-4k-mini-led-smart-tv-qa65qn90fauxxa/'
            }
            $monitor = Build-StandardProduct -NameHtml '34&rdquo; Odyssey G55T UWQHD<br>165Hz Gaming Monitor' -ModelHtml 'LC34G55TWWPXEN' -Link 'https://www.samsung.com/za/monitors/gaming/odyssey-g5-34-inch-165hz-curved-ultra-wqhd-lc34g55twwpxen/' -ImageRel 'Products\MX Owner\Mask Group 34.png' -ImageAlt '34 inch Odyssey G55T monitor' -NowPriceHtml 'R8 799' -SavePriceHtml 'R2 200'
            $heroCards = @(
                (Build-StandardProduct -NameHtml 'Galaxy S26 Ultra' -ModelHtml 'SM-S948BZSOAFA' -PriceHtml 'R35 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/' -ImageRel 'Products\MX Owner\Mask Group 6.png' -ImageAlt 'Galaxy S26 Ultra' -TagRel 'Discount Tags\Group 932.png' -TagAlt 'Use code LSV50 to save up to R5 000 off'),
                (Build-StandardProduct -NameHtml 'Galaxy S26' -ModelHtml 'SM-S942BZVPAFA' -PriceHtml 'R20 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26/buy/' -ImageRel 'Products\MX Owner\Group 891.png' -ImageAlt 'Galaxy S26' -TagRel 'Discount Tags\Group 933.png' -TagAlt 'Sign in & get up to R1 000 off'),
                (Build-StandardProduct -NameHtml 'Galaxy Watch8' -ModelHtml 'SM-L320NZSAXFA' -PriceHtml 'R6 999' -Link 'https://www.samsung.com/za/watches/galaxy-watch/galaxy-watch8-40mm-silver-bluetooth-sm-l320nzsaxfa/buy/?modelCode=SM-L320NZSAXFA' -ImageRel 'Products\MX Owner\Mask Group 3.png' -ImageAlt 'Galaxy Watch8' -TagRel 'Discount Tags\Group 934.png' -TagAlt 'Sign in & get up to 14% off')
            )
            $applianceCards = @(
                (Build-StandardProduct -NameHtml '594L Bespoke AI<br>Side-by-Side Refrigerator<br>AI Home 9&quot; Screen' -ModelHtml 'RS90F64D2FFA' -Link 'https://www.samsung.com/za/refrigerators/side-by-side/refrigerator-sbs-9-inch-ai-home-594l-black-rs90f64d2ffa/' -ImageRel 'Products\MX Owner\Mask Group 35.png' -ImageAlt '594L Bespoke AI Side-by-Side Refrigerator' -NowPriceHtml 'R32 999' -SavePriceHtml 'R10 000'),
                (Build-StandardProduct -NameHtml '617L Side-by-Side<br>Refrigerator' -ModelHtml 'RS70F65K2FFA' -Link 'https://www.samsung.com/za/refrigerators/side-by-side/refrigerator-sbs-rs90f-basic-617l-black-rs70f65k2ffa/' -ImageRel 'Products\MX Owner\Mask Group 9.png' -ImageAlt '617L Side-by-Side Refrigerator' -NowPriceHtml 'R23 999' -SavePriceHtml 'R3 000'),
                (Build-StandardProduct -NameHtml '11kg AI Front Load with<br>EcoBubble&trade;' -ModelHtml 'WW11CGP44DSBFA' -Link 'https://www.samsung.com/za/washers-and-dryers/washing-machines/ww7400t-11kg-black-ww11cgp44dsbfa/' -ImageRel 'Products\MX Owner\Mask Group 8.png' -ImageAlt '11kg AI Front Load washer' -NowPriceHtml 'R10 999' -SavePriceHtml 'R1 000')
            )

            $topInner = Join-Html @(
                (Render-TVWideBlock -Context $Context -TagRel 'Discount Tags\Group 983.png' -TagAlt 'Earn 5% bonus Samsung Rewards' -ImageRel 'Products\MX Owner\Mask Group 32.png' -ImageAlt 'Neo QLED TV' -LeftProduct $tvLeft -RightProduct $tvRight),
                '<table border="0" cellpadding="0" cellspacing="0" width="520"><tbody><tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>',
                (Render-HorizontalCardBlock -Context $Context -Product $monitor)
            )

            $topSection = Render-SectionWrapper -InnerHtml $topInner -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 169.png' -ImageAlt 'AI Week TV character' -Align 'left')
            $mobileSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $Context -Cards $heroCards -Columns 3) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 25.png' -ImageAlt 'AI Week character' -Align 'center')
            $applianceSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $Context -Cards $applianceCards -Columns 3) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 6.png' -ImageAlt 'AI Week appliance characters' -Align 'center')

            return @($topSection, $mobileSection, $applianceSection, (Render-CouponSection -Context $Context -ClaimLink $claimLink), (Render-TimerSection -Context $Context -ShopLink $shopLink))
        }
    },
    [ordered]@{
        MailerName = 'Remaining Audience'
        DesignFileName = 'Remaining Audience.jpg'
        HeroAlt = 'AI Week hero'
        HeroCropHeight = 780
        Sections = {
            param($Context)

            $tvLeft = [ordered]@{
                NameHtml = '55&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA55QN90FAUXXA'
                PriceHtml = 'R19 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-55-inch-neo-qled-4k-mini-led-smart-tv-qa55qn90fauxxa/'
            }
            $tvRight = [ordered]@{
                NameHtml = '65&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA65QN90FAUXXA'
                PriceHtml = 'R34 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-65-inch-neo-qled-4k-mini-led-smart-tv-qa65qn90fauxxa/'
            }
            $monitor = Build-StandardProduct -NameHtml '34&rdquo; Odyssey G55T UWQHD<br>165Hz Gaming Monitor' -ModelHtml 'LC34G55TWWPXEN' -Link 'https://www.samsung.com/za/monitors/gaming/odyssey-g5-34-inch-165hz-curved-ultra-wqhd-lc34g55twwpxen/' -ImageRel 'Products\Remaining Audience\Mask Group 36.png' -ImageAlt '34 inch Odyssey G55T monitor' -NowPriceHtml 'R8 799' -SavePriceHtml 'R2 200'
            $soundbarQ990 = Build-StandardProduct -NameHtml 'Q-Series Soundbar 11.1.4 ch<br>Subwoofer &amp; Rear Speaker' -ModelHtml 'HW-Q990F/XA' -Link 'https://www.samsung.com/za/audio-devices/soundbar/q990f-black-hw-q990f-xa/' -ImageRel 'Products\Remaining Audience\Mask Group 14.png' -ImageAlt 'Q-Series Soundbar 11.1.4' -NowPriceHtml 'R17 999' -SavePriceHtml 'R3 999'
            $applianceCards = @(
                (Build-StandardProduct -NameHtml '594L Bespoke AI<br>Side-by-Side Refrigerator<br>AI Home 9&quot; Screen' -ModelHtml 'RS90F64D2FFA' -Link 'https://www.samsung.com/za/refrigerators/side-by-side/refrigerator-sbs-9-inch-ai-home-594l-black-rs90f64d2ffa/' -ImageRel 'Products\Remaining Audience\Mask Group 35.png' -ImageAlt '594L Bespoke AI Side-by-Side Refrigerator' -NowPriceHtml 'R32 999' -SavePriceHtml 'R10 000'),
                (Build-StandardProduct -NameHtml '617L Side-by-Side<br>Refrigerator' -ModelHtml 'RS70F65K2FFA' -Link 'https://www.samsung.com/za/refrigerators/side-by-side/refrigerator-sbs-rs90f-basic-617l-black-rs70f65k2ffa/' -ImageRel 'Products\Remaining Audience\Mask Group 30.png' -ImageAlt '617L Side-by-Side Refrigerator' -NowPriceHtml 'R23 999' -SavePriceHtml 'R3 000'),
                (Build-StandardProduct -NameHtml '11kg AI Front Load with<br>EcoBubble&trade;' -ModelHtml 'WW11CGP44DSBFA' -Link 'https://www.samsung.com/za/washers-and-dryers/washing-machines/ww7400t-11kg-black-ww11cgp44dsbfa/' -ImageRel 'Products\Remaining Audience\Mask Group 31.png' -ImageAlt '11kg AI Front Load washer' -NowPriceHtml 'R10 999' -SavePriceHtml 'R1 000')
            )
            $s26Ultra = Build-StandardProduct -NameHtml 'Galaxy S26 Ultra' -ModelHtml 'SM-S948BZSOAFA' -PriceHtml 'R35 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/' -ImageRel 'Products\Remaining Audience\Mask Group 4.png' -ImageAlt 'Galaxy S26 Ultra' -TagRel 'Discount Tags\Group 932.png' -TagAlt 'Use code LSV50 to save up to R5 000 off'
            $s26 = Build-StandardProduct -NameHtml 'Galaxy S26' -ModelHtml 'SM-S942BZVPAFA' -PriceHtml 'R20 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26/buy/' -ImageRel 'Products\Remaining Audience\Group 13.png' -ImageAlt 'Galaxy S26' -TagRel 'Discount Tags\Group 933.png' -TagAlt 'Sign in & get up to R1 000 off'
            $tabS11 = Build-StandardProduct -NameHtml 'Galaxy Tab S11 Ultra' -ModelHtml 'SM-X936BZAAAFA' -PriceHtml 'R31 599' -Link 'https://www.samsung.com/za/tablets/galaxy-tab-s/galaxy-tab-s11-ultra-gray-256gb-sm-x936bzaaafa/' -ImageRel 'Products\Remaining Audience\Mask Group 29.png' -ImageAlt 'Galaxy Tab S11 Ultra' -TagTextHtml 'Sign in &amp; get up to<br><strong>R4 600 off</strong>'

            $topInner = Join-Html @(
                (Render-TVWideBlock -Context $Context -TagRel 'Discount Tags\Group 983.png' -TagAlt 'Earn 5% bonus Samsung Rewards' -ImageRel 'Products\Remaining Audience\Mask Group 32.png' -ImageAlt 'Neo QLED TV' -LeftProduct $tvLeft -RightProduct $tvRight),
                '<table border="0" cellpadding="0" cellspacing="0" width="520"><tbody><tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>',
                (Render-GridBlock -Context $Context -Cards @($monitor, $soundbarQ990) -Columns 2)
            )
            $topSection = Render-SectionWrapper -InnerHtml $topInner -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 169.png' -ImageAlt 'AI Week TV character' -Align 'left')
            $applianceSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $Context -Cards $applianceCards -Columns 3) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 6.png' -ImageAlt 'AI Week appliance characters' -Align 'center')
            $featuredInner = Join-Html @(
                (Render-GridBlock -Context $Context -Cards @($s26Ultra, $s26) -Columns 2),
                '<table border="0" cellpadding="0" cellspacing="0" width="520"><tbody><tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>',
                (Render-HorizontalCardBlock -Context $Context -Product $tabS11)
            )
            $featuredSection = Render-SectionWrapper -InnerHtml $featuredInner -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 25.png' -ImageAlt 'AI Week character' -Align 'center')

            return @($topSection, $applianceSection, $featuredSection, (Render-TimerSection -Context $Context -ShopLink $shopLink), (Render-LiveShoppingSection -Context $Context -LiveLink $liveLink))
        }
    },
    [ordered]@{
        MailerName = 'VD Owner'
        DesignFileName = 'VD Owner.jpg'
        HeroAlt = 'AI Week hero'
        HeroCropHeight = 850
        Sections = {
            param($Context)

            $mobileCards = @(
                (Build-StandardProduct -NameHtml 'Galaxy S26 Ultra' -ModelHtml 'SM-S948BZSOAFA' -PriceHtml 'R35 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/' -ImageRel 'Products\VD Owner\Mask Group 6.png' -ImageAlt 'Galaxy S26 Ultra' -TagRel 'Discount Tags\Group 932.png' -TagAlt 'Use code LSV50 to save up to R5 000 off'),
                (Build-StandardProduct -NameHtml 'Galaxy S26' -ModelHtml 'SM-S942BZVPAFA' -PriceHtml 'R20 999' -Link 'https://www.samsung.com/za/smartphones/galaxy-s26/buy/' -ImageRel 'Products\VD Owner\Group 891.png' -ImageAlt 'Galaxy S26' -TagRel 'Discount Tags\Group 933.png' -TagAlt 'Sign in & get up to R1 000 off'),
                (Build-StandardProduct -NameHtml 'Galaxy Buds4 Pro<br>(&ldquo;Samsung.com only&rdquo;)' -ModelHtml 'SM-R640NZDAXFA' -PriceHtml 'R4 999' -Link 'https://www.samsung.com/za/audio-sound/galaxy-buds/galaxy-buds4-pro-pink-gold-sm-r640nzdaxfa/' -ImageRel 'Products\VD Owner\Mask Group 21.png' -ImageAlt 'Galaxy Buds4 Pro' -TagRel 'Discount Tags\Group 950.png' -TagAlt 'Sign in & get up to R500 off')
            )
            $applianceCards = @(
                (Build-StandardProduct -NameHtml 'AI Top Load Washer with<br>EcoBubble&trade; and Digital<br>Inverter Technology' -ModelHtml 'WA80F21S8BFA' -Link 'https://www.samsung.com/za/washers-and-dryers/washing-machines/wa80f-25-top-load-washer-ai-wash-ecobubble-ai-energy-mode-21kg-black-wa80f21s8bfa/' -ImageRel 'Products\VD Owner\Mask Group 22.png' -ImageAlt 'AI Top Load Washer' -NowPriceHtml 'R8 999' -SavePriceHtml 'R3 000'),
                (Build-StandardProduct -NameHtml '594L Bespoke AI Side-by-Side<br>Refrigerator AI Home<br>9&quot; Screen' -ModelHtml 'RS90F64D2FFA' -Link 'https://www.samsung.com/za/refrigerators/side-by-side/refrigerator-sbs-9-inch-ai-home-594l-black-rs90f64d2ffa/' -ImageRel 'Products\VD Owner\Mask Group 35.png' -ImageAlt '594L Bespoke AI Side-by-Side Refrigerator' -NowPriceHtml 'R32 999' -SavePriceHtml 'R10 000')
            )
            $tvLeft = [ordered]@{
                NameHtml = '55&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA55QN90FAUXXA'
                PriceHtml = 'R19 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-55-inch-neo-qled-4k-mini-led-smart-tv-qa55qn90fauxxa/'
            }
            $tvRight = [ordered]@{
                NameHtml = '65&rdquo; 4K Neo QLED Mini<br>LED Vision AI TV'
                ModelHtml = 'QA65QN90FAUXXA'
                PriceHtml = 'R34 999'
                Link = 'https://www.samsung.com/za/tvs/neo-qled/qn90f-65-inch-neo-qled-4k-mini-led-smart-tv-qa65qn90fauxxa/'
            }
            $q800 = Build-StandardProduct -NameHtml 'Q-Series Soundbar 5.1.2 ch<br>Subwoofer' -ModelHtml 'HW-Q800F/XA' -Link 'https://www.samsung.com/za/audio-devices/soundbar/q800f-black-hw-q800f-xa/' -ImageRel 'Products\VD Owner\Mask Group 24.png' -ImageAlt 'Q-Series Soundbar 5.1.2' -NowPriceHtml 'R7 999' -SavePriceHtml 'R3 000'
            $q990 = Build-StandardProduct -NameHtml 'Q-Series Soundbar 11.1.4 ch<br>Subwoofer &amp; Rear Speaker' -ModelHtml 'HW-Q990F/XA' -Link 'https://www.samsung.com/za/audio-devices/soundbar/q990f-black-hw-q990f-xa/' -ImageRel 'Products\VD Owner\Mask Group 14.png' -ImageAlt 'Q-Series Soundbar 11.1.4' -NowPriceHtml 'R17 999' -SavePriceHtml 'R3 999'

            $mobileSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $Context -Cards $mobileCards -Columns 3) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 25.png' -ImageAlt 'AI Week character' -Align 'center')
            $applianceSection = Render-SectionWrapper -InnerHtml (Render-GridBlock -Context $Context -Cards $applianceCards -Columns 2) -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 6.png' -ImageAlt 'AI Week appliance characters' -Align 'center')
            $tvInner = Join-Html @(
                (Render-TVWideBlock -Context $Context -TagRel 'Discount Tags\Group 983.png' -TagAlt 'Earn 5% bonus Samsung Rewards' -ImageRel 'Products\VD Owner\Mask Group 32.png' -ImageAlt 'Neo QLED TV' -LeftProduct $tvLeft -RightProduct $tvRight),
                '<table border="0" cellpadding="0" cellspacing="0" width="520"><tbody><tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr></tbody></table>',
                (Render-GridBlock -Context $Context -Cards @($q800, $q990) -Columns 2)
            )
            $tvSection = Render-SectionWrapper -InnerHtml $tvInner -DecorationRow (Render-DecorationRow -Context $Context -ImageRel 'Products\imAGES\Image 169.png' -ImageAlt 'AI Week TV character' -Align 'left')

            return @($mobileSection, $applianceSection, $tvSection, (Render-CouponSection -Context $Context -ClaimLink $claimLink), (Render-TimerSection -Context $Context -ShopLink $shopLink))
        }
    }
)

$summary = @()

foreach ($mailer in $mailers) {
    $context = New-MailerContext -MailerName $mailer.MailerName -DesignFileName $mailer.DesignFileName

    $appBarAsset = Crop-DesignAsset -Context $context -OutputName 'app_bar.png' -X 0 -Y 0 -Width 600 -Height 78
    $heroAsset = Crop-DesignAsset -Context $context -OutputName 'hero_block.png' -X 0 -Y 78 -Width 600 -Height $mailer.HeroCropHeight
    $heroSection = @"
<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr>
            <td>$(Render-LinkedImage -Asset $appBarAsset -Href $downloadLink -Alt 'Samsung Shop App')</td>
        </tr>
        <tr>
            <td>$(Render-LinkedImage -Asset $heroAsset -Href $shopLink -Alt $mailer.HeroAlt)</td>
        </tr>
    </tbody>
</table>
"@

    $sections = @(
        $heroSection,
        (Render-SupportCopySection)
    )

    $sections += & $mailer.Sections $context
    $sections += Render-DealsValidSection

    $html = Build-DocumentHtml -Sections $sections -FooterHtml $footerHtml -PreheaderText 'Enjoy TV the way you want with AI Week'
    $htmlPath = Write-MailerHtml -Context $context -Html $html
    $zipPath = Write-MailerZip -Context $context

    $summary += [PSCustomObject]@{
        Mailer = $mailer.MailerName
        Html = $htmlPath
        Zip = $zipPath
    }
}

$summary | Format-Table -AutoSize | Out-String