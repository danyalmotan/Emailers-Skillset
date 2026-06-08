$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$jobRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetRoot = Join-Path $jobRoot 'ZAS26113060_export images'
$publishedRoot = Join-Path $jobRoot 'Published'
$footerRoot = Join-Path (Split-Path -Parent $jobRoot) '..\footers'
$footerRoot = [System.IO.Path]::GetFullPath($footerRoot)
$utf8 = [System.Text.UTF8Encoding]::new($false)

$enLink = 'https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/'
$frLink = 'https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/'

function Read-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return [System.IO.File]::ReadAllText($Path, $utf8)
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    [System.IO.File]::WriteAllText($Path, $Content, $utf8)
}

function Get-FooterHtml {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [bool]$IsFrench
    )

    $footerPath = Join-Path $footerRoot ("footer_{0}.txt" -f $Code)
    $footerHtml = Read-Utf8File -Path $footerPath
    $footerHtml = [System.Text.RegularExpressions.Regex]::Replace(
        $footerHtml,
        'href="[^"]*(?:adobe-campaign|<%=)[^"]*"',
        'href="YYYYY"',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    if (-not $IsFrench) {
        $footerHtml = $footerHtml.Replace('©', '&copy;')
    }

    return $footerHtml.Trim()
}

function Copy-Assets {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$AssetMap,
        [Parameter(Mandatory = $true)]
        [string]$DestinationFolder
    )

    foreach ($destName in $AssetMap.Keys) {
        $sourcePath = Join-Path $assetRoot $AssetMap[$destName]
        $destPath = Join-Path $DestinationFolder $destName
        Copy-Item -LiteralPath $sourcePath -Destination $destPath -Force
    }
}

function Build-Html {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Region,
        [Parameter(Mandatory = $true)]
        [string]$FooterHtml
    )

    $heroSection = @"
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#FFFFFF; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;">
                                        <a href="$($Region.Link)" target="_blank"><img alt="$($Region.HeroAlt)" border="0" height="$($Region.HeroHeight)" src="$($Region.HeroImage)" style="display:block; width:600px; height:$($Region.HeroHeight)px;" width="600"></a>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
"@

    $firstToggleSection = ''
    if ($Region.FirstToggleImage) {
        $firstToggleSection = @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#000000;" width="600">
                            <tbody>
                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><img alt="$($Region.FirstToggleAlt)" border="0" height="59" src="$($Region.FirstToggleImage)" style="display:block; margin:auto; width:520px; height:59px;" width="520"></td>
                                </tr>
                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
"@
    }

    return @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>$($Region.Title)</title>
    </head>
    <body style="background-color:#555555;"><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> $($Region.Preheader) </span>
        <table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">
            <tbody>
                <tr>
                    <td align="center" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: #000000; text-align: center;" valign="top" width="500"><br>
                                        <span style="color:#000000;">ZZZZZ</span><br>
                                        &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: #000000; text-align: center;" valign="top" width="500"></td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>
