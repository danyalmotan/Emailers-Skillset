Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$jobRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRoot = Join-Path $jobRoot 'ZAS26088170_imags export'
$publishedRoot = Join-Path $jobRoot 'Published'
$baseName = 'SA_ZAS26088170_Estore_Fathers_Day_Mailer_W24'
$outputFolder = Join-Path $publishedRoot $baseName
$outputHtml = Join-Path $outputFolder ($baseName + '.html')
$rootHtml = Join-Path $publishedRoot ($baseName + '.html')
$zipPath = Join-Path $outputFolder ($baseName + '.zip')
$referenceAssetRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26088136  2026_SSA Retainer_Digital_CRM Estore _ Student May _ Mailer _ W20\Published\ZAS26088136_2026_SSA Retainer_Digital_CRM Estore_Student May_Mailer_W20'
$footerPath = 'c:\Users\user\OneDrive\digidanWork\Mailers\footers\footer_ssa.txt'

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Copy-FlatAsset {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FromRoot,

        [Parameter(Mandatory = $true)]
        [string]$RelativePath,

        [Parameter(Mandatory = $true)]
        [string]$ToName
    )

    Copy-Item -LiteralPath (Join-Path $FromRoot $RelativePath) -Destination (Join-Path $outputFolder $ToName) -Force
}

function Render-PriceRows {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Rows
    )

    $parts = foreach ($row in $Rows) {
@"
                                                                                <tr>
                                                                                    <td style="color:#000000; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:12px; line-height:14px; padding:8px 0 8px 10px; border-top:1px solid #1A1A1A; white-space:nowrap;">$($row.Label)</td>
                                                                                    <td style="color:#000000; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:28px; line-height:24px; font-weight:700; text-align:right; padding:8px 10px 8px 0; border-top:1px solid #1A1A1A; white-space:nowrap;">$($row.Value)</td>
                                                                                </tr>
"@
    }

    ($parts -join "`r`n")
}

function Render-ProductCard {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Href,

        [Parameter(Mandatory = $true)]
        [string]$ImageSrc,

        [Parameter(Mandatory = $true)]
        [string]$ImageAlt,

        [Parameter(Mandatory = $true)]
        [int]$ImageWidth,

        [Parameter(Mandatory = $true)]
        [int]$ImageHeight,

        [Parameter(Mandatory = $true)]
        [int]$ImageCellHeight,

        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$Model,

        [Parameter(Mandatory = $true)]
        [object[]]$Rows,

        [Parameter(Mandatory = $true)]
        [string]$ButtonSrc,

        [Parameter(Mandatory = $true)]
        [string]$ButtonAlt,

        [Parameter(Mandatory = $true)]
        [int]$ButtonWidth,

        [Parameter(Mandatory = $true)]
        [int]$ButtonHeight
    )

    $priceRows = Render-PriceRows -Rows $Rows

@"
                                                    <td align="center" bgcolor="#FFFFFF" style="width:250px; background-color:#FFFFFF;" valign="top" width="250">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:250px; background-color:#FFFFFF;" width="250">
                                                            <tbody>
                                                                <tr>
                                                                    <td height="26" style="font-size:1px; line-height:1px;"></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" height="$ImageCellHeight" style="text-align:center; vertical-align:middle;" valign="middle"><a href="$Href" target="_blank"><img alt="$ImageAlt" border="0" height="$ImageHeight" src="$ImageSrc" style="display:block; width:${ImageWidth}px; height:${ImageHeight}px; margin:0 auto;" width="$ImageWidth"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; width:160px; border:1px solid #1A1A1A;" width="160">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td colspan="2" style="background-color:#000000; color:#FFFFFF; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:11px; line-height:14px; font-weight:700; padding:10px 6px 8px 6px;">$Title</td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td colspan="2" style="text-align:center; color:#000000; font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:11px; line-height:14px; padding:8px 6px; border-top:1px solid #1A1A1A;">$Model</td>
                                                                                </tr>
$priceRows
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="18" style="font-size:1px; line-height:1px;"></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center"><a href="$Href" target="_blank"><img alt="$ButtonAlt" border="0" height="$ButtonHeight" src="$ButtonSrc" style="display:block; width:${ButtonWidth}px; height:${ButtonHeight}px; margin:0 auto;" width="$ButtonWidth"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="24" style="font-size:1px; line-height:1px;"></td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
"@
}

