$ErrorActionPreference = 'Stop'

$jobDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mailersRoot = Split-Path -Parent (Split-Path -Parent $jobDir)
$assetsRoot = Join-Path $jobDir "ZAS26088126 _ MX _ Mother's Day Touch 2 _ Mailers _ W19_Assets"
$publishedRoot = Join-Path $jobDir 'Published'

$headingFont = 'Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$bodyFont = 'avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$config = [ordered]@{
    Country = 'South Africa'
    FooterCode = 'ssa'
    OutputName = 'ZAS26088126_MX_Mothers_Day_Touch_2_W19_SA'
    Preheader = 'A gift for mom, made a little easier'
    Links = [ordered]@{
        Kv = 'https://www.samsung.com/za/offer/mothers-day-gift-ideas/'
        Buds4Pro = 'https://www.samsung.com/za/offer/mothers-day-gift-ideas/'
        MomType = 'https://www.samsung.com/za/offer/mothers-day-gift-ideas/'
        S25Ultra = 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/'
        S25 = 'https://www.samsung.com/za/smartphones/galaxy-s25/buy/'
        S25Fe256 = 'https://www.samsung.com/za/smartphones/galaxy-s25/buy/'
        S25Fe128 = 'https://www.samsung.com/za/smartphones/galaxy-s25/buy/'
        A36 = 'https://www.samsung.com/za/smartphones/galaxy-a/galaxy-a36-5g/buy/'
        A26 = 'https://www.samsung.com/za/smartphones/galaxy-a/galaxy-a26-5g/buy/'
        TabS10Fe = 'https://www.samsung.com/za/tablets/galaxy-tab-s/galaxy-tab-s10-fe-blue-126gb-sm-x520nlbaafa/'
        LittleDetails = 'https://www.samsung.com/za/mobile-accessories/all-mobile-accessories/'
        MoreToLove = 'https://www.samsung.com/za/offer/buy-more-save-more/'
        BetterVersion = 'https://www.samsung.com/za/apps/samsung-health/'
    }
}

function Sanitize-FileName {
    param([string]$Name)

    $clean = $Name -replace ' ', '_'
    $clean = $clean -replace '@', '_'
    $clean = $clean -replace '[^A-Za-z0-9._-]', ''
    $clean = $clean -replace '_+', '_'
    return $clean.Trim('_')
}

function Use-Asset {
    param(
        [hashtable]$State,
        [string]$RelativePath,
        [string]$DesiredName
    )

    if ($State.Assets.ContainsKey($RelativePath)) {
        return $State.Assets[$RelativePath]
    }

    $sourcePath = Join-Path $script:assetsRoot $RelativePath
    if (-not (Test-Path $sourcePath)) {
        throw "Missing asset: $RelativePath"
    }

    $fileName = if ($DesiredName) {
        $requestedExt = [IO.Path]::GetExtension($DesiredName)
        if ([string]::IsNullOrWhiteSpace($requestedExt)) {
            $DesiredName + [IO.Path]::GetExtension($sourcePath)
        }
        else {
            $DesiredName
        }
    }
    else {
        [IO.Path]::GetFileName($sourcePath)
    }

    $sanitizedName = Sanitize-FileName $fileName
    $destPath = Join-Path $State.DestDir $sanitizedName
    Copy-Item $sourcePath $destPath -Force
    $State.Assets[$RelativePath] = $sanitizedName
    return $sanitizedName
}

function Get-FooterHtml {
    param([string]$FooterCode)

    $footerPath = Join-Path $script:mailersRoot ("footers\footer_{0}.txt" -f $FooterCode)
    if (-not (Test-Path $footerPath)) {
        throw "Missing footer file: $footerPath"
    }

    $footerHtml = [System.IO.File]::ReadAllText($footerPath, $script:utf8NoBom)
    $footerHtml = [regex]::Replace(
        $footerHtml,
        'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^\"]+"',
        'href="YYYYY"'
    )
    $footerHtml = $footerHtml.Replace([string][char]0x00A9, '&copy;')
    return $footerHtml
}

