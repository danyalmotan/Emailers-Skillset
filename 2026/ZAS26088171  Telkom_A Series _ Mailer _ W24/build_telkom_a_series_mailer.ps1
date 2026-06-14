$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function New-MailerHtml {
    param(
        [string]$AssetPrefix
    )

    $a57Link = 'https://www.telkom.co.za/online-shop/device-details?flow=device&devicename=Samsung%20Galaxy%20A57%205G&devicecategory=mobileDevices&dealtype=dealGroup&deviceid=cb7151fa-8621-319e-9ec6-b9e3b6f90775&color=Grey&storage=256GB&contractoption=new&dealid=TON2606020&planname=FlexOn%202&utm_source=earned_media&utm_medium=samsung_emailer&utm_campaign=online_exclusive&utm_date=2026_june_july&utm_content=samsung_galaxy_a57'
    $a37Link = 'https://www.telkom.co.za/online-shop/device-details?flow=device&devicename=Samsung%20Galaxy%20A37%205G&devicecategory=mobileDevices&dealtype=dealGroup&deviceid=32200ac8-c1fb-3ccd-a81d-27dba453b5aa&color=Grey&storage=256GB&contractoption=new&dealid=TVC2620674&planname=FlexOn%202&utm_source=earned_media&utm_medium=samsung_emailer&utm_campaign=winter_monthly_deal&utm_date=2026_june_july&utm_content=samsung_galaxy_a37'
    $awesomeLink = 'https://www.telkom.co.za/online-shop/device-gallery?flow=device&brand=Samsung&storage=128GB&storage=256GB&price=Up%20to%20R699&tag=All%20devices&utm_source=earned_media&utm_medium=samsung_emailer&utm_campaign=winter_monthly_deal&utm_date=2026_june_july&utm_content=add_more_awesome'
    $a17Link = 'https://www.telkom.co.za/online-shop/device-details?flow=device&devicename=Samsung%20Galaxy%20A17&devicecategory=mobileDevices&deviceid=659c8768-1f97-30ae-9af5-7de4c45c3619&dealtype=dealGroup&color=Awesome%20Black&storage=128GB&contractoption=new&dealid=TVC2618801&planname=FlexOn%202&utm_source=earned_media&utm_medium=samsung_emailer&utm_campaign=winter_monthly_deal&utm_date=2026_june_july&utm_content=samsung_galaxy_a17'

    return @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>Samsung South Africa</title>
    </head>
    <body style="background-color:#555555; margin:0; padding:0;"><span class="preheader" style="color:transparent; display:none; height:0; max-height:0; max-width:0; opacity:0; overflow:hidden; mso-hide:all; visibility:hidden; width:0;">The new Galaxy A57 | A37 5G</span>
        <table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">
            <tbody>
                <tr>
                    <td align="center" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family:arial,sans-serif; font-size:14px; line-height:18px; color:#000000; text-align:center;" valign="top" width="500"><br>
                                        <span style="color:#000000;">ZZZZZ</span><br>
                                        &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>
                        <br>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#EDEDED; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="font-size:0; line-height:0;"><a href="$a57Link" target="_blank"><img alt="The new Galaxy A57 | A37 5G" border="0" height="866" src="${AssetPrefix}Group 1379.png" style="display:block; width:600px; height:866px;" width="600"></a></td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 44px;"><span style="font-size:28px; line-height:34px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Step into the smarter era</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 46px;"><span style="font-size:19px; line-height:28px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Experience power of Awesome Intelligence and redefine a smarter, more premium life with the new Galaxy A57 | A37 5G</span></span></td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="540">
                                            <tbody>
                                                <tr>
                                                    <td align="center" valign="top" width="255">
                                                        <a href="$a57Link" target="_blank"><img alt="Samsung Galaxy A57 5G" border="0" height="170" src="${AssetPrefix}Image 21.png" style="display:block; width:142px; height:170px; margin:auto;" width="142"></a>
                                                    </td>
                                                    <td width="30"></td>
                                                    <td align="center" valign="top" width="255">
                                                        <a href="$a37Link" target="_blank"><img alt="Samsung Galaxy A37 5G" border="0" height="170" src="${AssetPrefix}Mask Group 2.png" style="display:block; width:141px; height:170px; margin:auto;" width="141"></a>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td height="16" colspan="3" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td align="center" valign="top" width="255">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:210px;" width="210">
                                                            <tbody>
                                                                <tr>
                                                                    <td align="center" height="40" style="background-color:#0099FF;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy A57 5G</span></strong></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; border-bottom:1px solid #000000; padding:11px 8px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><span style="font-size:14px;">From </span><span style="font-size:26px;"><strong>R479</strong></span><span style="font-size:14px;"> x 36</span></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#90E201; border-bottom:1px solid #000000; padding:8px 8px;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">FlexOn2</span></strong></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#FFFFFF; padding:10px 8px 12px 8px;"><span style="font-size:11px; line-height:15px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">2GB All-network Anytime Data<br>500 Telkom Minutes<br>75 All-net Minutes.</span></span></td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td width="30"></td>
                                                    <td align="center" valign="top" width="255">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:210px;" width="210">
                                                            <tbody>
                                                                <tr>
                                                                    <td align="center" height="40" style="background-color:#0099FF;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy A37 5G</span></strong></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; border-bottom:1px solid #000000; padding:11px 8px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><span style="font-size:14px;">From </span><span style="font-size:26px;"><strong>R379</strong></span><span style="font-size:14px;"> x 36</span></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#90E201; border-bottom:1px solid #000000; padding:8px 8px;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">FlexOn2</span></strong></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#FFFFFF; padding:10px 8px 12px 8px;"><span style="font-size:11px; line-height:15px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">2GB All-network Anytime Data<br>500 Telkom Minutes<br>75 All-net Minutes.</span></span></td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td height="18" colspan="3" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td align="center"><a href="$a57Link" target="_blank"><img alt="Buy now" border="0" height="60" src="${AssetPrefix}Group 1369.png" style="display:block; width:153px; height:60px; margin:auto;" width="153"></a></td>
                                                    <td width="30"></td>
                                                    <td align="center"><a href="$a37Link" target="_blank"><img alt="Buy now" border="0" height="60" src="${AssetPrefix}Group 1369.png" style="display:block; width:153px; height:60px; margin:auto;" width="153"></a></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$awesomeLink" target="_blank"><img alt="Add more awesome" border="0" height="124" src="${AssetPrefix}Group 1378.png" style="display:block; width:453px; height:124px; margin:auto;" width="453"></a></td>
                                </tr>
                                <tr>
                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="510">
                                            <tbody>
                                                <tr>
                                                    <td align="center" valign="middle" width="210"><a href="$a17Link" target="_blank"><img alt="Samsung Galaxy A17" border="0" height="185" src="${AssetPrefix}Mask Group 3.png" style="display:block; width:154px; height:185px; margin:auto;" width="154"></a></td>
                                                    <td width="18"></td>
                                                    <td align="center" valign="top" width="282">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:210px;" width="210">
                                                            <tbody>
                                                                <tr>
                                                                    <td align="center" height="40" style="background-color:#0099FF;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy A17</span></strong></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; border-bottom:1px solid #000000; padding:11px 8px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><span style="font-size:14px;">From </span><span style="font-size:26px;"><strong>R219</strong></span><span style="font-size:14px;"> x 36</span></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#90E201; border-bottom:1px solid #000000; padding:8px 8px;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">FlexOn2</span></strong></span></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="center" style="background-color:#FFFFFF; padding:10px 8px 12px 8px;"><span style="font-size:11px; line-height:15px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">2GB All-network Anytime Data<br>500 Telkom Minutes<br>75 All-net Minutes.</span></span></td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$a17Link" target="_blank"><img alt="Buy now" border="0" height="60" src="${AssetPrefix}Group 1369.png" style="display:block; width:153px; height:60px; margin:auto;" width="153"></a></td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFFFFF; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center;"><img alt="Telkom" border="0" height="30" src="${AssetPrefix}Image 118.png" style="display:block; width:122px; height:30px; margin:auto;" width="122"></td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:24px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Samsung SOS+ available on all deals</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="4" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><span style="font-size:14px; line-height:18px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Ts &amp; Cs apply.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><span style="font-size:14px; line-height:18px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Deals valid 07 June - 31 July 2026</span></span></td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0">
                                            <tbody>
                                                <tr>
                                                    <td align="center"><a href="https://www.facebook.com/SamsungSouthAfrica" target="_blank"><img alt="Facebook" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_137.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                    <td width="12"></td>
                                                    <td align="center"><a href="https://www.instagram.com/samsungsa/" target="_blank"><img alt="Instagram" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_138.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                    <td width="12"></td>
                                                    <td align="center"><a href="https://twitter.com/SamsungSA" target="_blank"><img alt="X" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_139.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                    <td width="12"></td>
                                                    <td align="center"><a href="https://www.youtube.com/user/samsungblog" target="_blank"><img alt="Youtube" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_140.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                    <td width="12"></td>
                                                    <td align="center"><a href="https://www.linkedin.com/company/samsung-south-africa?trk=company_logo" target="_blank"><img alt="LinkedIn" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_141.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                    <td width="12"></td>
                                                    <td align="center"><a href="https://www.samsung.com/za/apps/samsung-members/" target="_blank"><img alt="Samsung Members" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_142.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                    <td width="12"></td>
                                                    <td align="center"><a href="https://www.samsung.com/za/apps/samsung-wallet/" target="_blank"><img alt="Samsung Wallet" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_143.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                    <td width="12"></td>
                                                    <td align="center"><a href="https://www.samsung.com/za/offer/samsung-care-plus/" target="_blank"><img alt="Samsung Care Plus" border="0" height="48" src="https://cdn19.mailercdn.net/users/assets/379/images/group_144.png" style="display:block; width:48px; height:48px;" width="48"></a></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><a href="https://www.samsung.com/za/info/legal/" style="color:#000000; text-decoration:none;" target="_blank">Legal</a> <span style="color:#000000;">|</span> <a href="https://www.samsung.com/za/info/privacy/" style="color:#000000; text-decoration:none;" target="_blank">Privacy Policy</a></span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 36px;"><span style="font-size:13px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Terms and Conditions apply. Offer valid while stocks last. E&amp;OE. We cannot be held liable for any misrepresentation caused by unintentional copy errors, typing errors, and/or omissions that may occur in any of our material.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 36px;"><span style="font-size:13px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">This email has been sent to members who have requested to join the mailing list.<br>If you wish to unsubscribe from the mailing list, please click <a href="YYYYY" style="color:#696969;" target="_blank">Unsubscribe</a>.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 36px;"><span style="font-size:13px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">&copy; Copyright 2017-2026 Samsung Electronics. All Rights Reserved.<br>* Do not reply. This email address is for outgoing emails only.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
"@
}

$jobRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26088171  Telkom_A Series _ Mailer _ W24'
$assetsRoot = Join-Path $jobRoot 'ZAS26088171 _ Telkom_A Series _ Mailer _ W24_Assets'
$publishedRoot = Join-Path $jobRoot 'Published'
$baseName = 'ZAS26088171_Telkom_A_Series_Mailer_W24'
$outputDir = Join-Path $publishedRoot $baseName
$rootHtmlPath = Join-Path $publishedRoot ($baseName + '.html')
$folderHtmlPath = Join-Path $outputDir ($baseName + '.html')
$zipPath = Join-Path $outputDir ($baseName + '.zip')

New-Item -Path $publishedRoot -ItemType Directory -Force | Out-Null
New-Item -Path $outputDir -ItemType Directory -Force | Out-Null

Get-ChildItem -Path $assetsRoot -Recurse -File | Where-Object {
    $_.Name -notmatch '@2x' -and $_.Extension -in '.png', '.jpg', '.jpeg', '.gif'
} | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $outputDir $_.Name) -Force
}

$folderHtml = New-MailerHtml -AssetPrefix ''
$rootHtml = New-MailerHtml -AssetPrefix ($baseName + '/')

Write-Utf8NoBom -Path $folderHtmlPath -Content $folderHtml
Write-Utf8NoBom -Path $rootHtmlPath -Content $rootHtml

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

$zipCheck = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
    if ($zipCheck.Entries.Count -ne $filesToZip.Count) {
        throw "Zip entry count ($($zipCheck.Entries.Count)) did not match file count ($($filesToZip.Count))."
    }
}
finally {
    $zipCheck.Dispose()
}