function Render-TwoCardSection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BackgroundColor,

        [string]$PromoHtml,

        [Parameter(Mandatory = $true)]
        [string]$LeftCard,

        [Parameter(Mandatory = $true)]
        [string]$RightCard
    )

@"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:$BackgroundColor; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="24" style="font-size:1px; line-height:1px;"></td>
                                </tr>
$PromoHtml
                                <tr>
                                    <td align="center" valign="top">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:600px;" width="600">
                                            <tbody>
                                                <tr>
                                                    <td style="width:40px;"></td>
$LeftCard
                                                    <td style="width:20px;"></td>
$RightCard
                                                    <td style="width:40px;"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Render-SingleCardSection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BackgroundColor,

        [string]$PromoHtml,

        [Parameter(Mandatory = $true)]
        [string]$CardHtml
    )

@"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:$BackgroundColor; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="24" style="font-size:1px; line-height:1px;"></td>
                                </tr>
$PromoHtml
                                <tr>
                                    <td align="center" valign="top">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:600px;" width="600">
                                            <tbody>
                                                <tr>
                                                    <td style="width:175px;"></td>
$CardHtml
                                                    <td style="width:175px;"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="24" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                            </tbody>
                        </table>
"@
}

function Render-ImagePromo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BackgroundColor,

        [Parameter(Mandatory = $true)]
        [string]$Href,

        [Parameter(Mandatory = $true)]
        [string]$ImageSrc,

        [Parameter(Mandatory = $true)]
        [string]$Alt,

        [Parameter(Mandatory = $true)]
        [int]$Width,

        [Parameter(Mandatory = $true)]
        [int]$Height
    )

@"
                                <tr>
                                    <td align="center" style="text-align:center;"><a href="$Href" target="_blank"><img alt="$Alt" border="0" height="$Height" src="$ImageSrc" style="display:block; width:${Width}px; height:${Height}px; margin:0 auto;" width="$Width"></a></td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;"></td>
                                </tr>
"@
}

function Render-LivePromo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

@"
                                <tr>
                                    <td align="center" style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:22px; line-height:28px; font-weight:700;">$Text</td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;"></td>
                                </tr>
"@
}

New-Item -ItemType Directory -Path $publishedRoot -Force | Out-Null
New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null

Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Buttons\Group 2511.png' -ToName 'Button_Buy_Now_Black.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Buttons\Group 2515.png' -ToName 'Button_Learn_More.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Buttons\Group 2521.png' -ToName 'Valid_Until_21_June_2026.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Buttons\Group 26844.png' -ToName 'Button_Download.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Get Match Ready\Group 2517.png' -ToName 'Samsung_Live_Shop.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Group 2519@2x.png' -ToName 'Promo_Save_With_Float@2x.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Group 2520@2x.png' -ToName 'Promo_Signin_R2000@2x.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'KV\Group 2518.png' -ToName 'Hero_KV.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 632.png' -ToName 'Product_S26_Ultra.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 609.png' -ToName 'Product_Watch_Ultra.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 612.png' -ToName 'Product_Tab_S10_FE.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 614.png' -ToName 'Product_Neo_QLED_85.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 615.png' -ToName 'Product_Q990F_Soundbar.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 617.png' -ToName 'Product_Odyssey_G7_40.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 628.png' -ToName 'Product_Odyssey_G4_27.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 621.png' -ToName 'Product_Side_By_Side_564L.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 623.png' -ToName 'Product_Bottom_Freezer_321L.png'
Copy-FlatAsset -FromRoot $sourceRoot -RelativePath 'Image 625.png' -ToName 'Product_AI_Front_Load_11kg.png'

Copy-FlatAsset -FromRoot $referenceAssetRoot -RelativePath 'Finance_Divider.png' -ToName 'Finance_Divider.png'
Copy-FlatAsset -FromRoot $referenceAssetRoot -RelativePath 'Finance_Logo_Float.png' -ToName 'Finance_Logo_Float.png'
Copy-FlatAsset -FromRoot $referenceAssetRoot -RelativePath 'Finance_Logo_PayJustNow.png' -ToName 'Finance_Logo_PayJustNow.png'
Copy-FlatAsset -FromRoot $referenceAssetRoot -RelativePath 'Finance_Logo_Mobicred.png' -ToName 'Finance_Logo_Mobicred.png'

