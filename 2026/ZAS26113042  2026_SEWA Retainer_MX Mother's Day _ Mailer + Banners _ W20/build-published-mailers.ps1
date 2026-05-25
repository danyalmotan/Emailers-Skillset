$ErrorActionPreference = 'Stop'

$jobDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$mailersRoot = Split-Path -Parent (Split-Path -Parent $jobDir)
$assetsRoot = Join-Path $jobDir "AS26113042 _ 2026_SEWA Retainer_MX Mother's Day _ Mailer _ W20_Assets"
$publishedRoot = Join-Path $jobDir 'Published'

$headingFont = 'Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$bodyFont = 'avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$rawLinks = @{
    Home = 'https://www.samsung.com/africa_en/'
    HomeFr = 'https://www.samsung.com/africa_fr/'
    Kv = 'https://www.samsung.com/africa_en/offer/'
    Section2 = 'https://www.samsung.com/africa_en/smartphones/all-smartphones/'
    Fold = 'https://www.samsung.com/africa_en/smartphones/galaxy-z-fold7/'
    Flip = 'https://www.samsung.com/africa_en/smartphones/galaxy-z-flip7/'
    Flipsuit = 'https://www.samsung.com/africa_en/mobile-accessories/all-mobile-accessories/?smartphones'
    MagneticCase = 'https://www.samsung.com/africa_en/mobile-accessories/all-mobile-accessories/'
    BatteryPack = 'https://www.samsung.com/africa_en/mobile-accessories/all-mobile-accessories/?adaptors-and-cables'
    LearnMore = 'https://www.samsung.com/africa_en/mobile-accessories/all-mobile-accessories/'
    S26Ultra = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26-ultra/'
    Watch8 = 'https://www.samsung.com/africa_en/watches/galaxy-watch/galaxy-watch8-44mm-silver-bluetooth-sm-l330nzsamea/'
    Buds4 = 'https://www.samsung.com/africa_en/audio-sound/galaxy-buds/galaxy-buds4-pro-white-sm-r640nzwamea/'
    A11 = 'https://www.samsung.com/africa_en/tablets/galaxy-tab-a/galaxy-tab-a11-gray-128gb-sm-x135gzaeect/'
    MakeMoments = 'https://www.samsung.com/africa_en/offer/'
    SamsungCare = 'https://www.samsung.com/africa_en/offer/samsung-care-plus/'
    TryGalaxy = 'https://trygalaxy.com/'
    SideBySide634 = 'https://www.samsung.com/africa_en/refrigerators/side-by-side/refrigerator-sbs-rs90f-aod-634l-black-doi-rs80f65j3fut/'
    ChestFreezer371 = 'https://www.samsung.com/africa_en/aisearch/?searchvalue=chest%20freezer'
    Washer101 = 'https://www.samsung.com/africa_en/washers-and-dryers/washing-machines/ww5000d-front-loading-smartthings-ai-energy-mode-a-10-percent-extra-energy-efficiency-ai-ecobubble-10kg-black-ww10dg5u34abnq/'
}

$regionConfigs = @(
    [ordered]@{
        Region = 'GH'
        Country = 'Ghana'
        Language = 'en'
        FooterCode = 'gh'
        SourceJpg = "GH_ZAS26113042  2026_SEWA Retainer_MX Mother's Day _ Mailer + Banners _ W20.jpg"
        Layout = 'gh'
        Preheader = 'Your companion for mom'
    },
    [ordered]@{
        Region = 'KE'
        Country = 'Kenya'
        Language = 'en'
        FooterCode = 'ke'
        SourceJpg = "KE_ZAS26110063  2026_SEEA_Retainer MX Mother's Day _ Mailer + Banners _ W20.jpg"
        Layout = 'ketz'
        Preheader = 'Show your love with great gifts'
    },
    [ordered]@{
        Region = 'TZ'
        Country = 'Tanzania'
        Language = 'en'
        FooterCode = 'tz'
        SourceJpg = "TZ_ZAS26110063  2026_SEEA_Retainer MX Mother's Day _ Mailer + Banners _ W20.jpg"
        Layout = 'ketz'
        Preheader = 'Show your love with great gifts'
    },
    [ordered]@{
        Region = 'NG'
        Country = 'Nigeria'
        Language = 'en'
        FooterCode = 'ng'
        SourceJpg = "NG_ZAS26113042  2026_SEWA Retainer_MX Mother's Day _ Mailer + Banners _ W20.jpg"
        Layout = 'ng'
        Preheader = 'Show your love with great gifts'
    },
    [ordered]@{
        Region = 'SN'
        Country = 'Senegal'
        Language = 'fr'
        FooterCode = 'sn'
        SourceJpg = "SN_ZAS26114045  2026_SEWA_SN_Retainer_MX Mother's Day _ Mailer + Banners _ W20.jpg"
        Layout = 'sn'
        Preheader = 'Dites-lui &laquo; je t&rsquo;aime &raquo; avec les cadeaux Galaxy'
    }
)

function Sanitize-FileName {
    param([string]$Name)

    $clean = $Name -replace ' ', '_'
    $clean = $clean -replace '@', '_'
    $clean = $clean -replace '[^A-Za-z0-9._-]', ''
    $clean = $clean -replace '_+', '_'
    return $clean.Trim('_')
}

