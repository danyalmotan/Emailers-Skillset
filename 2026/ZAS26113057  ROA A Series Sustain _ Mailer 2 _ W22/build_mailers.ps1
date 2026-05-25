# ============================================================
# A Series Sustain Mailer 2 W22 - Build All 6 Regions
# GH, NG, KE, TZ (English) + SN, CIV (French)
# ============================================================

Add-Type -AssemblyName 'System.IO.Compression'
Add-Type -AssemblyName 'System.IO.Compression.FileSystem'

$jobBase    = 'C:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113057  ROA A Series Sustain _ Mailer 2 _ W22'
$assetsEng  = "$jobBase\ZAS26113057 _ ROA A Series Sustain _ Mailer 2 _ W22_Assets\English"
$assetsFr   = "$jobBase\ZAS26113057 _ ROA A Series Sustain _ Mailer 2 _ W22_Assets\French"
$footersDir = 'C:\Users\user\OneDrive\digidanWork\Mailers\footers'
$published  = "$jobBase\published"

$linkEn = 'https://www.samsung.com/africa_en/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/'
$linkFr = 'https://www.samsung.com/africa_fr/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-128gb-sm-a576bzamafb/'

function Get-Footer([string]$code) {
    $path = "$footersDir\footer_$code.txt"
    $html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $html = $html -replace 'href="https://samsung-mena-mkt-prod6-m\.adobe-campaign\.com/webApp/smgUnsub[^"]*"', 'href="YYYYY"'
    return $html
}

function Build-EnHtml([string]$title, [string]$link, [string]$footer) {
    $pre = "Now's your chance to move. Meet Galaxy A57 | A37 5G, now upgraded to deliver even more of what you love."
    $html = @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>$title</title>
    </head>
    <body style="background-color:#555;"><!-- Preheader START =========================================================================== --><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> $pre </span> <!-- Preheader END =========================================================================== -->
        <table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">
            <tbody>
                <tr>
                    <td align="center" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <!--olhide start-->
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"><br>
                                        <span style="color:#000000;">ZZZZZ</span><br>
                                        &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                    <!--olhide end-->
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"></td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>
                        <!-- KV + Main copy section -->
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;">
                                        <a href="$link" target="_blank"><img alt="The new Galaxy A57 | A37 5G" border="0" height="946" src="Group_1341.png" style="width:600px; height:946px; display:block;" width="600"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Now's your chance<br>to move</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:18px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Meet Galaxy A57 | A37 5G,<br>now upgraded to deliver even<br>more of what you love.</span></span>
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <a href="$link" target="_blank"><img alt="Learn more" border="0" height="60" src="Group_1337.png" style="width:181px; height:60px; display:block; margin:auto;" width="181"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
                        <!-- Galaxy A57 5G. More awesome section -->
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy A57 5G.<br>More awesome</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compared with</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A54 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="6.7 inch, 6.9 mm, 176 g, 29 hrs video playback vs Galaxy A54 5G" border="0" height="423" src="Group_1400.png" style="width:512px; height:423px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compared with</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A56 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="CPU 15%, GPU 15% - Faster performance" border="0" height="117" src="Group_1392.png" style="width:512px; height:117px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <a href="$link" target="_blank"><img alt="Compare now" border="0" height="60" src="Group_1376.png" style="width:221px; height:60px; display:block; margin:auto;" width="221"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
                        <!-- See what has changed section -->
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">See what has<br>changed</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compared with</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A34 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="176 g, 6.7 inch FHD+ Super AMOLED, 29 hrs, IP68, 196 g vs Galaxy A34 5G" border="0" height="368" src="Group_1398.png" style="width:512px; height:368px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compared with</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A36 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="CPU 12%, GPU 19% - Faster performance" border="0" height="117" src="Group_1399.png" style="width:512px; height:117px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:18px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Slimmer and lighter in hand,<br>yet more powerful where it counts,<br>built to keep up with your everyday<br>with greater ease.</span></span>
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <a href="$link" target="_blank"><img alt="Compare now" border="0" height="60" src="Group_1376.png" style="width:221px; height:60px; display:block; margin:auto;" width="221"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
                        $footer
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
"@
    return $html
}