$heroSection$firstToggleSection                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#000000;" width="600">
                            <tbody>
                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 30px;"><span style="font-size:30px; line-height:38px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.SectionOneHeadline)</span></strong></span></td>
                                </tr>
                                <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><img alt="$($Region.SectionOneImageAlt)" border="0" height="443" src="$($Region.SectionOneImage)" style="display:block; margin:auto; width:519px; height:443px;" width="519"></td>
                                </tr>
                                <tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="padding:0 40px;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="250" style="text-align:center;"><span style="font-size:15px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.SectionOneCaptionLeft)</span></span></td>
                                                    <td width="20"></td>
                                                    <td valign="top" width="250" style="text-align:center;"><span style="font-size:15px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.SectionOneCaptionRight)</span></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><img alt="$($Region.SectionOneCompareAlt)" border="0" height="334" src="$($Region.SectionOneCompareImage)" style="display:block; margin:auto; width:520px; height:334px;" width="520"></td>
                                </tr>
                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:19px; line-height:28px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.SectionOneBody)</span></span></td>
                                </tr>
                                <tr><td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><a href="$($Region.Link)" target="_blank"><img alt="$($Region.CtaOneAlt)" border="0" height="$($Region.CtaOneHeight)" src="$($Region.CtaOneImage)" style="display:block; margin:auto; width:$($Region.CtaOneWidth)px; height:$($Region.CtaOneHeight)px;" width="$($Region.CtaOneWidth)"></a></td>
                                </tr>
                                <tr><td height="36" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><img alt="$($Region.SecondToggleAlt)" border="0" height="59" src="$($Region.SecondToggleImage)" style="display:block; margin:auto; width:520px; height:59px;" width="520"></td>
                                </tr>
                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; padding:0 30px;"><span style="font-size:30px; line-height:38px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.SectionTwoHeadline)</span></strong></span></td>
                                </tr>
                                <tr><td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td>
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="520">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="250" style="font-size:0; line-height:0;"><img alt="$($Region.EditOneAlt)" border="0" height="182" src="$($Region.EditOneImage)" style="display:block; width:250px; height:182px;" width="250"></td>
                                                    <td width="20"></td>
                                                    <td valign="middle" width="250" style="text-align:left;"><span style="font-size:18px; line-height:26px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.EditOneBody)</span></span></td>
                                                </tr>
                                                <tr><td colspan="3" height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                <tr>
                                                    <td valign="top" width="250" style="font-size:0; line-height:0;"><img alt="$($Region.EditTwoAlt)" border="0" height="182" src="$($Region.EditTwoImage)" style="display:block; width:250px; height:182px;" width="250"></td>
                                                    <td width="20"></td>
                                                    <td valign="middle" width="250" style="text-align:left;"><span style="font-size:18px; line-height:26px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.EditTwoBody)</span></span></td>
                                                </tr>
                                                <tr><td colspan="3" height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                <tr>
                                                    <td valign="top" width="250" style="font-size:0; line-height:0;"><img alt="$($Region.EditThreeAlt)" border="0" height="181" src="$($Region.EditThreeImage)" style="display:block; width:250px; height:181px;" width="250"></td>
                                                    <td width="20"></td>
                                                    <td valign="middle" width="250" style="text-align:left;"><span style="font-size:18px; line-height:26px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">$($Region.EditThreeBody)</span></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><a href="$($Region.Link)" target="_blank"><img alt="$($Region.CtaTwoAlt)" border="0" height="$($Region.CtaTwoHeight)" src="$($Region.CtaTwoImage)" style="display:block; margin:auto; width:$($Region.CtaTwoWidth)px; height:$($Region.CtaTwoHeight)px;" width="$($Region.CtaTwoWidth)"></a></td>
                                </tr>
                                <tr><td height="48" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
$FooterHtml
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
"@
}

$sharedEnglishAssets = [ordered]@{
    'Toggle_Capture_Edit_1.png' = 'English\Group 2439.png'
    'Toggle_Capture_Edit_2.png' = 'English\Group 2440.png'
    'Feature_Night_Day.png' = 'English\Image 609.png'
    'Feature_Ultra_Wide.png' = 'English\Image 610.png'
    'Edit_Object_Eraser.png' = 'English\Image 611.png'
    'Edit_Best_Face.png' = 'English\Image 612.png'
    'Edit_Suggestion.png' = 'English\Image 613.png'
    'CTA_Learn_More_1.png' = 'English\Buttons\Group 2441.png'
    'CTA_Learn_More_2.png' = 'English\Buttons\Group 2446.png'
}

$sharedFrenchAssets = [ordered]@{
    'Toggle_Capture_Edit_1.png' = 'French\Group 2439.png'
    'Toggle_Capture_Edit_2.png' = 'French\Group 2440.png'
    'Feature_Night_Day.png' = 'French\Image 609.png'
    'Feature_Ultra_Wide.png' = 'French\d4b0e89fca76f827d3c8d0846b4c02c9.png'
    'Edit_Object_Eraser.png' = 'French\Image 611.png'
    'Edit_Best_Face.png' = 'French\Image 612.png'
    'Edit_Suggestion.png' = 'French\Image 613.png'
    'CTA_Learn_More_1.png' = 'French\Buttons\Group 2443.png'
    'CTA_Learn_More_2.png' = 'French\Buttons\Group 2448.png'
}