function Get-RegionLink {
    param(
        [hashtable]$Config,
        [string]$Key
    )

    $url = $script:rawLinks[$Key]
    if (-not $url) {
        throw "Missing link for key: $Key"
    }

    if ($Config.Language -eq 'fr' -and $url -like 'https://www.samsung.com/africa_en/*') {
        return $url -replace '/africa_en/', '/africa_fr/'
    }

    return $url
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

function Get-HeadingRow {
    param(
        [string]$Html,
        [int]$FontSize,
        [int]$LineHeight,
        [string]$Padding = '0 40px'
    )

    return '<tr><td style="text-align:center; padding:{0};"><span style="font-size:{1}px; line-height:{2}px;"><strong><span style="font-family:{3}; color:#000000;">{4}</span></strong></span></td></tr>' -f $Padding, $FontSize, $LineHeight, $script:headingFont, $Html
}

function Get-BodyRow {
    param(
        [string]$Html,
        [int]$FontSize,
        [int]$LineHeight,
        [string]$Padding = '0 60px'
    )

    return '<tr><td style="text-align:center; padding:{0};"><span style="font-size:{1}px; line-height:{2}px;"><span style="font-family:{3}; color:#000000;">{4}</span></span></td></tr>' -f $Padding, $FontSize, $LineHeight, $script:bodyFont, $Html
}

function Get-ButtonMarkup {
    param(
        [hashtable]$State,
        [hashtable]$Config,
        [string]$Href,
        [string]$Name = 'Button_Learn_More.png'
    )

    if ($Config.Language -eq 'fr') {
        $src = Use-Asset $State 'All mailer Assets\French Buttons\Group 1068.png' $Name
        $width = 158
        $height = 50
        $alt = 'En savoir plus'
    }
    elseif ($Config.Region -eq 'GH') {
        $src = Use-Asset $State 'Ghana Assets\Buttons\Group 1080.png' $Name
        $width = 142
        $height = 50
        $alt = 'Learn more'
    }
    else {
        $src = Use-Asset $State 'All mailer Assets\English Buttons\Group 1080.png' $Name
        $width = 142
        $height = 50
        $alt = 'Learn more'
    }

    return '<a href="{0}" target="_blank"><img alt="{1}" border="0" height="{2}" src="{3}" style="width:{4}px; height:{5}px; display:block; margin:auto;" width="{6}"></a>' -f $Href, $alt, $height, $src, $width, $height, $width
}

function Get-ButtonRow {
    param(
        [hashtable]$State,
        [hashtable]$Config,
        [string]$Href,
        [string]$Name = 'Button_Learn_More.png'
    )

    $buttonMarkup = Get-ButtonMarkup $State $Config $Href $Name
    return '<tr><td style="text-align:center;">{0}</td></tr>' -f $buttonMarkup
}

function Get-LiveProductCell {
    param(
        [string]$Label,
        [string]$Href,
        [string]$Src,
        [int]$Width,
        [int]$Height,
        [string]$Alt,
        [int]$CellWidth = 250
    )

    return @"
<td align="center" valign="top" width="$CellWidth">
    <table align="center" border="0" cellpadding="0" cellspacing="0">
        <tbody>
            <tr>
                <td style="text-align:center; padding-bottom:14px;"><span style="font-size:20px; line-height:24px;"><strong><span style="font-family:$script:headingFont; color:#000000;">$Label</span></strong></span></td>
            </tr>
            <tr>
                <td style="text-align:center;"><a href="$Href" target="_blank"><img alt="$Alt" border="0" height="$Height" src="$Src" style="width:${Width}px; height:${Height}px; display:block; margin:auto;" width="$Width"></a></td>
            </tr>
        </tbody>
    </table>
</td>
"@
}

function Get-BakedProductCell {
    param(
        [string]$Href,
        [string]$Src,
        [int]$Width,
        [int]$Height,
        [string]$Alt,
        [int]$CellWidth
    )

    return @"
<td align="center" valign="top" width="$CellWidth">
    <a href="$Href" target="_blank"><img alt="$Alt" border="0" height="$Height" src="$Src" style="width:${Width}px; height:${Height}px; display:block; margin:auto;" width="$Width"></a>
</td>
"@
}

function Get-StackCard {
    param(
        [string]$Label,
        [string]$Href,
        [string]$Src,
        [int]$Width,
        [int]$Height,
        [string]$Alt,
        [ValidateSet('left', 'right')]
        [string]$ImageSide
    )

    $textCell = '<td align="center" valign="middle" width="220" style="padding:0 10px;"><span style="font-size:20px; line-height:24px;"><strong><span style="font-family:{0}; color:#000000;">{1}</span></strong></span></td>' -f $script:headingFont, $Label
    $imageCell = '<td align="center" valign="middle" width="240"><a href="{0}" target="_blank"><img alt="{1}" border="0" height="{2}" src="{3}" style="width:{4}px; height:{5}px; display:block; margin:auto;" width="{6}"></a></td>' -f $Href, $Alt, $Height, $Src, $Width, $Height, $Width

    if ($ImageSide -eq 'left') {
        $cells = '<td width="30"></td>{0}{1}<td width="30"></td>' -f $imageCell, $textCell
    }
    else {
        $cells = '<td width="30"></td>{0}{1}<td width="30"></td>' -f $textCell, $imageCell
    }

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#f5b7cc; width:520px;" width="520">
    <tbody>
        <tr>
            $cells
        </tr>
    </tbody>
</table>
"@
}

function Get-HeaderHtml {
    param([hashtable]$Config)

    return @"
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=600">
<meta name="format-detection" content="telephone=no">
<title>Samsung $($Config.Country)</title>
</head>
<body style="background-color:#555;">
<span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;">$($Config.Preheader)</span>
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

function Get-LogoStripRow {
    param([string]$Href)

    return '<tr><td style="text-align:center; font-size:0; line-height:0;"><a href="{0}" target="_blank"><img alt="samsung logo" border="0" height="126" src="https://cdn19.mailercdn.net/users/assets/379/images/esrdgthjyukhhg-0001.jpg" style="display:block; width:600px; height:126px;" width="600"></a></td></tr>' -f $Href
}

function Build-GhContent {
    param(
        [hashtable]$State,
        [hashtable]$Config
    )

    $hero = Use-Asset $State 'Ghana Assets\KV\Group 1098.png' 'Hero_KV_GH.png'
    $photo = Use-Asset $State 'Ghana Assets\Images\Group 1077.png' 'Section2_Family_Photo.png'
    $a37 = Use-Asset $State 'Ghana Assets\Products\Group 1112.png' 'Product_Galaxy_A37.png'
    $a57 = Use-Asset $State 'Ghana Assets\Products\Group 1113.png' 'Product_Galaxy_A57.png'
    $budsCore = Use-Asset $State 'Ghana Assets\Products\Group 1114.png' 'Product_Galaxy_Buds_Core.png'
    $fold = Use-Asset $State 'Ghana Assets\Products\Group 1109.png' 'Card_Galaxy_Z_Fold7.png'
    $flip = Use-Asset $State 'Ghana Assets\Products\Group 1108.png' 'Card_Galaxy_Z_Flip7.png'
    $flipsuit = Use-Asset $State 'Ghana Assets\Products\Group 1111.png' 'Card_Flipsuit_Case.png'
    $magCase = Use-Asset $State 'Ghana Assets\Products\Group 1110.png' 'Card_Magnetic_Clear_Case.png'
    $bundle = Use-Asset $State 'Ghana Assets\Products\Mask Group 11.png' 'Bundle_Galaxy_S26_Ultra.png'
    $watch = Use-Asset $State 'Ghana Assets\Products\Group 1104.png' 'Bundle_Galaxy_Watch8.png'
    $buds4 = Use-Asset $State 'Ghana Assets\Products\Group 1103.png' 'Bundle_Galaxy_Buds4_Pro.png'
    $tabA11 = Use-Asset $State 'Ghana Assets\Products\Group 1105.png' 'Bundle_Galaxy_Tab_A11.png'
    $careLogo = Use-Asset $State 'Ghana Assets\Samsung Care Logo\SamsungCare+_Primary_Logo_1L_RGB.png' 'SamsungCare_Logo.png'
    $tryGalaxy = Use-Asset $State 'Ghana Assets\Images\Mask Group 21.png' 'Try_Galaxy_QR.png'
    $crown = Use-Asset $State 'Ghana Assets\Images\Image 7.png' 'Heading_Crown.png'

    $section2Link = Get-RegionLink $Config 'Section2'
    $s26Link = Get-RegionLink $Config 'S26Ultra'
    $watchLink = Get-RegionLink $Config 'Watch8'
    $buds4Link = Get-RegionLink $Config 'Buds4'
    $tabLink = Get-RegionLink $Config 'A11'
    $careLink = Get-RegionLink $Config 'SamsungCare'
    $tryLink = Get-RegionLink $Config 'TryGalaxy'

    $section2Cells = @(
        Get-BakedProductCell $section2Link $a37 161 233 'Galaxy A37' 180
        '<td width="10"></td>'
        Get-BakedProductCell $section2Link $a57 161 233 'Galaxy A57' 180
        '<td width="10"></td>'
        Get-BakedProductCell $section2Link $budsCore 161 233 'Galaxy Buds Core' 180
    ) -join "`r`n"

    $section3Top = Get-BakedProductCell (Get-RegionLink $Config 'Fold') $fold 246 348 'Galaxy Z Fold7' 250
    $section3TopRight = Get-BakedProductCell (Get-RegionLink $Config 'Flip') $flip 246 348 'Galaxy Z Flip7' 250
    $section3Bottom = Get-BakedProductCell (Get-RegionLink $Config 'Flipsuit') $flipsuit 246 348 'Flipsuit Case' 250
    $section3BottomRight = Get-BakedProductCell (Get-RegionLink $Config 'MagneticCase') $magCase 246 348 'Magnetic Clear Case' 250

    $watchCard = Get-StackCard 'Galaxy Watch8' $watchLink $watch 200 142 'Galaxy Watch8' 'left'
    $budsCard = Get-StackCard 'Galaxy Buds4 Pro' $buds4Link $buds4 231 144 'Galaxy Buds4 Pro' 'right'
    $tabCard = Get-StackCard 'Galaxy Tab A11' $tabLink $tabA11 230 142 'Galaxy Tab A11' 'right'

    return @"
<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        <tr>
            <td style="text-align:center; font-size:0; line-height:0;"><a href="$(Get-RegionLink $Config 'Kv')" target="_blank"><img alt="Mother's Day hero" border="0" height="773" src="$hero" style="width:600px; height:773px; display:block;" width="600"></a></td>
        </tr>
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#fbeeee;" width="600">
    <tbody>
        $(Get-SpacerRow 34)
        <tr><td style="text-align:center;"><table align="center" border="0" cellpadding="0" cellspacing="0" width="340"><tbody><tr><td style="text-align:right; padding-right:30px;"><img alt="" border="0" height="52" src="$crown" style="width:72px; height:52px; display:block; margin-left:auto;" width="72"></td></tr></tbody></table></td></tr>
        $(Get-HeadingRow 'Loved by many,<br>chosen for mom' 38 44 '0 40px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Discover the Galaxy favorites.<br>Give her the gift that&rsquo;s already<br>a top choice for moms.' 20 26 '0 72px')
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$section2Link" target="_blank"><img alt="Mother and daughter" border="0" height="255" src="$photo" style="width:394px; height:255px; display:block; margin:auto; border:8px solid #ffffff;" width="394"></a></td></tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="560">
                    <tbody>
                        <tr>
                            $section2Cells
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config $section2Link 'Button_Section2_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#f7c8d7;" width="600">
    <tbody>
        $(Get-SpacerRow 36)
        $(Get-HeadingRow 'The little details<br>that make it hers' 38 44 '0 40px')
        $(Get-SpacerRow 28)
        <tr>
            <td style="text-align:center; padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                    <tbody>
                        <tr>
                            $section3Top
                            <td width="20"></td>
                            $section3TopRight
                        </tr>
                        <tr><td height="20" colspan="3" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                        <tr>
                            $section3Bottom
                            <td width="20"></td>
                            $section3BottomRight
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config (Get-RegionLink $Config 'Fold') 'Button_Section3_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#fbeeee;" width="600">
    <tbody>
        $(Get-SpacerRow 38)
        $(Get-HeadingRow 'Thoughtfully paired<br>for her everyday' 38 44 '0 40px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Bundle the Galaxy devices to elevate her<br>experience and enjoy extra savings.' 20 26 '0 60px')
        $(Get-SpacerRow 22)
        <tr><td style="text-align:center;"><span style="font-size:22px; line-height:28px;"><strong><span style="font-family:$headingFont; color:#000000;">Galaxy S26 Ultra</span></strong></span></td></tr>
        $(Get-SpacerRow 16)
        <tr><td style="text-align:center;"><a href="$s26Link" target="_blank"><img alt="Galaxy S26 Ultra" border="0" height="284" src="$bundle" style="width:351px; height:284px; display:block; margin:auto;" width="351"></a></td></tr>
        $(Get-SpacerRow 18)
        <tr><td style="text-align:center;">$watchCard</td></tr>
        $(Get-SpacerRow 14)
        <tr><td style="text-align:center;">$budsCard</td></tr>
        $(Get-SpacerRow 14)
        <tr><td style="text-align:center;">$tabCard</td></tr>
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config $s26Link 'Button_Section4_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#fbeeee;" width="600">
    <tbody>
        $(Get-SpacerRow 10)
        <tr>
            <td style="text-align:center; padding:0 20px 30px 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff; width:520px;" width="520">
                    <tbody>
                        $(Get-SpacerRow 30)
                        <tr><td style="text-align:center;"><a href="$careLink" target="_blank"><img alt="Samsung Care+" border="0" height="42" src="$careLogo" style="width:292px; height:42px; display:block; margin:auto;" width="292"></a></td></tr>
                        $(Get-SpacerRow 20)
                        $(Get-HeadingRow 'Certified care by Samsung Experts' 20 26 '0 40px')
                        $(Get-SpacerRow 12)
                        $(Get-BodyRow 'Keep your Samsung Galaxy device<br>protected with Samsung Care+<br>provided by authorized professionals.' 17 25 '0 48px')
                        $(Get-SpacerRow 22)
                        $(Get-ButtonRow $State $Config $careLink 'Button_Samsung_Care.png')
                        $(Get-SpacerRow 30)
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr>
            <td width="259" style="text-align:center; font-size:0; line-height:0;"><a href="$tryLink" target="_blank"><img alt="Try Galaxy AI" border="0" height="260" src="$tryGalaxy" style="width:259px; height:260px; display:block;" width="259"></a></td>
            <td width="341" style="background-color:#ffffff; padding:0 34px; vertical-align:middle;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr><td><span style="font-size:20px; line-height:28px;"><strong><span style="font-family:$headingFont; color:#000000;">Try Galaxy AI<br>on your phone</span></strong></span></td></tr>
                        $(Get-SpacerRow 18)
                        <tr><td><a href="$tryLink" style="font-family:$bodyFont; color:#000000; font-size:16px; line-height:22px; text-decoration:none;" target="_blank"><strong>Learn more &gt;</strong></a></td></tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Build-Section2Shared {
    param(
        [hashtable]$Config,
        [string]$CrownSrc,
        [string]$PhotoSrc,
        [array]$Products,
        [string]$HeadingHtml,
        [string]$CopyHtml,
        [string]$ButtonHref
    )

    $cells = @()
    for ($i = 0; $i -lt $Products.Count; $i += 2) {
        $left = $Products[$i]
        $right = $Products[$i + 1]
        $cells += @"
<tr>
    $(Get-LiveProductCell $left.Label $left.Link $left.Src $left.Width $left.Height $left.Alt)
    <td width="20"></td>
    $(Get-LiveProductCell $right.Label $right.Link $right.Src $right.Width $right.Height $right.Alt)
</tr>
"@
        if ($i + 2 -lt $Products.Count) {
            $cells += '<tr><td height="24" colspan="3" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>'
        }
    }

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#fbeeee;" width="600">
    <tbody>
        $(Get-SpacerRow 34)
        <tr><td style="text-align:center;"><table align="center" border="0" cellpadding="0" cellspacing="0" width="340"><tbody><tr><td style="text-align:right; padding-right:30px;"><img alt="" border="0" height="52" src="$CrownSrc" style="width:72px; height:52px; display:block; margin-left:auto;" width="72"></td></tr></tbody></table></td></tr>
        $(Get-HeadingRow $HeadingHtml 38 44 '0 40px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow $CopyHtml 20 26 '0 72px')
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$ButtonHref" target="_blank"><img alt="Mother and daughter" border="0" height="255" src="$PhotoSrc" style="width:394px; height:255px; display:block; margin:auto; border:8px solid #ffffff;" width="394"></a></td></tr>
        $(Get-SpacerRow 24)
        <tr>
            <td style="text-align:center; padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                    <tbody>
                        $($cells -join "`r`n")
                    </tbody>
                </table>
            </td>
        </tr>
"@
}

function Build-Section3NgLike {
    param(
        [hashtable]$State,
        [hashtable]$Config,
        [string]$HeadingHtml,
        [string]$CopyHtml,
        [string]$TopWideSrc,
        [int]$TopWideWidth,
        [int]$TopWideHeight,
        [string]$TopWideHref,
        [string]$TopWideAlt,
        [string]$LeftCardSrc,
        [string]$LeftCardHref,
        [string]$LeftCardAlt,
        [string]$RightCardSrc,
        [string]$RightCardHref,
        [string]$RightCardAlt,
        [int]$BottomHeight,
        [string]$ButtonHref
    )

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#f7c8d7;" width="600">
    <tbody>
        $(Get-SpacerRow 36)
        $(Get-HeadingRow $HeadingHtml 38 44 '0 40px')
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$TopWideHref" target="_blank"><img alt="$TopWideAlt" border="0" height="$TopWideHeight" src="$TopWideSrc" style="width:${TopWideWidth}px; height:${TopWideHeight}px; display:block; margin:auto;" width="$TopWideWidth"></a></td></tr>
        $(Get-SpacerRow 20)
        <tr>
            <td style="text-align:center; padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                    <tbody>
                        <tr>
                            $(Get-BakedProductCell $LeftCardHref $LeftCardSrc 246 $BottomHeight $LeftCardAlt 250)
                            <td width="20"></td>
                            $(Get-BakedProductCell $RightCardHref $RightCardSrc 246 $BottomHeight $RightCardAlt 250)
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        $(Get-SpacerRow 18)
        $(Get-BodyRow $CopyHtml 20 26 '0 64px')
        $(Get-SpacerRow 24)
"@
}

function Build-Section4Recommendation {
    param(
        [hashtable]$Config,
        [string]$HeadingHtml,
        [string]$CopyHtml,
        [string]$BundleLabel,
        [string]$BundleHref,
        [string]$BundleSrc,
        [int]$BundleWidth,
        [int]$BundleHeight,
        [string]$WatchCard,
        [string]$BudsCard,
        [string]$TabCard,
        [string]$ButtonHref
    )

    return @"
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#fbeeee;" width="600">
    <tbody>
        $(Get-SpacerRow 38)
        $(Get-HeadingRow $HeadingHtml 38 44 '0 40px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow $CopyHtml 20 26 '0 60px')
        $(Get-SpacerRow 22)
        <tr><td style="text-align:center;"><span style="font-size:22px; line-height:28px;"><strong><span style="font-family:$headingFont; color:#000000;">$BundleLabel</span></strong></span></td></tr>
        $(Get-SpacerRow 16)
        <tr><td style="text-align:center;"><a href="$BundleHref" target="_blank"><img alt="$BundleLabel" border="0" height="$BundleHeight" src="$BundleSrc" style="width:${BundleWidth}px; height:${BundleHeight}px; display:block; margin:auto;" width="$BundleWidth"></a></td></tr>
        $(Get-SpacerRow 18)
        <tr><td style="text-align:center;">$WatchCard</td></tr>
        $(Get-SpacerRow 14)
        <tr><td style="text-align:center;">$BudsCard</td></tr>
        $(Get-SpacerRow 14)
        <tr><td style="text-align:center;">$TabCard</td></tr>
        $(Get-SpacerRow 24)
"@
}

function Build-NgContent {
    param(
        [hashtable]$State,
        [hashtable]$Config
    )

    $homeUrl = Get-RegionLink $Config 'Home'
    $kvLink = Get-RegionLink $Config 'Kv'
    $section2Link = Get-RegionLink $Config 'Section2'
    $learnMore = Get-RegionLink $Config 'LearnMore'
    $s26Link = Get-RegionLink $Config 'S26Ultra'
    $watchLink = Get-RegionLink $Config 'Watch8'
    $budsLink = Get-RegionLink $Config 'Buds4'
    $tabLink = Get-RegionLink $Config 'A11'
    $tryLink = Get-RegionLink $Config 'TryGalaxy'

    $hero = Use-Asset $State 'All mailer Assets\KV\Group 1106.png' 'Hero_KV.png'
    $crown = Use-Asset $State 'All mailer Assets\Images\Image 7.png' 'Heading_Crown.png'
    $photo = Use-Asset $State 'All mailer Assets\Images\Group 1077.png' 'Section2_Family_Photo.png'
    $s25 = Use-Asset $State 'All mailer Assets\English Products\Group 1120.png' 'Product_Galaxy_S25_Ultra.png'
    $s26 = Use-Asset $State 'All mailer Assets\English Products\Group 1121.png' 'Product_Galaxy_S26.png'
    $a37 = Use-Asset $State 'All mailer Assets\English Products\Group 1119.png' 'Product_Galaxy_A37.png'
    $a57 = Use-Asset $State 'All mailer Assets\English Products\Group 1118.png' 'Product_Galaxy_A57.png'
    $watchBand = Use-Asset $State 'All mailer Assets\English Products\Group 1115.png' 'Card_Galaxy_Watch8_Band.png'
    $battery = Use-Asset $State 'All mailer Assets\English Products\Group 1116.png' 'Card_Magnet_Wireless_Battery_Pack.png'
    $flipsuit = Use-Asset $State 'All mailer Assets\English Products\Group 1117.png' 'Card_Flipsuit_Case.png'
    $bundle = Use-Asset $State 'All mailer Assets\English Products\Mask Group 11.png' 'Bundle_Galaxy_S26_Ultra.png'
    $watch = Use-Asset $State 'All mailer Assets\English Products\Group 1104.png' 'Bundle_Galaxy_Watch8.png'
    $buds = Use-Asset $State 'All mailer Assets\English Products\Group 1103.png' 'Bundle_Galaxy_Buds4_Pro.png'
    $tab = Use-Asset $State 'All mailer Assets\English Products\Group 1105.png' 'Bundle_Galaxy_Tab_A11.png'
    $photoAssist = Use-Asset $State 'All mailer Assets\Images\Image 54.png' 'Section5_Photo_Assist.png'
    $tryGalaxy = Use-Asset $State 'All mailer Assets\Images\Mask Group 21.png' 'Try_Galaxy_QR.png'

    $products = @(
        [ordered]@{ Label = 'Galaxy S25 Ultra'; Link = $section2Link; Src = $s25; Width = 189; Height = 227; Alt = 'Galaxy S25 Ultra' },
        [ordered]@{ Label = 'Galaxy S26'; Link = $s26Link; Src = $s26; Width = 156; Height = 227; Alt = 'Galaxy S26' },
        [ordered]@{ Label = 'Galaxy A37'; Link = $section2Link; Src = $a37; Width = 156; Height = 247; Alt = 'Galaxy A37' },
        [ordered]@{ Label = 'Galaxy A57'; Link = $section2Link; Src = $a57; Width = 165; Height = 247; Alt = 'Galaxy A57' }
    )

    $watchCard = Get-StackCard 'Galaxy Watch8' $watchLink $watch 200 142 'Galaxy Watch8' 'left'
    $budsCard = Get-StackCard 'Galaxy Buds4 Pro' $budsLink $buds 231 144 'Galaxy Buds4 Pro' 'right'
    $tabCard = Get-StackCard 'Galaxy Tab A11' $tabLink $tab 230 142 'Galaxy Tab A11' 'right'

    $section2Open = Build-Section2Shared $Config $crown $photo $products 'Loved by many,<br>chosen for mom' 'Discover the Galaxy favorites.<br>Give her the gift that&rsquo;s already<br>a top choice for moms.' $section2Link
    $section3Open = Build-Section3NgLike $State $Config 'The little details<br>that make it hers' 'Thoughtful accessories that bring<br>comfort, style, and a little more<br>joy to her everyday moments.' $watchBand 512 285 $watchLink 'Galaxy Watch8 Band' $flipsuit (Get-RegionLink $Config 'Flipsuit') 'Flipsuit Case' $battery (Get-RegionLink $Config 'BatteryPack') 'Magnet Wireless Battery Pack' 348 $learnMore
    $section4Open = Build-Section4Recommendation $Config 'Thoughtfully paired<br>for her everyday' 'Bundle the Galaxy devices to elevate her<br>experience and enjoy extra savings.' 'Galaxy S26 Ultra' $s26Link $bundle 401 284 $watchCard $budsCard $tabCard $s26Link

    return @"
<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        $(Get-LogoStripRow $homeUrl)
        $(Get-SpacerRow 22)
        $(Get-HeadingRow 'Show your love<br>with great gifts' 40 46 '0 60px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Our finest Galaxy gifts to help you choose<br>the one that truly completes her day.' 20 26 '0 72px')
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config $kvLink 'Button_Hero_Learn_More.png')
        $(Get-SpacerRow 32)
        <tr><td style="text-align:center; font-size:0; line-height:0;"><a href="$kvLink" target="_blank"><img alt="Mother's Day hero" border="0" height="843" src="$hero" style="width:600px; height:843px; display:block;" width="600"></a></td></tr>
    </tbody>
</table>
$section2Open
        $(Get-ButtonRow $State $Config $section2Link 'Button_Section2_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
$section3Open
        $(Get-ButtonRow $State $Config $learnMore 'Button_Section3_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
$section4Open
        $(Get-ButtonRow $State $Config $s26Link 'Button_Section4_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        $(Get-SpacerRow 38)
        $(Get-HeadingRow 'Make her favorite<br>moments feel<br>even more special' 38 44 '0 40px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Let mom reimagine her shots effortlessly<br>in a single touch with Photo Assist.' 20 26 '0 60px')
        $(Get-SpacerRow 24)
        <tr><td style="text-align:center;"><a href="$(Get-RegionLink $Config 'MakeMoments')" target="_blank"><img alt="Make her favorite moments" border="0" height="542" src="$photoAssist" style="width:515px; height:542px; display:block; margin:auto;" width="515"></a></td></tr>
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config (Get-RegionLink $Config 'MakeMoments') 'Button_Section5_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr>
            <td width="259" style="text-align:center; font-size:0; line-height:0;"><a href="$tryLink" target="_blank"><img alt="Try Galaxy AI" border="0" height="260" src="$tryGalaxy" style="width:259px; height:260px; display:block;" width="259"></a></td>
            <td width="341" style="background-color:#ffffff; padding:0 34px; vertical-align:middle;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr><td><span style="font-size:20px; line-height:28px;"><strong><span style="font-family:$headingFont; color:#000000;">Try Galaxy AI<br>on your phone</span></strong></span></td></tr>
                        $(Get-SpacerRow 18)
                        <tr><td><a href="$tryLink" style="font-family:$bodyFont; color:#000000; font-size:16px; line-height:22px; text-decoration:none;" target="_blank"><strong>Learn more &gt;</strong></a></td></tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Build-KeTzContent {
    param(
        [hashtable]$State,
        [hashtable]$Config
    )

    $homeUrl = Get-RegionLink $Config 'Home'
    $kvLink = Get-RegionLink $Config 'Kv'
    $section2Link = Get-RegionLink $Config 'Section2'
    $s26Link = Get-RegionLink $Config 'S26Ultra'
    $watchLink = Get-RegionLink $Config 'Watch8'
    $tryLink = Get-RegionLink $Config 'TryGalaxy'

    $hero = Use-Asset $State 'All mailer Assets\KV\Group 1106.png' 'Hero_KV.png'
    $crown = Use-Asset $State 'All mailer Assets\Images\Image 7.png' 'Heading_Crown.png'
    $photo = Use-Asset $State 'All mailer Assets\Images\Group 1077.png' 'Section2_Family_Photo.png'
    $a37 = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1127.png' 'Product_Galaxy_A37_5G.png'
    $a57 = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1126.png' 'Product_Galaxy_A57_5G.png'
    $s26 = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1128.png' 'Product_Galaxy_S26_Series.png'
    $watch8 = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1125.png' 'Product_Galaxy_Watch8.png'
    $fridge = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1122.png' 'Card_634L_Side_By_Side.png'
    $freezer = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1124.png' 'Card_371L_Chest_Freezer.png'
    $washer = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1123.png' 'Card_10kg_Bespoke_AI_Washer.png'
    $bundle = Use-Asset $State 'All mailer Assets\TZ_KN Products\Group 1129.png' 'Bundle_Galaxy_S26_Plus_Adapter.png'
    $tryGalaxy = Use-Asset $State 'All mailer Assets\Images\Mask Group 21.png' 'Try_Galaxy_QR.png'

    $products = @(
        [ordered]@{ Label = 'Galaxy A37 5G'; Link = $section2Link; Src = $a37; Width = 156; Height = 245; Alt = 'Galaxy A37 5G' },
        [ordered]@{ Label = 'Galaxy A57 5G'; Link = $section2Link; Src = $a57; Width = 165; Height = 245; Alt = 'Galaxy A57 5G' },
        [ordered]@{ Label = 'Galaxy S26 Series'; Link = $s26Link; Src = $s26; Width = 156; Height = 236; Alt = 'Galaxy S26 Series' },
        [ordered]@{ Label = 'Galaxy Watch8'; Link = $watchLink; Src = $watch8; Width = 172; Height = 236; Alt = 'Galaxy Watch8' }
    )

    $section2Open = Build-Section2Shared $Config $crown $photo $products 'Loved by many,<br>chosen for mom' 'Discover the Galaxy favorites.<br>Give her the gift that&rsquo;s already<br>a top choice for moms.' $section2Link

    return @"
<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        $(Get-LogoStripRow $homeUrl)
        $(Get-SpacerRow 22)
        $(Get-HeadingRow 'Show your love<br>with great gifts' 40 46 '0 60px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Our finest Galaxy gifts to help you choose<br>the one that truly completes her day.' 20 26 '0 72px')
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config $kvLink 'Button_Hero_Learn_More.png')
        $(Get-SpacerRow 32)
        <tr><td style="text-align:center; font-size:0; line-height:0;"><a href="$kvLink" target="_blank"><img alt="Mother's Day hero" border="0" height="843" src="$hero" style="width:600px; height:843px; display:block;" width="600"></a></td></tr>
    </tbody>
</table>
$section2Open
        $(Get-ButtonRow $State $Config $section2Link 'Button_Section2_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#f7c8d7;" width="600">
    <tbody>
        $(Get-SpacerRow 36)
        $(Get-HeadingRow 'The little details<br>that make it hers' 38 44 '0 40px')
        $(Get-SpacerRow 28)
        <tr><td style="text-align:center;"><a href="$(Get-RegionLink $Config 'SideBySide634')" target="_blank"><img alt="634L Side by side Refrigerator Water Dispenser" border="0" height="285" src="$fridge" style="width:512px; height:285px; display:block; margin:auto;" width="512"></a></td></tr>
        $(Get-SpacerRow 20)
        <tr>
            <td style="text-align:center; padding:0 20px;">
                <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                    <tbody>
                        <tr>
                            $(Get-BakedProductCell (Get-RegionLink $Config 'ChestFreezer371') $freezer 246 328 '371L Chest freezer Dark Gray' 250)
                            <td width="20"></td>
                            $(Get-BakedProductCell (Get-RegionLink $Config 'Washer101') $washer 246 328 '10.1kg Bespoke AI Front-load Washer SmartThings' 250)
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        $(Get-SpacerRow 18)
        $(Get-BodyRow 'Thoughtful accessories that bring<br>comfort, style, and a little more<br>joy to her everyday moments.' 20 26 '0 64px')
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config (Get-RegionLink $Config 'SideBySide634') 'Button_Section3_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#fbeeee;" width="600">
    <tbody>
        $(Get-SpacerRow 38)
        $(Get-HeadingRow 'Thoughtfully paired<br>for her everyday' 38 44 '0 40px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Buy a Galaxy S26+ and get a<br>FREE 60W Travel adapter' 20 26 '0 60px')
        $(Get-SpacerRow 22)
        <tr><td style="text-align:center;"><a href="$s26Link" target="_blank"><img alt="Galaxy S26+ bundle" border="0" height="339" src="$bundle" style="width:355px; height:339px; display:block; margin:auto;" width="355"></a></td></tr>
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config $s26Link 'Button_Section4_Learn_More.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr>
            <td width="259" style="text-align:center; font-size:0; line-height:0;"><a href="$tryLink" target="_blank"><img alt="Try Galaxy AI" border="0" height="260" src="$tryGalaxy" style="width:259px; height:260px; display:block;" width="259"></a></td>
            <td width="341" style="background-color:#ffffff; padding:0 34px; vertical-align:middle;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr><td><span style="font-size:20px; line-height:28px;"><strong><span style="font-family:$headingFont; color:#000000;">Try Galaxy AI<br>on your phone</span></strong></span></td></tr>
                        $(Get-SpacerRow 18)
                        <tr><td><a href="$tryLink" style="font-family:$bodyFont; color:#000000; font-size:16px; line-height:22px; text-decoration:none;" target="_blank"><strong>Learn more &gt;</strong></a></td></tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Build-SnContent {
    param(
        [hashtable]$State,
        [hashtable]$Config
    )

    $homeUrl = Get-RegionLink $Config 'HomeFr'
    $kvLink = Get-RegionLink $Config 'Kv'
    $section2Link = Get-RegionLink $Config 'Section2'
    $learnMore = Get-RegionLink $Config 'LearnMore'
    $s26Link = Get-RegionLink $Config 'S26Ultra'
    $watchLink = Get-RegionLink $Config 'Watch8'
    $budsLink = Get-RegionLink $Config 'Buds4'
    $tabLink = Get-RegionLink $Config 'A11'
    $tryLink = Get-RegionLink $Config 'TryGalaxy'

    $hero = Use-Asset $State 'All mailer Assets\KV\Group 1106.png' 'Hero_KV.png'
    $crown = Use-Asset $State 'All mailer Assets\Images\Image 7.png' 'Heading_Crown.png'
    $photo = Use-Asset $State 'All mailer Assets\Images\Group 1077.png' 'Section2_Family_Photo.png'
    $s25 = Use-Asset $State 'All mailer Assets\French Products\Group 1120.png' 'Product_Galaxy_S25_Ultra.png'
    $s26 = Use-Asset $State 'All mailer Assets\French Products\Group 1121.png' 'Product_Galaxy_S26.png'
    $a37 = Use-Asset $State 'All mailer Assets\French Products\Group 1119.png' 'Product_Galaxy_A37.png'
    $a57 = Use-Asset $State 'All mailer Assets\French Products\Group 1118.png' 'Product_Galaxy_A57.png'
    $watchBand = Use-Asset $State 'All mailer Assets\French Products\Group 1099.png' 'Card_Bracelet_Galaxy_Watch8.png'
    $battery = Use-Asset $State 'All mailer Assets\French Products\Group 1100.png' 'Card_Batterie_Externe_Magnetique.png'
    $flipsuit = Use-Asset $State 'All mailer Assets\French Products\Group 1101.png' 'Card_Etui_Flipsuit.png'
    $bundle = Use-Asset $State 'All mailer Assets\French Products\Group 1102.png' 'Bundle_Galaxy_S26_Ultra.png'
    $watch = Use-Asset $State 'All mailer Assets\English Products\Group 1104.png' 'Bundle_Galaxy_Watch8.png'
    $buds = Use-Asset $State 'All mailer Assets\English Products\Group 1103.png' 'Bundle_Galaxy_Buds4_Pro.png'
    $tab = Use-Asset $State 'All mailer Assets\English Products\Group 1105.png' 'Bundle_Galaxy_Tab_A11.png'
    $photoAssist = Use-Asset $State 'All mailer Assets\Images\Image 54.png' 'Section5_Photo_Assist.png'
    $tryGalaxy = Use-Asset $State 'All mailer Assets\Images\Mask Group 21.png' 'Try_Galaxy_QR.png'

    $products = @(
        [ordered]@{ Label = 'Galaxy S25 Ultra'; Link = $section2Link; Src = $s25; Width = 189; Height = 227; Alt = 'Galaxy S25 Ultra' },
        [ordered]@{ Label = 'Galaxy S26'; Link = $s26Link; Src = $s26; Width = 156; Height = 227; Alt = 'Galaxy S26' },
        [ordered]@{ Label = 'Galaxy A37'; Link = $section2Link; Src = $a37; Width = 156; Height = 247; Alt = 'Galaxy A37' },
        [ordered]@{ Label = 'Galaxy A57'; Link = $section2Link; Src = $a57; Width = 165; Height = 247; Alt = 'Galaxy A57' }
    )

    $watchCard = Get-StackCard 'Galaxy Watch8' $watchLink $watch 200 142 'Galaxy Watch8' 'left'
    $budsCard = Get-StackCard 'Galaxy Buds4 Pro' $budsLink $buds 231 144 'Galaxy Buds4 Pro' 'right'
    $tabCard = Get-StackCard 'Galaxy Tab A11' $tabLink $tab 230 142 'Galaxy Tab A11' 'right'

    $section2Open = Build-Section2Shared $Config $crown $photo $products 'Approuv&eacute;s par tous,<br>pens&eacute;s pour maman' 'D&eacute;couvrez les incontournables Galaxy.<br>Offrez-lui le cadeau que les mamans<br>adorent d&eacute;j&agrave;.' $section2Link
    $section3Open = Build-Section3NgLike $State $Config 'Ces petits d&eacute;tails qui<br>font toute la diff&eacute;rence' 'Ces accessoires pens&eacute;s pour allier<br>confort, style et une touche de bonheur<br>au quotidien.' $watchBand 512 285 $watchLink 'Bracelet pour Galaxy Watch8' $flipsuit (Get-RegionLink $Config 'Flipsuit') '&Eacute;tui Flipsuit' $battery (Get-RegionLink $Config 'BatteryPack') 'Batterie externe magn&eacute;tique sans fil' 348 $learnMore
    $section4Open = Build-Section4Recommendation $Config 'Des associations<br>pens&eacute;es pour son<br>quotidien' 'Associez les appareils Galaxy pour sublimer<br>son exp&eacute;rience et profiter d&rsquo;avantages exclusifs.' 'Galaxy S26 Ultra' $s26Link $bundle 401 284 $watchCard $budsCard $tabCard $s26Link

    return @"
<table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
    <tbody>
        $(Get-LogoStripRow $homeUrl)
        $(Get-SpacerRow 22)
        $(Get-HeadingRow 'Dites-lui &laquo; je t&rsquo;aime &raquo;<br>avec les cadeaux<br>Galaxy' 36 42 '0 52px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Une s&eacute;lection des plus beaux cadeaux<br>Galaxy pour trouver celui qui r&eacute;sonne au<br>premier coup d&rsquo;&oelig;il.' 20 26 '0 60px')
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config $kvLink 'Button_Hero_En_Savoir_Plus.png')
        $(Get-SpacerRow 32)
        <tr><td style="text-align:center; font-size:0; line-height:0;"><a href="$kvLink" target="_blank"><img alt="Mother's Day hero" border="0" height="843" src="$hero" style="width:600px; height:843px; display:block;" width="600"></a></td></tr>
    </tbody>
</table>
$section2Open
        $(Get-ButtonRow $State $Config $section2Link 'Button_Section2_En_Savoir_Plus.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
$section3Open
        $(Get-ButtonRow $State $Config $learnMore 'Button_Section3_En_Savoir_Plus.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
$section4Open
        $(Get-ButtonRow $State $Config $s26Link 'Button_Section4_En_Savoir_Plus.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        $(Get-SpacerRow 38)
        $(Get-HeadingRow 'Rendez ses moments<br>pr&eacute;f&eacute;r&eacute;s encore plus<br>pr&eacute;cieux' 38 44 '0 40px')
        $(Get-SpacerRow 16)
        $(Get-BodyRow 'Offrez &agrave; maman la libert&eacute; de r&eacute;inventer ses<br>photos en un geste, avec l&rsquo;Assistant Photo.' 20 26 '0 54px')
        $(Get-SpacerRow 24)
        <tr><td style="text-align:center;"><a href="$(Get-RegionLink $Config 'MakeMoments')" target="_blank"><img alt="Rendez ses moments pr&eacute;f&eacute;r&eacute;s encore plus pr&eacute;cieux" border="0" height="542" src="$photoAssist" style="width:515px; height:542px; display:block; margin:auto;" width="515"></a></td></tr>
        $(Get-SpacerRow 24)
        $(Get-ButtonRow $State $Config (Get-RegionLink $Config 'MakeMoments') 'Button_Section5_En_Savoir_Plus.png')
        $(Get-SpacerRow 34)
    </tbody>
</table>
<table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
    <tbody>
        <tr>
            <td width="259" style="text-align:center; font-size:0; line-height:0;"><a href="$tryLink" target="_blank"><img alt="Essayez Galaxy AI" border="0" height="260" src="$tryGalaxy" style="width:259px; height:260px; display:block;" width="259"></a></td>
            <td width="341" style="background-color:#ffffff; padding:0 34px; vertical-align:middle;">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr><td><span style="font-size:20px; line-height:28px;"><strong><span style="font-family:$headingFont; color:#000000;">Essayez Galaxy AI<br>sur votre t&eacute;l&eacute;phone</span></strong></span></td></tr>
                        $(Get-SpacerRow 18)
                        <tr><td><a href="$tryLink" style="font-family:$bodyFont; color:#000000; font-size:16px; line-height:22px; text-decoration:none;" target="_blank"><strong>En savoir plus &gt;</strong></a></td></tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>
"@
}

function Build-RegionContent {
    param(
        [hashtable]$State,
        [hashtable]$Config
    )

    switch ($Config.Layout) {
        'gh' { return Build-GhContent $State $Config }
        'ng' { return Build-NgContent $State $Config }
        'ketz' { return Build-KeTzContent $State $Config }
        'sn' { return Build-SnContent $State $Config }
        default { throw "Unsupported layout: $($Config.Layout)" }
    }
}

function Build-Mailer {
    param([hashtable]$Config)

    $baseName = [IO.Path]::GetFileNameWithoutExtension($Config.SourceJpg)
    $destDir = Join-Path $script:publishedRoot $baseName
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    $state = @{
        DestDir = $destDir
        Assets = @{}
    }

    $header = Get-HeaderHtml $Config
    $content = Build-RegionContent $state $Config
    $footer = Get-FooterHtml $Config.FooterCode
    $html = $header + $content + $footer
    $htmlPath = Join-Path $destDir ($baseName + '.html')
    [System.IO.File]::WriteAllText($htmlPath, $html, $script:utf8NoBom)
}

New-Item -ItemType Directory -Path $publishedRoot -Force | Out-Null

foreach ($config in $regionConfigs) {
    Build-Mailer $config
}

Write-Output ("Published mailers created in {0}" -f $publishedRoot)