$footerHtml = Get-Content -LiteralPath $footerPath -Raw -Encoding UTF8
$footerHtml = [regex]::Replace($footerHtml, 'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com[^"]+"', 'href="YYYYY"', 1)
$footerHtml = $footerHtml.Replace('©', '&copy;')

$buyNowButton = 'Button_Buy_Now_Black.png'
$learnMoreButton = 'Button_Learn_More.png'

$s26Card = Render-ProductCard -Href 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/' -ImageSrc 'Product_S26_Ultra.png' -ImageAlt 'Galaxy S26 Ultra' -ImageWidth 148 -ImageHeight 150 -ImageCellHeight 170 -Title 'Galaxy S26 Ultra' -Model 'SM-S948 512GB' -Rows @(@{ Label = 'Now'; Value = 'R35 999' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$watchCard = Render-ProductCard -Href 'https://www.samsung.com/za/watches/galaxy-watch/galaxy-watch-ultra-2025-47mm-titanium-blue-lte-sm-l705fzb1xfa/buy/?modelCode=SM-L705FZB1XFA' -ImageSrc 'Product_Watch_Ultra.png' -ImageAlt 'Galaxy Watch Ultra' -ImageWidth 131 -ImageHeight 150 -ImageCellHeight 170 -Title 'Galaxy Watch Ultra' -Model 'SM-L705FZB1XFA' -Rows @(@{ Label = 'Now'; Value = 'R12 999' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$tabCard = Render-ProductCard -Href 'https://www.samsung.com/za/tablets/galaxy-tab-s10-fe/buy/?modelCode=SM-X520NLBAAFA' -ImageSrc 'Product_Tab_S10_FE.png' -ImageAlt 'Galaxy Tab S10 FE' -ImageWidth 225 -ImageHeight 150 -ImageCellHeight 168 -Title 'Galaxy Tab S10 FE Wi-Fi' -Model 'SM-X520NLBAAFA' -Rows @(@{ Label = 'Now'; Value = 'R11 499' }, @{ Label = 'Save'; Value = 'R1 296' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$tvCard = Render-ProductCard -Href 'https://www.samsung.com/za/tvs/neo-qled/qn1ef-85-inch-neo-qled-4k-mini-led-smart-tv-qa85qn1efauxxa/' -ImageSrc 'Product_Neo_QLED_85.png' -ImageAlt '85 inch 4K Neo QLED TV' -ImageWidth 227 -ImageHeight 140 -ImageCellHeight 150 -Title '85&quot; 4K Neo QLED' -Model 'QA85QN1EFAUXXA' -Rows @(@{ Label = 'Now'; Value = 'R29 999' }, @{ Label = 'Save'; Value = 'R4 800' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$soundbarCard = Render-ProductCard -Href 'https://www.samsung.com/za/audio-devices/soundbar/q990f-black-hw-q990f-xa/' -ImageSrc 'Product_Q990F_Soundbar.png' -ImageAlt 'Q-series soundbar' -ImageWidth 220 -ImageHeight 120 -ImageCellHeight 150 -Title 'Q-Series Soundbar 11.1.4 ch' -Model 'HW-Q990F/XA' -Rows @(@{ Label = 'Now'; Value = 'R14 999' }, @{ Label = 'Save'; Value = 'R6 999' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$g7Card = Render-ProductCard -Href 'https://www.samsung.com/za/monitors/gaming/odyssey-g7-g75f-40-inch-180hz-wuhd-ls40fg750euxen/' -ImageSrc 'Product_Odyssey_G7_40.png' -ImageAlt '40 inch Odyssey G7' -ImageWidth 240 -ImageHeight 140 -ImageCellHeight 150 -Title '40&quot; Odyssey G7 WUHD' -Model 'LS40FG750EUXEN' -Rows @(@{ Label = 'Now'; Value = 'R24 999' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$g4Card = Render-ProductCard -Href 'https://www.samsung.com/za/monitors/gaming/odyssey-g4-g40h-27-inch-300hz-fhd-ls27hg402euxen/' -ImageSrc 'Product_Odyssey_G4_27.png' -ImageAlt '27 inch Odyssey G4' -ImageWidth 171 -ImageHeight 140 -ImageCellHeight 150 -Title '27&quot; Odyssey G4 FHD' -Model 'LS27HG402EUXEN' -Rows @(@{ Label = 'Now'; Value = 'R6 199' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$sideBySideCard = Render-ProductCard -Href 'https://www.samsung.com/za/refrigerators/side-by-side/rs4000dc-sbside-with-large-capacity-rs4000dc-side-by-side-with-large-capacity-564l-black-rs57dg4000b4fa/' -ImageSrc 'Product_Side_By_Side_564L.png' -ImageAlt '564L side-by-side refrigerator' -ImageWidth 78 -ImageHeight 150 -ImageCellHeight 170 -Title '564L Side-by-side' -Model 'RS57DG4000B4FA' -Rows @(@{ Label = 'Now'; Value = 'R14 999' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$freezerCard = Render-ProductCard -Href 'https://www.samsung.com/za/refrigerators/bottom-mount-freezer/bottom-freezer--321l-silver-rb33j3611s9-fa/' -ImageSrc 'Product_Bottom_Freezer_321L.png' -ImageAlt '321L bottom freezer' -ImageWidth 51 -ImageHeight 150 -ImageCellHeight 170 -Title '321L Bottom Freezer' -Model 'RB33J3611S9/FA' -Rows @(@{ Label = 'Now'; Value = 'R13 999' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50
$washerCard = Render-ProductCard -Href 'https://www.samsung.com/za/washers-and-dryers/washing-machines/ww7400t-11kg-black-ww11cgp44dsbfa/' -ImageSrc 'Product_AI_Front_Load_11kg.png' -ImageAlt '11kg AI front load with Eco bubble' -ImageWidth 108 -ImageHeight 150 -ImageCellHeight 170 -Title '11kg AI Front Load' -Model 'WW11CGP44DSBFA' -Rows @(@{ Label = 'Now'; Value = 'R11 999' }) -ButtonSrc $buyNowButton -ButtonAlt 'Buy now' -ButtonWidth 134 -ButtonHeight 50