$englishText = @{
    Preheader = 'The new Galaxy A57 5G. Enjoy a more refined shooting experience with a triple-camera. See more in every shot with Galaxy A57 5G.'
    SectionOneHeadline = 'Night or Day.<br>Every capture counts'
    SectionOneCaptionLeft = 'Own the night,<br>bright with Nightography.'
    SectionOneCaptionRight = 'Post-ready selfies.<br>Clear and vibrant.'
    SectionOneBody = 'Capture studio-grade portraits<br>and landscapes with AI.'
    SectionTwoHeadline = 'Not just your<br>day-to-day edits'
    EditOneBody = 'Easily erase<br>what you don''t<br>want with<br><strong>Object Eraser.</strong>'
    EditTwoBody = 'Pick the best<br>smiles, merge<br>into one with<br><strong>Best Face.</strong>'
    EditThreeBody = 'Smart photo<br>edits, one-tap<br>perfection with<br><strong>Edit Suggestion.</strong>'
    CtaAlt = 'Learn more'
    FirstToggleAlt = 'Capture and Edit'
    SecondToggleAlt = 'Capture and Edit'
}

$frenchText = @{
    Preheader = 'Le nouveau Galaxy A57 5G. Profitez d''une exp&eacute;rience photo plus sophistiqu&eacute;e gr&acirc;ce au triple capteur photo.'
    SectionOneHeadline = 'De jour comme de nuit,<br>chaque photo m&eacute;rite<br>d''&ecirc;tre exceptionnelle.'
    SectionOneCaptionLeft = 'Dominez la nuit avec Nightography.<br>Des clich&eacute;s plus lumineux, m&ecirc;me<br>en faible luminosit&eacute;.'
    SectionOneCaptionRight = 'Des selfies pr&ecirc;ts &agrave; publier.<br>Clairs, &eacute;clatants et<br>naturellement r&eacute;ussis.'
    SectionOneBody = 'Des portraits et paysages dignes d''un studio, gr&acirc;ce &agrave; l''IA.<br>Capturez toute la beaut&eacute; de chaque sc&egrave;ne<br>avec une pr&eacute;cision impressionnante.'
    SectionTwoHeadline = 'Bien plus que<br>de simples retouches.'
    EditOneBody = 'Effacez facilement<br>ce que vous ne voulez<br>plus voir avec l''<strong>Effaceur<br>d''objet.</strong>'
    EditTwoBody = 'Choisissez les<br>meilleurs sourires<br>et fusionnez-les en une<br>seule photo avec la fonction<br><strong>Meilleure Pose.</strong>'
    EditThreeBody = 'Des retouches<br>intelligentes, une<br>perfection en un geste<br>avec la fonction<br><strong>Suggestion de retouches.</strong>'
    CtaAlt = 'En savoir plus'
    FirstToggleAlt = 'Capturez et Retouchez'
    SecondToggleAlt = 'Capturez et Retouchez'
}