function Build-FrHtml([string]$title, [string]$link, [string]$footer) {
    $pre = "Le moment est venu de passer a la vitesse superieure. Decouvrez les nouveaux Galaxy A57 | A37 5G."
    $html = @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>$title</title>
    </head>
    <body style="background-color:#555;"><!-- Preheader START =========================================================================== --><span class="preheader" style="color: transparent; display: none; height: 0; max-height: 0; max-width: 0; opacity: 0; overflow: hidden; mso-hide: all; visibility: hidden; width: 0;"> $pre </span> <!-- Preheader END =========================================================================== -->
        <table border="0" cellpadding="0" cellspacing="0" id="bodyTable" style="height:100%;" width="100%">
            <tbody>
                <tr>
                    <td align="center" valign="top">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <!--olhide start-->
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"><br>
                                        <span style="color:#000000;">ZZZZZ</span><br>
                                        &nbsp; &nbsp; &nbsp;&nbsp;</td>
                                    <!--olhide end-->
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                                <tr>
                                    <td align="center" valign="top" width="10"></td>
                                    <td style="font-family: arial, sans-serif; font-size: 14px; line-height: 18px; color: rgb(0, 0, 0); text-align: center;" valign="top" width="500"></td>
                                    <td align="center" valign="top" width="10"></td>
                                </tr>
                            </tbody>
                        </table>
                        <!-- KV + Main copy section -->
                        <table border="0" cellpadding="0" cellspacing="0" class="mailcont" id="emailContainer" style="background-color:#ffffff; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;">
                                        <a href="$link" target="_blank"><img alt="Les nouveaux Galaxy A57 | A37 5G" border="0" height="946" src="Group_1341.png" style="width:600px; height:946px; display:block;" width="600"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Le moment est venu<br>de passer &#224; la vitesse<br>sup&#233;rieure.</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:18px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Les Galaxy A57 | A37 5G ont &#233;t&#233;<br>repens&#233;s pour vous offrir encore plus<br>de ce que vous aimez au quotidien.</span></span>
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <a href="$link" target="_blank"><img alt="En savoir plus" border="0" height="60" src="Group_1337.png" style="width:215px; height:60px; display:block; margin:auto;" width="215"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
                        <!-- Galaxy A57 5G. Encore plus exceptionnel section -->
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy A57 5G.<br>Encore plus exceptionnel</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compar&#233; au</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A54 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="6,7 pouces, 6,9 mm, 176 g, 29 h de lecture video vs Galaxy A54 5G" border="0" height="423" src="Group_1395.png" style="width:512px; height:423px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compar&#233; au</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A56 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="CPU 15%, GPU 15% - performances plus rapides" border="0" height="117" src="Group_1394.png" style="width:512px; height:117px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <a href="$link" target="_blank"><img alt="Comparez maintenant" border="0" height="60" src="Group_1376.png" style="width:297px; height:60px; display:block; margin:auto;" width="297"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
                        <!-- Decouvrez les nouveautes section -->
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:36px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">D&#233;couvrez<br>les nouveaut&#233;s</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compar&#233; au</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A34 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="176 g, 6,7 pouce FHD+ Super AMOLED, 29 h, IP68, 196 g vs Galaxy A34 5G" border="0" height="368" src="Group_1396.png" style="width:512px; height:368px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 20px;">
                                        <span style="font-size:14px; color:#555555;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Compar&#233; au</span></span>&nbsp;<span style="font-size:22px; color:#000000;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; text-decoration:underline;">Galaxy A36 5G</span></strong></span>
                                    </td>
                                </tr>
                                <tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <img alt="CPU 12%, GPU 19% - performances plus rapides" border="0" height="117" src="Group_1397.png" style="width:512px; height:117px; display:block; margin:auto;" width="512">
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center; padding:0 40px;">
                                        <span style="font-size:18px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Plus fin et plus l&#233;ger en main,<br>mais plus puissant l&#224; o&#249; cela compte,<br>con&#231;u pour vous suivre au quotidien<br>en toute fluidit&#233;.</span></span>
                                    </td>
                                </tr>
                                <tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                <tr>
                                    <td align="center" style="text-align:center;">
                                        <a href="$link" target="_blank"><img alt="Comparez maintenant" border="0" height="60" src="Group_1376.png" style="width:297px; height:60px; display:block; margin:auto;" width="297"></a>
                                    </td>
                                </tr>
                                <tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                            </tbody>
                        </table>
                        $footer
                    </td>
                </tr>
            </tbody>
        </table>
    </body>
</html>
"@
    return $html
}

function Create-Zip([string]$folderPath, [string]$zipPath) {
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -ne '.zip' }
    $zipStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::Create)
    $archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
    foreach ($f in $files) {
        $entry = $archive.CreateEntry($f.Name, [System.IO.Compression.CompressionLevel]::Optimal)
        $entryStream = $entry.Open()
        $fileStream = [System.IO.File]::OpenRead($f.FullName)
        $fileStream.CopyTo($entryStream)
        $fileStream.Close()
        $entryStream.Close()
    }
    $archive.Dispose()
    $zipStream.Close()
    $count = (Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -ne '.zip' }).Count
    Write-Host "  Zipped $count files -> $(Split-Path $zipPath -Leaf)"
}

# ============================================================
# Region definitions
# ============================================================

# English regions: GH, NG, KE, TZ
$engRegions = @(
    @{ Code = 'GH'; Title = 'Samsung Ghana';    FooterCode = 'gh' },
    @{ Code = 'NG'; Title = 'Samsung Nigeria';  FooterCode = 'ng' },
    @{ Code = 'KE'; Title = 'Samsung Kenya';    FooterCode = 'ke' },
    @{ Code = 'TZ'; Title = 'Samsung Tanzania'; FooterCode = 'tz' }
)