$firstPromo = Render-ImagePromo -BackgroundColor '#E7F4FA' -Href 'https://www.samsung.com/za/smartphones/galaxy-s26-ultra/buy/' -ImageSrc 'Promo_Save_With_Float@2x.png' -Alt 'Sign in or use code LSV50 to save up to R5 000 off your cart' -Width 230 -Height 106
$secondPromo = Render-ImagePromo -BackgroundColor '#E7F4FA' -Href 'https://www.samsung.com/za/tablets/galaxy-tab-s10-fe/buy/?modelCode=SM-X520NLBAAFA' -ImageSrc 'Promo_Signin_R2000@2x.png' -Alt 'Sign in and get up to R2 000 off your cart' -Width 230 -Height 50
$odysseyPromo = Render-LivePromo -Text 'Use code ODYSSEY and get 10% off your cart'

$productSections = @(
    (Render-TwoCardSection -BackgroundColor '#E7F4FA' -PromoHtml $firstPromo -LeftCard $s26Card -RightCard $watchCard)
    (Render-SingleCardSection -BackgroundColor '#E7F4FA' -PromoHtml $secondPromo -CardHtml $tabCard)
    (Render-TwoCardSection -BackgroundColor '#D6D1EA' -PromoHtml '' -LeftCard $tvCard -RightCard $soundbarCard)
    (Render-TwoCardSection -BackgroundColor '#E7F4FA' -PromoHtml $odysseyPromo -LeftCard $g7Card -RightCard $g4Card)
    (Render-SingleCardSection -BackgroundColor '#E7F4FA' -PromoHtml '' -CardHtml $sideBySideCard)
    (Render-TwoCardSection -BackgroundColor '#E7F4FA' -PromoHtml '' -LeftCard $freezerCard -RightCard $washerCard)
) -join "`r`n"