$regions = @(
    @{
        Code = 'GH'
        Title = 'Samsung Ghana'
        FooterCode = 'gh'
        Link = $enLink
        Basename = 'GH_ZAS26113060_A_Series_Sustain_Mailer_3_W23'
        HeroImage = 'Hero_KV.png'
        HeroHeight = 1321
        HeroAlt = 'The new Galaxy A57 5G'
        FirstToggleImage = 'Toggle_Capture_Edit_1.png'
        FirstToggleAlt = $englishText.FirstToggleAlt
        SecondToggleImage = 'Toggle_Capture_Edit_2.png'
        SecondToggleAlt = $englishText.SecondToggleAlt
        SectionOneHeadline = $englishText.SectionOneHeadline
        SectionOneImage = 'Feature_Night_Day.png'
        SectionOneImageAlt = 'Night or day Galaxy A57 5G photography'
        SectionOneCaptionLeft = $englishText.SectionOneCaptionLeft
        SectionOneCaptionRight = $englishText.SectionOneCaptionRight
        SectionOneCompareImage = 'Feature_Ultra_Wide.png'
        SectionOneCompareAlt = 'Wide-angle and Ultra Wide Galaxy A57 5G sample'
        SectionOneBody = $englishText.SectionOneBody
        CtaOneImage = 'CTA_Learn_More_1.png'
        CtaOneAlt = $englishText.CtaAlt
        CtaOneWidth = 170
        CtaOneHeight = 50
        SectionTwoHeadline = $englishText.SectionTwoHeadline
        EditOneImage = 'Edit_Object_Eraser.png'
        EditOneAlt = 'Galaxy A57 5G Object Eraser'
        EditOneBody = $englishText.EditOneBody
        EditTwoImage = 'Edit_Best_Face.png'
        EditTwoAlt = 'Galaxy A57 5G Best Face'
        EditTwoBody = $englishText.EditTwoBody
        EditThreeImage = 'Edit_Suggestion.png'
        EditThreeAlt = 'Galaxy A57 5G Edit Suggestion'
        EditThreeBody = $englishText.EditThreeBody
        CtaTwoImage = 'CTA_Learn_More_2.png'
        CtaTwoAlt = $englishText.CtaAlt
        CtaTwoWidth = 172
        CtaTwoHeight = 52
        Preheader = $englishText.Preheader
        IsFrench = $false
        Assets = ([ordered]@{ 'Hero_KV.png' = 'English\KV\Group 2445.png' } + $sharedEnglishAssets)
    },
    @{
        Code = 'NG'
        Title = 'Samsung Nigeria'
        FooterCode = 'ng'
        Link = $enLink
        Basename = 'NG_ZAS26113060_A_Series_Sustain_Mailer_3_W23'
        HeroImage = 'Hero_KV.png'
        HeroHeight = 921
        HeroAlt = 'Galaxy A57 and Galaxy A37 5G launch offer'
        FirstToggleImage = $null
        FirstToggleAlt = ''
        SecondToggleImage = 'Toggle_Capture_Edit_2.png'
        SecondToggleAlt = $englishText.SecondToggleAlt
        SectionOneHeadline = $englishText.SectionOneHeadline
        SectionOneImage = 'Feature_Night_Day.png'
        SectionOneImageAlt = 'Night or day Galaxy A57 5G photography'
        SectionOneCaptionLeft = $englishText.SectionOneCaptionLeft
        SectionOneCaptionRight = $englishText.SectionOneCaptionRight
        SectionOneCompareImage = 'Feature_Ultra_Wide.png'
        SectionOneCompareAlt = 'Wide-angle and Ultra Wide Galaxy A57 5G sample'
        SectionOneBody = $englishText.SectionOneBody
        CtaOneImage = 'CTA_Learn_More_1.png'
        CtaOneAlt = $englishText.CtaAlt
        CtaOneWidth = 170
        CtaOneHeight = 50
        SectionTwoHeadline = $englishText.SectionTwoHeadline
        EditOneImage = 'Edit_Object_Eraser.png'
        EditOneAlt = 'Galaxy A57 5G Object Eraser'
        EditOneBody = $englishText.EditOneBody
        EditTwoImage = 'Edit_Best_Face.png'
        EditTwoAlt = 'Galaxy A57 5G Best Face'
        EditTwoBody = $englishText.EditTwoBody
        EditThreeImage = 'Edit_Suggestion.png'
        EditThreeAlt = 'Galaxy A57 5G Edit Suggestion'
        EditThreeBody = $englishText.EditThreeBody
        CtaTwoImage = 'CTA_Learn_More_2.png'
        CtaTwoAlt = $englishText.CtaAlt
        CtaTwoWidth = 172
        CtaTwoHeight = 52
        Preheader = 'Galaxy A57 | A37 5G launch offer. Buy Galaxy A37 or Galaxy A57 and get a Bluetooth speaker or Headset.'
        IsFrench = $false
        Assets = ([ordered]@{ 'Hero_KV.png' = 'Nigeria\Group 2446.png' } + $sharedEnglishAssets)
    },
    @{
        Code = 'KE'
        Title = 'Samsung Kenya'
        FooterCode = 'ke'
        Link = $enLink
        Basename = 'KE_ZAS26113060_A_Series_Sustain_Mailer_3_W23'
        HeroImage = 'Hero_KV.png'
        HeroHeight = 1321
        HeroAlt = 'The new Galaxy A57 5G'
        FirstToggleImage = 'Toggle_Capture_Edit_1.png'
        FirstToggleAlt = $englishText.FirstToggleAlt
        SecondToggleImage = 'Toggle_Capture_Edit_2.png'
        SecondToggleAlt = $englishText.SecondToggleAlt
        SectionOneHeadline = $englishText.SectionOneHeadline
        SectionOneImage = 'Feature_Night_Day.png'
        SectionOneImageAlt = 'Night or day Galaxy A57 5G photography'
        SectionOneCaptionLeft = $englishText.SectionOneCaptionLeft
        SectionOneCaptionRight = $englishText.SectionOneCaptionRight
        SectionOneCompareImage = 'Feature_Ultra_Wide.png'
        SectionOneCompareAlt = 'Wide-angle and Ultra Wide Galaxy A57 5G sample'
        SectionOneBody = $englishText.SectionOneBody
        CtaOneImage = 'CTA_Learn_More_1.png'
        CtaOneAlt = $englishText.CtaAlt
        CtaOneWidth = 170
        CtaOneHeight = 50
        SectionTwoHeadline = $englishText.SectionTwoHeadline
        EditOneImage = 'Edit_Object_Eraser.png'
        EditOneAlt = 'Galaxy A57 5G Object Eraser'
        EditOneBody = $englishText.EditOneBody
        EditTwoImage = 'Edit_Best_Face.png'
        EditTwoAlt = 'Galaxy A57 5G Best Face'
        EditTwoBody = $englishText.EditTwoBody
        EditThreeImage = 'Edit_Suggestion.png'
        EditThreeAlt = 'Galaxy A57 5G Edit Suggestion'
        EditThreeBody = $englishText.EditThreeBody
        CtaTwoImage = 'CTA_Learn_More_2.png'
        CtaTwoAlt = $englishText.CtaAlt
        CtaTwoWidth = 172
        CtaTwoHeight = 52
        Preheader = $englishText.Preheader
        IsFrench = $false
        Assets = ([ordered]@{ 'Hero_KV.png' = 'English\KV\Group 2445.png' } + $sharedEnglishAssets)
    },
    @{
        Code = 'TZ'
        Title = 'Samsung Tanzania'
        FooterCode = 'tz'
        Link = $enLink
        Basename = 'TZ_ZAS26113060_A_Series_Sustain_Mailer_3_W23'
        HeroImage = 'Hero_KV.png'
        HeroHeight = 1321
        HeroAlt = 'The new Galaxy A57 5G'
        FirstToggleImage = 'Toggle_Capture_Edit_1.png'
        FirstToggleAlt = $englishText.FirstToggleAlt
        SecondToggleImage = 'Toggle_Capture_Edit_2.png'
        SecondToggleAlt = $englishText.SecondToggleAlt
        SectionOneHeadline = $englishText.SectionOneHeadline
        SectionOneImage = 'Feature_Night_Day.png'
        SectionOneImageAlt = 'Night or day Galaxy A57 5G photography'
        SectionOneCaptionLeft = $englishText.SectionOneCaptionLeft
        SectionOneCaptionRight = $englishText.SectionOneCaptionRight
        SectionOneCompareImage = 'Feature_Ultra_Wide.png'
        SectionOneCompareAlt = 'Wide-angle and Ultra Wide Galaxy A57 5G sample'
        SectionOneBody = $englishText.SectionOneBody
        CtaOneImage = 'CTA_Learn_More_1.png'
        CtaOneAlt = $englishText.CtaAlt
        CtaOneWidth = 170
        CtaOneHeight = 50
        SectionTwoHeadline = $englishText.SectionTwoHeadline
        EditOneImage = 'Edit_Object_Eraser.png'
        EditOneAlt = 'Galaxy A57 5G Object Eraser'
        EditOneBody = $englishText.EditOneBody
        EditTwoImage = 'Edit_Best_Face.png'
        EditTwoAlt = 'Galaxy A57 5G Best Face'
        EditTwoBody = $englishText.EditTwoBody
        EditThreeImage = 'Edit_Suggestion.png'
        EditThreeAlt = 'Galaxy A57 5G Edit Suggestion'
        EditThreeBody = $englishText.EditThreeBody
        CtaTwoImage = 'CTA_Learn_More_2.png'
        CtaTwoAlt = $englishText.CtaAlt
        CtaTwoWidth = 172
        CtaTwoHeight = 52
        Preheader = $englishText.Preheader
        IsFrench = $false
        Assets = ([ordered]@{ 'Hero_KV.png' = 'English\KV\Group 2445.png' } + $sharedEnglishAssets)
    },
    @{
        Code = 'CIV'
        Title = 'Samsung C&ocirc;te d''Ivoire'
        FooterCode = 'ci'
        Link = $frLink
        Basename = 'CIV_ZAS26113060_A_Series_Sustain_Mailer_3_W23'
        HeroImage = 'Hero_KV.png'
        HeroHeight = 1353
        HeroAlt = 'Le nouveau Galaxy A57 5G'
        FirstToggleImage = 'Toggle_Capture_Edit_1.png'
        FirstToggleAlt = $frenchText.FirstToggleAlt
        SecondToggleImage = 'Toggle_Capture_Edit_2.png'
        SecondToggleAlt = $frenchText.SecondToggleAlt
        SectionOneHeadline = $frenchText.SectionOneHeadline
        SectionOneImage = 'Feature_Night_Day.png'
        SectionOneImageAlt = 'Photographies Galaxy A57 5G de jour comme de nuit'
        SectionOneCaptionLeft = $frenchText.SectionOneCaptionLeft
        SectionOneCaptionRight = $frenchText.SectionOneCaptionRight
        SectionOneCompareImage = 'Feature_Ultra_Wide.png'
        SectionOneCompareAlt = 'Exemple grand-angle et ultra grand-angle du Galaxy A57 5G'
        SectionOneBody = $frenchText.SectionOneBody
        CtaOneImage = 'CTA_Learn_More_1.png'
        CtaOneAlt = $frenchText.CtaAlt
        CtaOneWidth = 184
        CtaOneHeight = 50
        SectionTwoHeadline = $frenchText.SectionTwoHeadline
        EditOneImage = 'Edit_Object_Eraser.png'
        EditOneAlt = 'Effaceur d''objet Galaxy A57 5G'
        EditOneBody = $frenchText.EditOneBody
        EditTwoImage = 'Edit_Best_Face.png'
        EditTwoAlt = 'Meilleure Pose Galaxy A57 5G'
        EditTwoBody = $frenchText.EditTwoBody
        EditThreeImage = 'Edit_Suggestion.png'
        EditThreeAlt = 'Suggestion de retouches Galaxy A57 5G'
        EditThreeBody = $frenchText.EditThreeBody
        CtaTwoImage = 'CTA_Learn_More_2.png'
        CtaTwoAlt = $frenchText.CtaAlt
        CtaTwoWidth = 186
        CtaTwoHeight = 52
        Preheader = $frenchText.Preheader
        IsFrench = $true
        Assets = ([ordered]@{ 'Hero_KV.png' = 'French\KV\Group 2447.png' } + $sharedFrenchAssets)
    },
    @{
        Code = 'SN'
        Title = 'Samsung Senegal'
        FooterCode = 'sn'
        Link = $frLink
        Basename = 'SN_ZAS26113060_A_Series_Sustain_Mailer_3_W23'
        HeroImage = 'Hero_KV.png'
        HeroHeight = 1353
        HeroAlt = 'Le nouveau Galaxy A57 5G'
        FirstToggleImage = 'Toggle_Capture_Edit_1.png'
        FirstToggleAlt = $frenchText.FirstToggleAlt
        SecondToggleImage = 'Toggle_Capture_Edit_2.png'
        SecondToggleAlt = $frenchText.SecondToggleAlt
        SectionOneHeadline = $frenchText.SectionOneHeadline
        SectionOneImage = 'Feature_Night_Day.png'
        SectionOneImageAlt = 'Photographies Galaxy A57 5G de jour comme de nuit'
        SectionOneCaptionLeft = $frenchText.SectionOneCaptionLeft
        SectionOneCaptionRight = $frenchText.SectionOneCaptionRight
        SectionOneCompareImage = 'Feature_Ultra_Wide.png'
        SectionOneCompareAlt = 'Exemple grand-angle et ultra grand-angle du Galaxy A57 5G'
        SectionOneBody = $frenchText.SectionOneBody
        CtaOneImage = 'CTA_Learn_More_1.png'
        CtaOneAlt = $frenchText.CtaAlt
        CtaOneWidth = 184
        CtaOneHeight = 50
        SectionTwoHeadline = $frenchText.SectionTwoHeadline
        EditOneImage = 'Edit_Object_Eraser.png'
        EditOneAlt = 'Effaceur d''objet Galaxy A57 5G'
        EditOneBody = $frenchText.EditOneBody
        EditTwoImage = 'Edit_Best_Face.png'
        EditTwoAlt = 'Meilleure Pose Galaxy A57 5G'
        EditTwoBody = $frenchText.EditTwoBody
        EditThreeImage = 'Edit_Suggestion.png'
        EditThreeAlt = 'Suggestion de retouches Galaxy A57 5G'
        EditThreeBody = $frenchText.EditThreeBody
        CtaTwoImage = 'CTA_Learn_More_2.png'
        CtaTwoAlt = $frenchText.CtaAlt
        CtaTwoWidth = 186
        CtaTwoHeight = 52
        Preheader = $frenchText.Preheader
        IsFrench = $true
        Assets = ([ordered]@{ 'Hero_KV.png' = 'French\KV\Group 2447.png' } + $sharedFrenchAssets)
    }
)