function Get-SpacerRow {
    param([int]$Height)
    return '<tr><td height="{0}" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>' -f $Height
}

function Get-HeaderHtml {
    param([hashtable]$MailerConfig)

    return @"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=600">
<meta name="format-detection" content="telephone=no">
<title>Samsung $($MailerConfig.Country)</title>
</head>
<body style="background-color:#555;">
<span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;">$($MailerConfig.Preheader)</span>
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
"@
}

function Get-ButtonMarkup {
    param(
        [hashtable]$State,
        [string]$RelativePath,
        [string]$Href,
        [string]$Alt,
        [int]$Width,
        [int]$Height,
        [string]$DesiredName
    )

    $src = Use-Asset $State $RelativePath $DesiredName
    return '<a href="{0}" target="_blank"><img alt="{1}" border="0" height="{2}" src="{3}" style="width:{4}px; height:{5}px; display:block; margin:auto;" width="{6}"></a>' -f $Href, $Alt, $Height, $src, $Width, $Height, $Width
}

function Get-PriceCard {
    param([hashtable]$Product)

    $nameSize = if ($Product.NameSize) { [int]$Product.NameSize } else { 18 }
    $cardWidth = if ($Product.CardWidth) { [int]$Product.CardWidth } else { 220 }
    $saveRow = ''

    if (-not [string]::IsNullOrWhiteSpace($Product.Save)) {
        $saveRow = @"
        <tr>
            <td align="center" style="background-color:#ffffff; padding:8px 5px; border-top:1px solid #000000;">
                <span style="font-size:12px; font-family:$script:bodyFont; color:#000000;">Save&nbsp;</span><span style="font-size:24px; line-height:28px; white-space:nowrap;"><strong><span style="font-family:$script:headingFont; color:#000000;">$($Product.Save)</span></strong></span>
            </td>
        </tr>
"@
    }

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:${cardWidth}px; background-color:#ffffff;" width="$cardWidth">
    <tbody>
        <tr>
            <td align="center" style="background-color:#000000; padding:9px 8px;">
                <span style="font-size:${nameSize}px; line-height:22px;"><strong><span style="font-family:$script:headingFont; color:#ffffff;">$($Product.Name)</span></strong></span><br>
                <span style="font-size:14px; line-height:18px;"><span style="font-family:$script:bodyFont; color:#ffffff;">$($Product.Model)</span></span>
            </td>
        </tr>
        <tr>
            <td align="center" style="background-color:#ffffff; padding:9px 5px; border-top:1px solid #000000;">
                <span style="font-size:12px; font-family:$script:bodyFont; color:#000000;">Now&nbsp;</span><span style="font-size:28px; line-height:32px; white-space:nowrap;"><strong><span style="font-family:$script:headingFont; color:#000000;">$($Product.Now)</span></strong></span>
            </td>
        </tr>
        $saveRow
    </tbody>
</table>
"@
}

function Get-ProductOfferCell {
    param(
        [hashtable]$State,
        [hashtable]$Product,
        [int]$CellWidth = 250
    )

    $button = Get-ButtonMarkup $State 'Buttons\Group 1074.png' $Product.Link 'Buy now' 120 50 'Button_Buy_Now.png'
    $card = Get-PriceCard $Product

    return @"
<td align="center" valign="top" width="$CellWidth">
    <table align="center" border="0" cellpadding="0" cellspacing="0" width="$CellWidth">
        <tbody>
            <tr>
                <td style="text-align:center;"><a href="$($Product.Link)" target="_blank"><img alt="$($Product.Name)" border="0" height="$($Product.Height)" src="$($Product.Src)" style="width:$($Product.Width)px; height:$($Product.Height)px; display:block; margin:auto;" width="$($Product.Width)"></a></td>
            </tr>
            $(Get-SpacerRow 16)
            <tr>
                <td style="text-align:center;">$card</td>
            </tr>
            $(Get-SpacerRow 14)
            <tr>
                <td style="text-align:center;">$button</td>
            </tr>
        </tbody>
    </table>
</td>
"@
}