$html = @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>Samsung South Africa</title>
    </head>
    <body style="background-color:#555555; margin:0; padding:0;"><!-- Preheader START =========================================================================== --><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;">Father's Day savings across Samsung favourites</span> <!-- Preheader END =========================================================================== -->
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

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#222224;" width="600">
                            <tbody>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:90%;">
                                            <tbody>
                                                <tr>
                                                    <td style="width:60px;"></td>
                                                    <td>&nbsp;&nbsp;</td>
                                                    <td style="width:132px;"></td>
                                                </tr>
                                                <tr>
                                                    <td style="width:60px;"><a href="https://www.samsung.com/za/apps/samsung-shop-app/" target="_blank"><img align="left" alt="Samsung Shop Icon" height="50" src="https://cdn19.mailercdn.net/users/assets/379/images/gsf3ffregfb-0003.png" style="width:50px; height:50px; float:left;" width="50"></a></td>
                                                    <td><span style="color:#FFFFFF;"><span style="font-size:15px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><strong>Samsung Shop App</strong></span></span><br>
                                                        <span style="font-size:10px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Download the App &amp; save up to 10% off your first order.</span></span><br>
                                                        <span style="font-size:9px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Ts &amp; Cs apply. Valid until 30 June 2026.</span></span></span></td>
                                                    <td style="width:132px;"><a href="https://www.samsung.com/za/apps/samsung-shop-app/" target="_blank"><img align="right" alt="Download" height="40" src="Button_Download.png" style="width:122px; height:40px; float:right;" width="122"></a></td>
                                                </tr>
                                                <tr>
                                                    <td style="width:60px;"></td>
                                                    <td>&nbsp; &nbsp;</td>
                                                    <td style="width:132px;"></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>

                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#E7F4FA; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top"><a href="https://www.samsung.com/za/" target="_blank"><img alt="Father's Day" border="0" height="467" src="Hero_KV.png" style="display:block; width:600px; height:467px;" width="600"></a></td>
                                </tr>
                            </tbody>
                        </table>