New-Item -ItemType Directory -Path $publishedRoot -Force | Out-Null

$report = foreach ($region in $regions) {
    $packageFolder = Join-Path $publishedRoot $region.Basename
    $packageHtmlPath = Join-Path $packageFolder ($region.Basename + '.html')
    $rootHtmlPath = Join-Path $publishedRoot ($region.Basename + '.html')
    $zipPath = Join-Path $packageFolder ($region.Basename + '.zip')

    if (Test-Path -LiteralPath $packageFolder) {
        Remove-Item -LiteralPath $packageFolder -Recurse -Force
    }

    if (Test-Path -LiteralPath $rootHtmlPath) {
        Remove-Item -LiteralPath $rootHtmlPath -Force
    }

    New-Item -ItemType Directory -Path $packageFolder -Force | Out-Null
    Copy-Assets -AssetMap $region.Assets -DestinationFolder $packageFolder

    $footerHtml = Get-FooterHtml -Code $region.FooterCode -IsFrench $region.IsFrench
    $html = Build-Html -Region $region -FooterHtml $footerHtml

    Write-Utf8File -Path $packageHtmlPath -Content $html
    Write-Utf8File -Path $rootHtmlPath -Content $html

    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    $filesToZip = Get-ChildItem -LiteralPath $packageFolder -File | Where-Object { $_.Extension -ne '.zip' } | Select-Object -ExpandProperty FullName
    Compress-Archive -LiteralPath $filesToZip -DestinationPath $zipPath -Force

    $archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    $entryCount = $archive.Entries.Count
    $archive.Dispose()

    [pscustomobject]@{
        Region = $region.Code
        Html = [System.IO.Path]::GetFileName($packageHtmlPath)
        PackageFiles = $filesToZip.Count
        ZipEntries = $entryCount
        ZipExists = Test-Path -LiteralPath $zipPath
    }
}

$report | Format-Table -AutoSize