# French regions: SN, CIV
$frRegions = @(
    @{ Code = 'SN';  Title = 'Samsung Senegal';         FooterCode = 'sn' },
    @{ Code = 'CIV'; Title = 'Samsung Cote d Ivoire'; FooterCode = 'ci' }
)

# ============================================================
# English image assets (1x, sanitized names)
# ============================================================
$engImages = @(
    @{ Src = "$assetsEng\Group 1341.png"; Dest = 'Group_1341.png' },
    @{ Src = "$assetsEng\Group 1392.png"; Dest = 'Group_1392.png' },
    @{ Src = "$assetsEng\Group 1398.png"; Dest = 'Group_1398.png' },
    @{ Src = "$assetsEng\Group 1399.png"; Dest = 'Group_1399.png' },
    @{ Src = "$assetsEng\Group 1400.png"; Dest = 'Group_1400.png' },
    @{ Src = "$assetsEng\Buttons\Group 1337.png"; Dest = 'Group_1337.png' },
    @{ Src = "$assetsEng\Buttons\Group 1376.png"; Dest = 'Group_1376.png' }
)

# French image assets (1x, sanitized names)
$frImages = @(
    @{ Src = "$assetsEng\Group 1341.png"; Dest = 'Group_1341.png' },
    @{ Src = "$assetsFr\Group 1394.png";  Dest = 'Group_1394.png' },
    @{ Src = "$assetsFr\Group 1395.png";  Dest = 'Group_1395.png' },
    @{ Src = "$assetsFr\Group 1396.png";  Dest = 'Group_1396.png' },
    @{ Src = "$assetsFr\Group 1397.png";  Dest = 'Group_1397.png' },
    @{ Src = "$assetsFr\Buttons\Group 1337.png"; Dest = 'Group_1337.png' },
    @{ Src = "$assetsFr\Buttons\Group 1376.png"; Dest = 'Group_1376.png' }
)

# ============================================================
# Build English mailers
# ============================================================
$engBaseName = 'ENG_ZAS26110082  2026_SEEA_Retainer MX A Series Sustain _ Mailer 2 _ W22'

foreach ($region in $engRegions) {
    $folderName = "${engBaseName}_$($region.Code)"
    $folderPath = "$published\$folderName"
    $htmlName   = "$folderName.html"
    $zipName    = "$folderName.zip"

    Write-Host "Building $htmlName ..."

    # Create folder
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null

    # Generate and write HTML
    $footerHtml = Get-Footer $region.FooterCode
    $html = Build-EnHtml $region.Title $linkEn $footerHtml
    [System.IO.File]::WriteAllText("$folderPath\$htmlName", $html, [System.Text.Encoding]::UTF8)

    # Copy images
    foreach ($img in $engImages) {
        Copy-Item -Path $img.Src -Destination "$folderPath\$($img.Dest)" -Force
    }

    # Validate image count
    $imgCount = (Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -ne '.html' -and $_.Extension -ne '.zip' }).Count
    Write-Host "  Files: 1 HTML + $imgCount images"

    # Create zip
    Create-Zip $folderPath "$folderPath\$zipName"
}

# ============================================================
# Build French mailers
# ============================================================
$frBaseName = 'SN_ZAS26114059  2026_SEWA Retainer_MX A Series Sustain _ Mailer 2 _ W22'

foreach ($region in $frRegions) {
    $folderName = "${frBaseName}_$($region.Code)"
    $folderPath = "$published\$folderName"
    $htmlName   = "$folderName.html"
    $zipName    = "$folderName.zip"

    Write-Host "Building $htmlName ..."

    # Create folder
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null

    # Generate and write HTML
    $footerHtml = Get-Footer $region.FooterCode
    $html = Build-FrHtml $region.Title $linkFr $footerHtml
    [System.IO.File]::WriteAllText("$folderPath\$htmlName", $html, [System.Text.Encoding]::UTF8)

    # Copy images
    foreach ($img in $frImages) {
        Copy-Item -Path $img.Src -Destination "$folderPath\$($img.Dest)" -Force
    }

    # Validate image count
    $imgCount = (Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -ne '.html' -and $_.Extension -ne '.zip' }).Count
    Write-Host "  Files: 1 HTML + $imgCount images"

    # Create zip
    Create-Zip $folderPath "$folderPath\$zipName"
}

Write-Host ""
Write-Host "All 6 mailers built successfully."
Write-Host ""
Write-Host "Published folders:"
Get-ChildItem -Path $published -Directory | ForEach-Object {
    $files = Get-ChildItem $_.FullName -File
    Write-Host "  $($_.Name) ($($files.Count) files)"
}