$productSections

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#A39CC4; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="38" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                                <tr>
                                    <td align="center" style="color:#FFFFFF; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:18px; line-height:22px; font-weight:700;">Get Match Ready</td>
                                </tr>
                                <tr>
                                    <td height="16" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                                <tr>
                                    <td align="center"><a href="https://www.samsung.com/za/samsung-live/" target="_blank"><img alt="Samsung Live Shop" border="0" height="84" src="Samsung_Live_Shop.png" style="display:block; width:103px; height:84px; margin:0 auto;" width="103"></a></td>
                                </tr>
                                <tr>
                                    <td height="18" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                                <tr>
                                    <td align="center" style="color:#FFFFFF; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:20px; line-height:22px; font-weight:700;">Live Shopping Event<br>
                                        A New Line-up is Taking the Field</td>
                                </tr>
                                <tr>
                                    <td height="14" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                                <tr>
                                    <td align="center" style="color:#FFFFFF; text-align:center; font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; line-height:20px; padding:0 28px;">Be among the first to discover Samsung's<br>
                                        latest innovations, exciting product reveals,<br>
                                        and exclusive offers.</td>
                                </tr>
                                <tr>
                                    <td height="12" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                                <tr>
                                    <td align="center" style="color:#FFFFFF; text-align:center; font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; line-height:20px;">Save the Date: 10 June 2026</td>
                                </tr>
                                <tr>
                                    <td height="8" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                                <tr>
                                    <td align="center" style="color:#FFFFFF; text-align:center; font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; line-height:20px;"><a href="https://www.samsung.com/za/samsung-live/" style="color:#FFFFFF; text-decoration:none;" target="_blank">https://www.samsung.com/za/samsung-live/</a></td>
                                </tr>
                                <tr>
                                    <td height="32" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#000000; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="42" style="font-size:1px; line-height:1px;">&nbsp;&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center" style="color:#FFFFFF; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:36px; line-height:42px; font-weight:700;">Flexible Finance<br>
                                        Options Available</td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center" style="color:#FFFFFF; text-align:center; font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; line-height:20px;">Explore multiple ways to pay for your<br>
                                        favourite Samsung product.</td>
                                </tr>
                                <tr>
                                    <td height="24" style="font-size:1px; line-height:1px;">&nbsp;&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center"><a href="https://www.samsung.com/za/why-buy-online/#finance" target="_blank"><img alt="Learn more" border="0" height="50" src="Button_Learn_More.png" style="display:block; width:170px; height:50px; margin:0 auto;" width="170"></a></td>
                                </tr>
                                <tr>
                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp; &nbsp; &nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:520px; background-color:#FFFFFF; border-radius:28px;" width="520">
                                            <tbody>
                                                <tr>
                                                    <td style="text-align:center; padding:20px 0; border-radius:28px 0 0 28px;" width="129"><a href="https://www.samsung.com/za/why-buy-online/#finance" target="_blank"><img alt="Float" border="0" height="26" src="Finance_Logo_Float.png" style="display:block; width:52px; height:26px; margin:0 auto;" width="52"></a></td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:15px; line-height:20px; font-weight:700;" width="129">Using your<br>
                                                        credit card</td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:15px; line-height:20px;" width="129"><strong style="font-size:20px; line-height:20px;">0%</strong><br>
                                                        interest</td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; line-height:18px; border-radius:0 28px 28px 0;" width="130"><span style="font-size:12px;">Up to<br>
                                                        <strong style="font-size:14px; line-height:18px;">6</strong><br>
                                                        months to pay</span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="14" style="font-size:1px; line-height:1px;">&nbsp; &nbsp; &nbsp;&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:520px; background-color:#FFFFFF; border-radius:28px;" width="520">
                                            <tbody>
                                                <tr>
                                                    <td style="text-align:center; padding:20px 0; border-radius:28px 0 0 28px;" width="129"><a href="https://www.samsung.com/za/why-buy-online/#finance" target="_blank"><img alt="PayJustNow" border="0" height="12" src="Finance_Logo_PayJustNow.png" style="display:block; width:80px; height:12px; margin:0 auto;" width="80"></a></td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:15px; line-height:20px; font-weight:700;" width="129">Instant<br>
                                                        approval</td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:15px; line-height:20px;" width="129"><strong style="font-size:20px; line-height:20px;">0%</strong><br>
                                                        interest</td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:14px; line-height:18px; border-radius:0 28px 28px 0;" width="130"><span style="font-size:12px;">Pay back in<br>
                                                        <strong style="font-size:14px; line-height:18px;">3</strong><br>
                                                        easy instalments</span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="14" style="font-size:1px; line-height:1px;">&nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="width:520px; background-color:#FFFFFF; border-radius:28px;" width="520">
                                            <tbody>
                                                <tr>
                                                    <td style="text-align:center; padding:20px 0; border-radius:28px 0 0 28px;" width="129"><a href="https://www.samsung.com/za/why-buy-online/#finance" target="_blank"><img alt="Mobicred" border="0" height="28" src="Finance_Logo_Mobicred.png" style="display:block; width:78px; height:28px; margin:0 auto;" width="78"></a></td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:15px; line-height:20px; font-weight:700;" width="129">Easy online<br>
                                                        application</td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:15px; line-height:20px;" width="129">Competitive<br>
                                                        interest<br>
                                                        rate</td>
                                                    <td width="1"><img alt="" border="0" height="55" src="Finance_Divider.png" style="display:block; width:1px; height:55px;" width="1"></td>
                                                    <td style="color:#000000; text-align:center; font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; font-size:15px; line-height:20px; border-radius:0 28px 28px 0;" width="130"><span style="font-size:12px;">Revolving<br>
                                                        credit</span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="40" style="font-size:1px; line-height:1px;">&nbsp;&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFFFFF; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="38" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                                <tr>
                                    <td align="center"><a href="https://www.samsung.com/za/" target="_blank"><img alt="Deals valid until 21 June 2026" border="0" height="40" src="Valid_Until_21_June_2026.png" style="display:block; width:311px; height:40px; margin:0 auto;" width="311"></a></td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;"></td>
                                </tr>
                            </tbody>
                        </table>

$footerHtml
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
"@

Write-Utf8NoBom -Path $outputHtml -Content $html

$rootHtmlContent = [regex]::Replace(
    $html,
    'src="(?!https?:|cid:)([^"]+)"',
    {
        param($match)
        'src="' + $baseName + '/' + $match.Groups[1].Value + '"'
    }
)

Write-Utf8NoBom -Path $rootHtml -Content $rootHtmlContent

if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

$filesToZip = Get-ChildItem -LiteralPath $outputFolder -File | Where-Object { $_.Extension -ne '.zip' } | Select-Object -ExpandProperty FullName
Compress-Archive -LiteralPath $filesToZip -DestinationPath $zipPath -Force

$archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$report = [pscustomobject]@{
    OutputFolder = $outputFolder
    HtmlExists = Test-Path -LiteralPath $outputHtml
    RootHtmlExists = Test-Path -LiteralPath $rootHtml
    PackageFiles = (Get-ChildItem -LiteralPath $outputFolder -File | Where-Object { $_.Extension -ne '.zip' }).Count
    ZipEntries = $archive.Entries.Count
    ZipExists = Test-Path -LiteralPath $zipPath
}
$archive.Dispose()

$report | Format-List | Out-String