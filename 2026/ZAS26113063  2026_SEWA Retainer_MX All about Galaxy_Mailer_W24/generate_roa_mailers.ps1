$ErrorActionPreference = 'Stop'

$jobRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113063  2026_SEWA Retainer_MX All about Galaxy_Mailer_W24'
$assetsRoot = Join-Path $jobRoot 'ZAS26113063 _ 2026_SEWA Retainer_MX All about Galaxy_Mailer_W24_Assets\ZAS26113063 _ 2026_SEWA Retainer_MX All about Galaxy_Mailer_W24_Assets'
$publishedRoot = Join-Path $jobRoot 'Published'
$footerRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\footers'
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$mailers = @(
    @{ Code = 'GH'; Country = 'Ghana'; Footer = 'footer_gh.txt'; BaseName = 'GH_ZAS26113063_All_about_Galaxy_Mailer_W24' },
    @{ Code = 'NG'; Country = 'Nigeria'; Footer = 'footer_ng.txt'; BaseName = 'NG_ZAS26113063_All_about_Galaxy_Mailer_W24' },
    @{ Code = 'KE'; Country = 'Kenya'; Footer = 'footer_ke.txt'; BaseName = 'KE_ZAS26113063_All_about_Galaxy_Mailer_W24' },
    @{ Code = 'TZ'; Country = 'Tanzania'; Footer = 'footer_tz.txt'; BaseName = 'TZ_ZAS26113063_All_about_Galaxy_Mailer_W24' }
)

$assetFiles = @(
    '01_KV_pc.gif',
    'Group 1.png',
    'Group 6.png',
    'Group 7.png',
    'Image 10.png',
    'Image 11.png',
    'Image 12.png',
    'Image 13.png',
    'Image 14.png'
)