function Build-Mailer {
    param([hashtable]$MailerConfig)

    $destDir = Join-Path $script:publishedRoot $MailerConfig.OutputName
    if (Test-Path $destDir) {
        Remove-Item $destDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    $state = @{
        DestDir = $destDir
        Assets = @{}
    }

    $logo = Use-Asset $state 'KV\Color Overlay@2x.png' 'KV_Logo_2x.png'
    $heroImage = Use-Asset $state 'KV\Mask Group 12.png' 'KV_Hero.png'
    $budsImage = Use-Asset $state 'Products\Image 124.png' 'Promo_Buds4_Pro.png'
    $momTypeIcon = Use-Asset $state 'Flowers\Image 125.png' 'Flower_Mom_Type.png'
    $momTypeCollage = Use-Asset $state 'Images\Image 126.png' 'Mom_Type_Collage.png'
    $pricingIcon = Use-Asset $state 'Flowers\Image 127.png' 'Flower_Pricing.png'
    $pricingPhoto = Use-Asset $state 'Images\Image 128.png' 'Pricing_Lifestyle.png'
    $frameTop = Use-Asset $state 'Flowers\62cb3735313061a6ebf7fc9dba943816.png' 'Promo_Frame_Top.png'
    $frameSide = Use-Asset $state 'Flowers\Image 42.png' 'Promo_Frame_Side.png'
    $frameBottom = Use-Asset $state 'Flowers\Image 44@2x.png' 'Promo_Frame_Bottom_2x.png'
    $littleDetailsIcon = Use-Asset $state 'Flowers\Image 125.png' 'Flower_Mom_Type.png'
    $accessoriesBanner = Use-Asset $state 'Icons\Group 1078.png' 'Accessories_Banner.png'
    $moreToLoveIcon = Use-Asset $state 'Flowers\Image 160.png' 'Flower_More_To_Love.png'
    $bundleHero = Use-Asset $state 'Products\Image 149.png' 'Bundle_S26_Ultra.png'
    $bundleOffer = Use-Asset $state 'dfsghfjgkmggfds-0001.png' 'Bundle_Offer.png'
    $healthIcon = Use-Asset $state 'Flowers\Image 125.png' 'Flower_Mom_Type.png'
    $healthImage = Use-Asset $state 'Images\Image 161.png' 'Health_Image.png'

    $heroButton = Get-ButtonMarkup $state 'Buttons\Group 1.png' $MailerConfig.Links.Kv 'Shop now' 134 50 'Button_Shop_Now.png'
    $budsButton = Get-ButtonMarkup $state 'Buttons\Group 1074.png' $MailerConfig.Links.Buds4Pro 'Buy now' 120 50 'Button_Buy_Now.png'
    $momTypeButton = Get-ButtonMarkup $state 'Buttons\Group 3.png' $MailerConfig.Links.MomType 'Find her match' 164 50 'Button_Find_Her_Match.png'
    $seeMoreButton = Get-ButtonMarkup $state 'Buttons\Group 1064.png' $MailerConfig.Links.LittleDetails 'See more' 124 50 'Button_See_More.png'
    $bundleButton = Get-ButtonMarkup $state 'Buttons\Group 1065.png' $MailerConfig.Links.MoreToLove 'Create your bundle' 200 50 'Button_Create_Your_Bundle.png'
    $healthButton = Get-ButtonMarkup $state 'Buttons\Group 1066.png' $MailerConfig.Links.BetterVersion 'Learn more' 138 50 'Button_Learn_More.png'

    $products = @(
        [ordered]@{ Name = 'Galaxy S25 Ultra'; Model = 'SM-S938BZBIAFA'; Now = 'R24 999'; Save = 'R3 400'; Link = $MailerConfig.Links.S25Ultra; Src = Use-Asset $state 'Products\Mask Group 2.png' 'Product_S25_Ultra.png'; Width = 129; Height = 129; NameSize = 18; CardWidth = 220 },
        [ordered]@{ Name = 'Galaxy S25'; Model = 'SM-S931BDBOAFA'; Now = 'R18 999'; Save = 'R2 000'; Link = $MailerConfig.Links.S25; Src = Use-Asset $state 'Products\Mask Group 3.png' 'Product_S25.png'; Width = 106; Height = 128; NameSize = 18; CardWidth = 220 },
        [ordered]@{ Name = 'Galaxy S25 FE 256GB'; Model = 'SM-S731BDBVAFA'; Now = 'R15 499'; Save = 'R2 500'; Link = $MailerConfig.Links.S25Fe256; Src = Use-Asset $state 'Products\Mask Group 4.png' 'Product_S25_FE_256.png'; Width = 106; Height = 128; NameSize = 16; CardWidth = 220 },
        [ordered]@{ Name = 'Galaxy S25 FE 128GB'; Model = 'SM-S731BDBUAFA'; Now = 'R15 499'; Save = ''; Link = $MailerConfig.Links.S25Fe128; Src = Use-Asset $state 'Products\Mask Group 6.png' 'Product_S25_FE_128.png'; Width = 106; Height = 128; NameSize = 16; CardWidth = 220 },
        [ordered]@{ Name = 'Galaxy A36'; Model = 'SM-A366BLGMAFA'; Now = 'R6 799'; Save = 'R700'; Link = $MailerConfig.Links.A36; Src = Use-Asset $state 'Products\Mask Group 7.png' 'Product_A36.png'; Width = 129; Height = 129; NameSize = 18; CardWidth = 220 },
        [ordered]@{ Name = 'Galaxy A26'; Model = 'SM-A266BZKIAFA'; Now = 'R4 499'; Save = 'R500'; Link = $MailerConfig.Links.A26; Src = Use-Asset $state 'Products\Mask Group 10.png' 'Product_A26.png'; Width = 101; Height = 128; NameSize = 18; CardWidth = 220 },
        [ordered]@{ Name = 'Galaxy Tab S10 FE Wi-Fi'; Model = 'SM-X520NLBAAFA'; Now = 'R11 499'; Save = 'R1 296'; Link = $MailerConfig.Links.TabS10Fe; Src = Use-Asset $state 'Products\Image 37.png' 'Product_Tab_S10_FE.png'; Width = 127; Height = 88; NameSize = 16; CardWidth = 220 }
    )

    $pricingRows = @()
    for ($index = 0; $index -lt 6; $index += 2) {
        $left = Get-ProductOfferCell $state $products[$index]
        $right = Get-ProductOfferCell $state $products[$index + 1]
        $pricingRows += @"
<tr>
    $left
    <td width="20"></td>
    $right
</tr>
"@
        if ($index -lt 4) {
            $pricingRows += '<tr><td colspan="3" height="26" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>'
        }
    }

    $tabCard = Get-PriceCard $products[6]
    $tabButton = Get-ButtonMarkup $state 'Buttons\Group 1074.png' $products[6].Link 'Buy now' 120 50 'Button_Buy_Now.png'

    $countdownRow = @"
<tr>
<td style="text-align:center; padding:5px 20px 20px 20px;"><img alt="" height="120" src="https://samsungsa.online/timer/countdown.php?lang=en&amp;time=2026-05-10+00:00:00&amp;width=450&amp;height=120&amp;boxColor=fff&amp;font=BebasNeue&amp;fontColor=AA1F49&amp;fontSize=90&amp;xOffset=0&amp;yOffset=85&amp;labelOffsets=0.5,3.5,6,8.5" style="width: 450px; height: 120px;" width="450"></td>
</tr>
"@

    $content = @"
<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#FFD9A8; width:600px;" width="600">
    <tbody>
        $(Get-SpacerRow 40)
        <tr>
            <td style="padding:0 42px;"><a href="$($MailerConfig.Links.Kv)" target="_blank"><img alt="Samsung" border="0" height="36" src="$logo" style="width:233px; height:36px; display:block;" width="233"></a></td>
        </tr>
        $(Get-SpacerRow 24)
        $countdownRow
        <tr>
            <td style="text-align:center; padding:0 44px;"><span style="font-size:47px; line-height:54px;"><strong><span style="font-family:$headingFont; color:#000000;">A gift for mom,<br>made a little easier</span></strong></span></td>
        </tr>
        $(Get-SpacerRow 22)
        <tr>
            <td style="text-align:center; padding:0 54px;"><span style="font-size:20px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Don&rsquo;t worry, we&rsquo;ve done the work for you.<br>Find the perfect Galaxy gift and<br>make her day unforgettable.</span></span></td>
        </tr>
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;">$heroButton</td></tr>
        $(Get-SpacerRow 34)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.Kv)" target="_blank"><img alt="Mother's Day Galaxy gifts" border="0" height="579" src="$heroImage" style="width:600px; height:579px; display:block;" width="600"></a></td></tr>
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FBF4E8; width:600px;" width="600">
    <tbody>
        $(Get-SpacerRow 54)
        <tr>
            <td style="text-align:center; padding:0 40px;"><span style="font-size:50px; line-height:58px;"><strong><span style="font-family:$headingFont; color:#000000;">Make her favorite<br>moments feel<br>even more special</span></strong></span></td>
        </tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 48px;"><span style="font-size:20px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Buy any of the Mother&rsquo;s Day products and<br>stand a chance to win <strong>Galaxy Buds4 Pro</strong><br>Pink Gold.</span></span></td>
        </tr>
        $(Get-SpacerRow 22)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.Buds4Pro)" target="_blank"><img alt="Galaxy Buds4 Pro Pink Gold" border="0" height="282" src="$budsImage" style="width:200px; height:282px; display:block; margin:auto;" width="200"></a></td></tr>
        $(Get-SpacerRow 24)
        <tr><td style="text-align:center; padding:0 40px;"><span style="font-size:14px; line-height:22px;"><span style="font-family:$bodyFont; color:#000000;">*Minimum spend of R10 000. Ts &amp; Cs apply.</span></span></td></tr>
        $(Get-SpacerRow 30)
        <tr><td style="text-align:center;">$budsButton</td></tr>
        $(Get-SpacerRow 58)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFD9A8; width:600px;" width="600">
    <tbody>
        $(Get-SpacerRow 38)
        <tr><td style="text-align:center;"><img alt="Flower icon" border="0" height="84" src="$momTypeIcon" style="width:71px; height:84px; display:block; margin:auto;" width="71"></td></tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 44px;"><span style="font-size:50px; line-height:58px;"><strong><span style="font-family:$headingFont; color:#000000;">What&rsquo;s your<br>mom&rsquo;s type?</span></strong></span></td>
        </tr>
        $(Get-SpacerRow 22)
        <tr>
            <td style="text-align:center; padding:0 42px;"><span style="font-size:20px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Short on time? Explore our curated gifts<br>perfectly matched for mom&rsquo;s everyday.</span></span></td>
        </tr>
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.MomType)" target="_blank"><img alt="Curated gifts for mom" border="0" height="652" src="$momTypeCollage" style="width:535px; height:652px; display:block; margin:auto;" width="535"></a></td></tr>
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;">$momTypeButton</td></tr>
        $(Get-SpacerRow 54)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFD9A8; width:600px;" width="600">
    <tbody>
        $(Get-SpacerRow 38)
        <tr><td style="text-align:center;"><img alt="Flower icon" border="0" height="84" src="$pricingIcon" style="width:79px; height:84px; display:block; margin:auto;" width="79"></td></tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 40px;"><span style="font-size:50px; line-height:58px;"><strong><span style="font-family:$headingFont; color:#000000;">Perfect gifts at the<br>perfect price</span></strong></span></td>
        </tr>
        $(Get-SpacerRow 22)
        <tr>
            <td style="text-align:center; padding:0 60px;"><span style="font-size:20px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Discover Galaxy gifts mom<br>will love for every budget.</span></span></td>
        </tr>
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.S25Ultra)" target="_blank"><img alt="Mother and daughter with flowers" border="0" height="334" src="$pricingPhoto" style="width:512px; height:334px; display:block; margin:auto;" width="512"></a></td></tr>
        $(Get-SpacerRow 28)
        <tr>
            <td style="text-align:center; padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:560px; background-color:#FFF8EF; border:10px solid #FFC983;" width="560">
                    <tbody>
                        $(Get-SpacerRow 20)
                        <tr>
                            <td style="padding:0 10px 20px 10px;">
                                <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                                    <tbody>
                                        $($pricingRows -join "`r`n")
                                        <tr><td colspan="3" height="26" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                        <tr>
                                            <td align="center" valign="middle" width="250"><a href="$($products[6].Link)" target="_blank"><img alt="$($products[6].Name)" border="0" height="$($products[6].Height)" src="$($products[6].Src)" style="width:$($products[6].Width)px; height:$($products[6].Height)px; display:block; margin:auto;" width="$($products[6].Width)"></a></td>
                                            <td width="20"></td>
                                            <td align="center" valign="middle" width="250">
                                                <table align="center" border="0" cellpadding="0" cellspacing="0" width="250">
                                                    <tbody>
                                                        <tr><td style="text-align:center;">$tabCard</td></tr>
                                                        $(Get-SpacerRow 14)
                                                        <tr><td style="text-align:center;">$tabButton</td></tr>
                                                    </tbody>
                                                </table>
                                            </td>
                                        </tr>
                                        $(Get-SpacerRow 8)
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        $(Get-SpacerRow 46)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFD9A8; width:600px;" width="600">
    <tbody>
        <tr>
            <td style="text-align:center; padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="512">
                    <tbody>
                        <tr><td style="text-align:center;"><img alt="Offer frame top" border="0" height="85" src="$frameTop" style="width:512px; height:85px; display:block; margin:auto;" width="512"></td></tr>
                        <tr>
                            <td>
                                <table align="center" border="0" cellpadding="0" cellspacing="0" width="512">
                                    <tbody>
                                        <tr>
                                            <td valign="top" width="21"><img alt="Offer frame side" border="0" height="395" src="$frameSide" style="width:21px; height:395px; display:block;" width="21"></td>
                                            <td valign="middle" width="470" style="background-color:#ffffff; text-align:center; padding:24px 24px 18px 24px;">
                                                <span style="font-size:18px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Celebrate Mom, Use Code <strong>MOTHER</strong><br>at checkout to <strong>get 10% off</strong> on the<br><strong>Galaxy A57 | A37, Galaxy S26</strong> Pink Gold<br>or Silver Shadow &amp; <strong>Galaxy Buds4 Pro</strong><br>Pink Gold.</span></span><br><br>
                                                <span style="font-size:18px; line-height:28px;"><span style="font-family:$bodyFont; color:#000000;">Limited to the first 50 customers.</span></span><br><br>
                                                <span style="font-size:14px; line-height:22px;"><span style="font-family:$bodyFont; color:#000000;">Valid until 10 May 2026.<br>Ts &amp; Cs apply.</span></span>
                                            </td>
                                            <td valign="top" width="21"><img alt="Offer frame side" border="0" height="395" src="$frameSide" style="width:21px; height:395px; display:block;" width="21"></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                        <tr><td style="text-align:center;"><img alt="Offer frame bottom" border="0" height="27" src="$frameBottom" style="width:509px; height:27px; display:block; margin:auto;" width="509"></td></tr>
                    </tbody>
                </table>
            </td>
        </tr>
        $(Get-SpacerRow 48)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFD9A8; width:600px;" width="600">
    <tbody>
        <tr><td style="text-align:center;"><img alt="Flower icon" border="0" height="84" src="$littleDetailsIcon" style="width:71px; height:84px; display:block; margin:auto;" width="71"></td></tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 52px;"><span style="font-size:50px; line-height:58px;"><strong><span style="font-family:$headingFont; color:#000000;">The little details<br>that make it hers</span></strong></span></td>
        </tr>
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.LittleDetails)" target="_blank"><img alt="Save up to 25% on selected accessories" border="0" height="159" src="$accessoriesBanner" style="width:512px; height:159px; display:block; margin:auto;" width="512"></a></td></tr>
        $(Get-SpacerRow 26)
        <tr>
            <td style="text-align:center; padding:0 38px;"><span style="font-size:20px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Thoughtful accessories that bring<br>comfort, style, and a little more joy to her<br>everyday moments.</span></span></td>
        </tr>
        $(Get-SpacerRow 30)
        <tr><td style="text-align:center;">$seeMoreButton</td></tr>
        $(Get-SpacerRow 62)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFD9A8; width:600px;" width="600">
    <tbody>
        <tr><td style="text-align:center;"><img alt="Flower icon" border="0" height="84" src="$moreToLoveIcon" style="width:71px; height:84px; display:block; margin:auto;" width="71"></td></tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 34px;"><span style="font-size:50px; line-height:58px;"><strong><span style="font-family:$headingFont; color:#000000;">More to love,<br>thoughtfully together</span></strong></span></td>
        </tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 50px;"><span style="font-size:20px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Bundle Galaxy devices to complete<br>the perfect gift set for less.</span></span></td>
        </tr>
        $(Get-SpacerRow 30)
        <tr><td style="text-align:center;"><span style="font-size:20px; line-height:28px;"><strong><span style="font-family:$headingFont; color:#000000;">Galaxy S26 Ultra</span></strong></span></td></tr>
        $(Get-SpacerRow 16)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.MoreToLove)" target="_blank"><img alt="Galaxy S26 Ultra" border="0" height="304" src="$bundleHero" style="width:290px; height:304px; display:block; margin:auto;" width="290"></a></td></tr>
        $(Get-SpacerRow 20)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.MoreToLove)" target="_blank"><img alt="Bundle offer" border="0" height="445" src="$bundleOffer" style="width:600px; height:445px; display:block; margin:auto;" width="600"></a></td></tr>
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;">$bundleButton</td></tr>
        $(Get-SpacerRow 58)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFD9A8; width:600px;" width="600">
    <tbody>
        <tr><td style="text-align:center;"><img alt="Flower icon" border="0" height="84" src="$healthIcon" style="width:71px; height:84px; display:block; margin:auto;" width="71"></td></tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 38px;"><span style="font-size:50px; line-height:58px;"><strong><span style="font-family:$headingFont; color:#000000;">Better version of<br>mom starts today</span></strong></span></td>
        </tr>
        $(Get-SpacerRow 22)
        <tr>
            <td style="text-align:center; padding:0 46px;"><span style="font-size:20px; line-height:30px;"><span style="font-family:$bodyFont; color:#000000;">Help her shape a healthier day from start<br>to finish. Don&rsquo;t wait to give her the best.</span></span></td>
        </tr>
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$($MailerConfig.Links.BetterVersion)" target="_blank"><img alt="Samsung Health" border="0" height="334" src="$healthImage" style="width:512px; height:334px; display:block; margin:auto;" width="512"></a></td></tr>
        $(Get-SpacerRow 30)
        <tr><td style="text-align:center;">$healthButton</td></tr>
        $(Get-SpacerRow 62)
    </tbody>
</table>
"@

    $header = Get-HeaderHtml $MailerConfig
    $footer = Get-FooterHtml $MailerConfig.FooterCode
    $html = $header + $content + $footer
    $htmlPath = Join-Path $destDir ($MailerConfig.OutputName + '.html')
    [System.IO.File]::WriteAllText($htmlPath, $html, $script:utf8NoBom)
}

New-Item -ItemType Directory -Path $publishedRoot -Force | Out-Null
Build-Mailer $config
Write-Output ("Published mailer created in {0}" -f $publishedRoot)