$template = @'
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>{TITLE}</title>
    </head>
    <body style="background-color:#555555;"><!-- Preheader START =========================================================================== --><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> All about Galaxy </span> <!-- Preheader END =========================================================================== -->
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
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family:arial,sans-serif; font-size:14px; line-height:18px; color:#000000; text-align:center;" valign="top" width="500"></td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:left; padding:0 36px;"><span style="font-size:32px; line-height:32px; letter-spacing:1px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">SAMSUNG</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="58" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:28px; line-height:34px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">All about Galaxy</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:18px; line-height:28px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Life is full of possibilities and we are born open to them. In the same way, Galaxy is created to be open to all and ready for anything. With innovative devices and easy Galaxy AI, every experience becomes seamless and effortless.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:22px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Discover our new and innovative Galaxy devices</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="All about Galaxy hero" border="0" height="267" src="01_KV_pc.gif" style="display:block; width:600px; height:267px;" width="600"></a></td>
                                </tr>
                                <tr>
                                    <td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Galaxy S26 Ultra, Galaxy Z Fold7, Galaxy Buds4 Pro and Galaxy Watch8" border="0" height="133" src="Group 6.png" style="display:block; width:512px; height:133px; margin:auto;" width="512"></a></td>
                                </tr>
                                <tr>
                                    <td height="36" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:22px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Find out how Galaxy expands your everyday</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="512">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="247"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Galaxy AI" border="0" height="182" src="Image 10.png" style="display:block; width:247px; height:182px;" width="247"></a></td>
                                                    <td width="18"></td>
                                                    <td valign="top" width="247"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Switch to Galaxy" border="0" height="182" src="Image 11.png" style="display:block; width:247px; height:182px;" width="247"></a></td>
                                                </tr>
                                                <tr>
                                                    <td height="18" colspan="3" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" style="text-align:center; padding:0 6px;"><span style="font-size:22px; line-height:28px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy AI</span></strong></span><br>
                                                        <span style="font-size:16px; line-height:24px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy AI is your true AI companion that brings practical help into your everyday life.</span></span></td>
                                                    <td width="18"></td>
                                                    <td valign="top" style="text-align:center; padding:0 6px;"><span style="font-size:22px; line-height:28px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Switch to Galaxy</span></strong></span><br>
                                                        <span style="font-size:16px; line-height:24px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Switch to Galaxy and discover a world where all your technology works together seamlessly.</span></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="42" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:22px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Discover the tech behind our next-gen Galaxy devices</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="512">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="247"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Privacy Display" border="0" height="182" src="Image 12.png" style="display:block; width:247px; height:182px;" width="247"></a></td>
                                                    <td width="18"></td>
                                                    <td valign="top" width="247"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Proscaler" border="0" height="182" src="Image 13.png" style="display:block; width:247px; height:182px;" width="247"></a></td>
                                                </tr>
                                                <tr>
                                                    <td height="18" colspan="3" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" style="text-align:center; padding:0 6px;"><span style="font-size:22px; line-height:28px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Privacy Display</span></strong></span><br>
                                                        <span style="font-size:16px; line-height:24px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Samsung's first Privacy display on mobile.</span></span></td>
                                                    <td width="18"></td>
                                                    <td valign="top" style="text-align:center; padding:0 6px;"><span style="font-size:22px; line-height:28px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Proscaler</span></strong></span><br>
                                                        <span style="font-size:16px; line-height:24px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Naturally clear and colorful display.</span></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="42" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:22px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Discover what benefits you can get</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="512">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="247"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Samsung Care Plus" border="0" height="165" src="Image 14.png" style="display:block; width:247px; height:165px;" width="247"></a></td>
                                                    <td width="18"></td>
                                                    <td valign="top" width="247"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Try Galaxy" border="0" height="165" src="Group 7.png" style="display:block; width:245px; height:165px; margin-left:auto;" width="245"></a></td>
                                                </tr>
                                                <tr>
                                                    <td height="18" colspan="3" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" style="text-align:center; padding:0 8px;"><span style="font-size:18px; line-height:26px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Certified care by Samsung experts</span></strong></span><br>
                                                        <span style="font-size:16px; line-height:24px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Keep your Samsung Galaxy device protected with Samsung Care+.</span></span></td>
                                                    <td width="18"></td>
                                                    <td valign="top" style="text-align:center; padding:0 8px;"><span style="font-size:18px; line-height:26px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Try Galaxy</span></strong></span><br>
                                                        <span style="font-size:16px; line-height:24px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Try Galaxy on your phone</span></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="https://www.samsung.com/africa_en/mobile/" target="_blank"><img alt="Learn more" border="0" height="59" src="Group 1.png" style="display:block; margin:auto; width:181px; height:59px;" width="181"></a></td>
                                </tr>
                                <tr>
                                    <td height="48" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
{FOOTER}
'@

New-Item -Path $publishedRoot -ItemType Directory -Force | Out-Null

foreach ($mailer in $mailers) {
    $footerPath = Join-Path $footerRoot $mailer.Footer
    $footer = [System.IO.File]::ReadAllText($footerPath, [System.Text.Encoding]::UTF8)
    $footer = $footer.Replace('https://samsung-mena-mkt-prod6-m.adobe-campaign.com/webApp/smgUnsub?id=<%= escapeUrl(recipient.cryptedId) %>&lang=en&unsub=true', 'YYYYY')
    $footer = $footer.Replace('&copy;', '©')
    $footer = $footer.Replace('©', '&copy;')

    $outputDir = Join-Path $publishedRoot $mailer.BaseName
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null

    foreach ($assetFile in $assetFiles) {
        Copy-Item -Path (Join-Path $assetsRoot $assetFile) -Destination (Join-Path $outputDir $assetFile) -Force
    }

    $html = $template.Replace('{TITLE}', "Samsung $($mailer.Country)").Replace('{FOOTER}', $footer)
    $htmlPath = Join-Path $outputDir ($mailer.BaseName + '.html')
    [System.IO.File]::WriteAllText($htmlPath, $html, $utf8NoBom)
}