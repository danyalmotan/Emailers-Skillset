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

    $heroLink = 'https://www.samsung.com/za/smartphones/galaxy-s26/'
    $learnMoreLink = 'https://www.samsung.com/za/smartphones/galaxy-s26/'
    $shopNowLink = 'https://www.vodacom.co.za/shopping/deal-details-page/dv6fd17084'
    $standaloneS26Link = 'https://www.vodacom.co.za/shopping/deal-details-page/dv6fd17084'
    $standaloneS26PlusLink = 'https://www.vodacom.co.za/shopping/deal-details-page/dv6fd17086'
    $standaloneS26UltraLink = 'https://www.vodacom.co.za/shopping/deal-details-page/dv6fd13356'
    $doubleS26Link = 'https://www.vodacom.co.za/shopping/deal-details-page/dv6fd18310'
    $doubleS26PlusLink = 'https://www.vodacom.co.za/shopping/deal-details-page/dv6fd18309'
    $doubleS26UltraLink = 'https://www.vodacom.co.za/shopping/deal-details-page/dv6fd18311'

    return @"
<!DOCTYPE html>
<html>
    <head><meta http-equiv="content-type" content="text/html; charset=utf-8"><meta name="viewport" content="width=600"><meta name="format-detection" content="telephone=no">
        <title>Samsung South Africa</title>
    </head>
    <body style="background-color:#555555; margin:0; padding:0;"><span class="preheader" style="color:transparent; display:none; height:0; max-height:0; max-width:0; opacity:0; overflow:hidden; mso-hide:all; visibility:hidden; width:0;">Compact in size, packed with power.</span>
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

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#0B0C17; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center;"><a href="$heroLink" target="_blank"><img alt="Samsung Galaxy S26 hero device" border="0" height="1153" src="${AssetPrefix}hero_top.png" style="display:block; width:600px; height:1153px;" width="600"></a></td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 34px;"><span style="font-size:36px; line-height:48px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Compact in size,<br>packed with power</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 42px;"><span style="font-size:19px; line-height:28px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Expand what's possible with Galaxy S26. Meet the next-level innovation with a compact design and powerful battery.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0">
                                            <tbody>
                                                <tr>
                                                    <td align="center"><a href="$learnMoreLink" target="_blank"><img alt="Learn more" border="0" height="50" src="${AssetPrefix}button_learn_white.png" style="display:block; width:176px; height:50px;" width="176"></a></td>
                                                    <td width="16"></td>
                                                    <td align="center"><a href="$shopNowLink" target="_blank"><img alt="Shop now" border="0" height="50" src="${AssetPrefix}button_shop_blue.png" style="display:block; width:176px; height:50px;" width="176"></a></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="32" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#24263E; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><img alt="Double Up on Galaxy S26 Series" border="0" height="50" src="${AssetPrefix}double_up_header.png" style="display:block; width:560px; height:50px; margin:auto;" width="560"></td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="560">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="270">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4;" width="270">
                                                            <tbody>
                                                                <tr>
                                                                    <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="text-align:center;"><a href="$doubleS26UltraLink" target="_blank"><img alt="2x Galaxy S26 Ultra 256GB" border="0" height="150" src="${AssetPrefix}double_s26_ultra.png" style="display:block; width:204px; height:150px; margin:auto;" width="204"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="padding:0 20px;">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:230px;" width="230">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#000000; padding:8px 10px;">
                                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                                                            <tbody>
                                                                                                <tr>
                                                                                                    <td align="left"><span style="font-size:11px; line-height:14px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy S26 Ultra</span></strong></span></td>
                                                                                                    <td align="center" width="40"><img alt="256GB" border="0" height="19" src="${AssetPrefix}badge_256_offer.png" style="display:block; width:40px; height:19px; margin:auto;" width="40"></td>
                                                                                                    <td align="right" width="30"><span style="font-size:11px; line-height:14px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">X2</span></strong></span></td>
                                                                                                </tr>
                                                                                            </tbody>
                                                                                        </table>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:10px 8px;"><span style="font-size:14px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">R</span></span><span style="font-size:28px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">2 099</span></strong></span><span style="font-size:14px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"> PM x 36</span></span></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 10px;"><span style="font-size:13px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><strong>3GB Red Core</strong> | 100Min +<br>Flexi 170 [second device]</span></span></td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="text-align:center;"><a href="$doubleS26UltraLink" target="_blank"><img alt="Buy now" border="0" height="50" src="${AssetPrefix}button_buy_black.png" style="display:block; width:134px; height:50px; margin:auto;" width="134"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td width="20"></td>
                                                    <td valign="top" width="270">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4;" width="270">
                                                            <tbody>
                                                                <tr>
                                                                    <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="text-align:center;"><a href="$doubleS26Link" target="_blank"><img alt="2x Galaxy S26 256GB" border="0" height="150" src="${AssetPrefix}double_s26.png" style="display:block; width:177px; height:150px; margin:auto;" width="177"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="padding:0 20px;">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:230px;" width="230">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#000000; padding:8px 10px;">
                                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                                                            <tbody>
                                                                                                <tr>
                                                                                                    <td align="left"><span style="font-size:11px; line-height:14px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy S26</span></strong></span></td>
                                                                                                    <td align="center" width="40"><img alt="256GB" border="0" height="19" src="${AssetPrefix}badge_256_offer_alt.png" style="display:block; width:40px; height:19px; margin:auto;" width="40"></td>
                                                                                                    <td align="right" width="30"><span style="font-size:11px; line-height:14px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">X2</span></strong></span></td>
                                                                                                </tr>
                                                                                            </tbody>
                                                                                        </table>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:10px 8px;"><span style="font-size:14px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">R</span></span><span style="font-size:28px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">1 599</span></strong></span><span style="font-size:14px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"> PM x 36</span></span></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 10px;"><span style="font-size:13px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><strong>3GB Red Core</strong> | 100Min +<br>Flexi 170 [second device]</span></span></td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="text-align:center;"><a href="$doubleS26Link" target="_blank"><img alt="Buy now" border="0" height="50" src="${AssetPrefix}button_buy_black.png" style="display:block; width:134px; height:50px; margin:auto;" width="134"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3" height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" width="270">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4;" width="270">
                                                            <tbody>
                                                                <tr>
                                                                    <td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="text-align:center;"><a href="$doubleS26PlusLink" target="_blank"><img alt="2x Galaxy S26+ 256GB" border="0" height="150" src="${AssetPrefix}double_s26_plus.png" style="display:block; width:176px; height:150px; margin:auto;" width="176"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="10" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="padding:0 20px;">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:230px;" width="230">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#000000; padding:8px 10px;">
                                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                                                            <tbody>
                                                                                                <tr>
                                                                                                    <td align="left"><span style="font-size:11px; line-height:14px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy S26+</span></strong></span></td>
                                                                                                    <td align="center" width="40"><img alt="256GB" border="0" height="19" src="${AssetPrefix}badge_256_offer_alt2.png" style="display:block; width:40px; height:19px; margin:auto;" width="40"></td>
                                                                                                    <td align="right" width="30"><span style="font-size:11px; line-height:14px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">X2</span></strong></span></td>
                                                                                                </tr>
                                                                                            </tbody>
                                                                                        </table>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:10px 8px;"><span style="font-size:14px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">R</span></span><span style="font-size:28px; line-height:30px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">1 899</span></strong></span><span style="font-size:14px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"> PM x 36</span></span></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 10px;"><span style="font-size:13px; line-height:18px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><strong>3GB Red Core</strong> | 100Min +<br>Flexi 170 [second device]</span></span></td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                                <tr>
                                                                    <td style="text-align:center;"><a href="$doubleS26PlusLink" target="_blank"><img alt="Buy now" border="0" height="50" src="${AssetPrefix}button_buy_black.png" style="display:block; width:134px; height:50px; margin:auto;" width="134"></a></td>
                                                                </tr>
                                                                <tr>
                                                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td width="20"></td>
                                                    <td></td>
                                                </tr>
                                                <tr>
                                                    <td colspan="3" height="24" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#24263E; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center;"><img alt="Bolt on Deals" border="0" height="50" src="${AssetPrefix}bolt_header.png" style="display:block; width:560px; height:50px; margin:auto;" width="560"></td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$standaloneS26UltraLink" target="_blank"><img alt="Add Galaxy Watch8 LTE for R149 PM x 36" border="0" height="120" src="${AssetPrefix}bolt_watch_banner.png" style="display:block; width:560px; height:120px; margin:auto;" width="560"></a></td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0" width="560">
                                            <tbody>
                                                <tr>
                                                    <td valign="top" width="173">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4;" width="173">
                                                            <tbody>
                                                                <tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:center;"><a href="$standaloneS26UltraLink" target="_blank"><img alt="Galaxy S26 Ultra 256GB" border="0" height="120" src="${AssetPrefix}bolt_s26_ultra.png" style="display:block; width:99px; height:120px; margin:auto;" width="99"></a></td></tr>
                                                                <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr>
                                                                    <td style="padding:0 8px;">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:157px;" width="157">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#000000; padding:8px 4px;">
                                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="left"><span style="font-size:9px; line-height:12px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy S26 Ultra</span></strong></span></td><td align="right" width="40"><img alt="256GB" border="0" height="19" src="${AssetPrefix}badge_256_bolt.png" style="display:block; width:40px; height:19px; margin-left:auto;" width="40"></td></tr></tbody></table>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr><td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 4px;"><span style="font-size:12px; line-height:16px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">R</span></span><span style="font-size:24px; line-height:26px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">1 249</span></strong></span><span style="font-size:12px; line-height:16px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"> PM x 36</span></span></td></tr>
                                                                                <tr><td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 4px;"><span style="font-size:10px; line-height:14px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><strong>6GB Red Core</strong> | 250Min +<br>AnyTime Data 3GB | SMS 200</span></span></td></tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:center;"><a href="$standaloneS26UltraLink" target="_blank"><img alt="Buy now" border="0" height="50" src="${AssetPrefix}button_buy_black.png" style="display:block; width:134px; height:50px; margin:auto;" width="134"></a></td></tr>
                                                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td width="20"></td>
                                                    <td valign="top" width="173">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4;" width="173">
                                                            <tbody>
                                                                <tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:center;"><a href="$standaloneS26Link" target="_blank"><img alt="Galaxy S26 256GB" border="0" height="120" src="${AssetPrefix}bolt_s26.png" style="display:block; width:98px; height:120px; margin:auto;" width="98"></a></td></tr>
                                                                <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr>
                                                                    <td style="padding:0 8px;">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:157px;" width="157">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#000000; padding:8px 4px;">
                                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="left"><span style="font-size:9px; line-height:12px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy S26</span></strong></span></td><td align="right" width="40"><img alt="256GB" border="0" height="19" src="${AssetPrefix}badge_256_bolt_mid.png" style="display:block; width:40px; height:19px; margin-left:auto;" width="40"></td></tr></tbody></table>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr><td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 4px;"><span style="font-size:12px; line-height:16px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">R</span></span><span style="font-size:24px; line-height:26px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">999</span></strong></span><span style="font-size:12px; line-height:16px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"> PM x 36</span></span></td></tr>
                                                                                <tr><td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 4px;"><span style="font-size:10px; line-height:14px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><strong>3GB Red Core</strong> | 100Min +<br>4GB AnyTime Data | 100SMS</span></span></td></tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:center;"><a href="$standaloneS26Link" target="_blank"><img alt="Buy now" border="0" height="50" src="${AssetPrefix}button_buy_black.png" style="display:block; width:134px; height:50px; margin:auto;" width="134"></a></td></tr>
                                                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                    <td width="20"></td>
                                                    <td valign="top" width="173">
                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#F4F4F4;" width="173">
                                                            <tbody>
                                                                <tr><td height="14" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:center;"><a href="$standaloneS26PlusLink" target="_blank"><img alt="Galaxy S26+ 256GB" border="0" height="120" src="${AssetPrefix}bolt_s26_plus.png" style="display:block; width:119px; height:120px; margin:auto;" width="119"></a></td></tr>
                                                                <tr><td height="12" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr>
                                                                    <td style="padding:0 8px;">
                                                                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse; border:1px solid #000000; width:157px;" width="157">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td align="center" style="background-color:#000000; padding:8px 4px;">
                                                                                        <table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td align="left"><span style="font-size:9px; line-height:12px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#FFFFFF;">Galaxy S26+</span></strong></span></td><td align="right" width="40"><img alt="256GB" border="0" height="19" src="${AssetPrefix}badge_256_bolt_right.png" style="display:block; width:40px; height:19px; margin-left:auto;" width="40"></td></tr></tbody></table>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr><td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 4px;"><span style="font-size:12px; line-height:16px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">R</span></span><span style="font-size:24px; line-height:26px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">749</span></strong></span><span style="font-size:12px; line-height:16px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"> PM x 36</span></span></td></tr>
                                                                                <tr><td align="center" style="background-color:#FFFFFF; border-top:1px solid #000000; padding:8px 4px;"><span style="font-size:10px; line-height:14px;"><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;"><strong>3GB Red Core</strong> | 100Min +<br>4GB AnyTime Data | 100SMS</span></span></td></tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr><td height="16" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                                <tr><td style="text-align:center;"><a href="$standaloneS26PlusLink" target="_blank"><img alt="Buy now" border="0" height="50" src="${AssetPrefix}button_buy_black.png" style="display:block; width:134px; height:50px; margin:auto;" width="134"></a></td></tr>
                                                                <tr><td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="5" height="24" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#E7EAF1; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="42" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:36px; line-height:46px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Everyday slimness,<br>long-lasting battery</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 44px;"><span style="font-size:19px; line-height:28px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Enjoy refined comfort in a slim design that fits effortlessly in your hand and a battery that keeps your day uninterrupted.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$learnMoreLink" target="_blank"><img alt="Galaxy S26 compact design and Android Authority review" border="0" height="656" src="${AssetPrefix}review_card.png" style="display:block; width:520px; height:656px; margin:auto;" width="520"></a></td>
                                </tr>
                                <tr>
                                    <td height="34" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#E7EAF1; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="8" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 40px;"><span style="font-size:36px; line-height:42px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Compared with Galaxy S24</span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0"><tbody><tr><td style="padding-right:25px;"><span style="font-size:24px; line-height:42px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Galaxy S26</span></strong></span></td><td style="padding-left:25px;"><span style="font-size:24px; line-height:42px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#A2A6B2;">Galaxy S24</span></strong></span></td></tr></tbody></table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><a href="$learnMoreLink" target="_blank"><img alt="Galaxy S26 compared with Galaxy S24 on slimness, battery and video playback" border="0" height="385" src="${AssetPrefix}compare_chart.png" style="display:block; width:520px; height:385px; margin:auto;" width="520"></a></td>
                                </tr>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <table align="center" border="0" cellpadding="0" cellspacing="0"><tbody><tr><td align="center"><a href="$learnMoreLink" target="_blank"><img alt="Learn more" border="0" height="50" src="${AssetPrefix}button_learn_white_bottom.png" style="display:block; width:176px; height:50px;" width="176"></a></td><td width="16"></td><td align="center"><a href="$shopNowLink" target="_blank"><img alt="Shop now" border="0" height="50" src="${AssetPrefix}button_shop_black.png" style="display:block; width:176px; height:50px;" width="176"></a></td></tr></tbody></table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="18" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 44px 34px 44px;"><span style="font-size:11px; line-height:16px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#666666;">*Actual battery life varies by network environment, features and apps used, frequency of calls and messages, the number of times charged, and many other factors. Estimated against the average usage profile compiled by UX Connect Research. Independently assessed by UX Connect Research between 2026.1.8-2026.1.30 in US and UK with pre-release versions of SM-S942, SM-S924 and SM-S948 under default settings using LTE and 5G Sub6 networks. Not tested under 5G mmWave network.</span></span></td>
                                </tr>
                            </tbody>
                        </table>

                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#FFFFFF; width:600px;" width="600">
                            <tbody>
                                <tr>
                                    <td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><img alt="Deals valid 09 June - 06 July 2026" border="0" height="40" src="${AssetPrefix}deals_valid.png" style="display:block; width:334px; height:40px; margin:auto;" width="334"></td>
                                </tr>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><img alt="Connected by Vodacom" border="0" height="46" src="${AssetPrefix}vodacom_logo.png" style="display:block; width:164px; height:46px; margin:auto;" width="164"></td>
                                </tr>
                                <tr>
                                    <td height="26" style="font-size:1px; line-height:1px;">&nbsp;</td>
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
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center;"><span style="font-size:16px; line-height:20px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><a href="https://www.samsung.com/za/info/legal/" style="color:#000000; text-decoration:none;" target="_blank">Legal</a> <span style="color:#000000;">|</span> <a href="https://www.samsung.com/za/info/privacy/" style="color:#000000; text-decoration:none;" target="_blank">Privacy Policy</a></span></strong></span></td>
                                </tr>
                                <tr>
                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 36px;"><span style="font-size:13px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">Vodacom Terms and Conditions apply. Offer valid while stocks last. E&amp;OE. We cannot be held liable for any misrepresentation caused by unintentional copy errors, typing errors, and/or omissions that may occur in any of our material.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="22" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 36px;"><span style="font-size:13px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">This email has been sent to members who have requested to join the mailing list.<br>If you wish to unsubscribe from the mailing list, please click <a href="YYYYY" style="color:#696969;" target="_blank">Unsubscribe</a>.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="24" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                </tr>
                                <tr>
                                    <td style="text-align:center; padding:0 36px;"><span style="font-size:13px; line-height:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif; color:#000000;">&copy; Copyright 2017-2026 Samsung Electronics. All Rights Reserved.<br>* Do not reply. The email address is for outgoing emails only.</span></span></td>
                                </tr>
                                <tr>
                                    <td height="28" style="font-size:1px; line-height:1px;">&nbsp;</td>
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

$jobRoot = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26088177  2026_SSA Retainer_Digital_CRM MX_Channel_Vodacom_S Series Sustain_Mailer_W24'
$sourceAssets = Join-Path $jobRoot 'ZAS26088177_images export'
$publishedRoot = Join-Path $jobRoot 'Published'
$baseName = 'ZAS26088177_Vodacom_S_Sustain_Mailer_W24'
$outputDir = Join-Path $publishedRoot $baseName
$rootHtmlPath = Join-Path $publishedRoot ($baseName + '.html')
$folderHtmlPath = Join-Path $outputDir ($baseName + '.html')
$zipPath = Join-Path $outputDir ($baseName + '.zip')

$assetMap = @{
    'Group 2770.png' = 'hero_top.png'
    'Group 2774.png' = 'double_up_header.png'
    'Group 2766.png' = 'double_s26_ultra.png'
    'Group 2771.png' = 'double_s26.png'
    'Group 2773.png' = 'double_s26_plus.png'
    'Group -1.png'   = 'badge_256_offer.png'
    'Group 2726.png' = 'badge_256_offer_alt.png'
    'Group 2726.png|Offer deals 2' = 'badge_256_bolt.png'
    'Group 2726.png|Offer deals 2|mid' = 'badge_256_bolt_mid.png'
    'Group 2726.png|Offer deals 2|right' = 'badge_256_bolt_right.png'
    'Bolt on Deals.png' = 'bolt_header.png'
    'Group 2761.png' = 'bolt_watch_banner.png'
    'Image 629.png' = 'bolt_s26_ultra.png'
    'Image 630.png' = 'bolt_s26.png'
    'Image 638.png' = 'bolt_s26_plus.png'
    'Group 1758.png' = 'vodacom_logo.png'
    'Group 2776.png' = 'review_card.png'
    'Image 217.png' = 'compare_chart.png'
    'Group 2777.png' = 'deals_valid.png'
    'Group 2710.png' = 'button_learn_white.png'
    'Group 2718.png' = 'button_shop_blue.png'
    'Group 2719.png' = 'button_learn_white_bottom.png'
    'Group 2720.png' = 'button_shop_black.png'
    'Group 2755.png' = 'button_buy_black.png'
}

New-Item -Path $publishedRoot -ItemType Directory -Force | Out-Null
New-Item -Path $outputDir -ItemType Directory -Force | Out-Null

$copiedRightBoltBadge = $false
$copiedMidBoltBadge = $false

Get-ChildItem -Path $sourceAssets -Recurse -File | Where-Object {
    $_.Name -notmatch '@2x' -and $_.Extension -in '.png', '.jpg', '.jpeg', '.gif'
} | ForEach-Object {
    $dirName = Split-Path $_.DirectoryName -Leaf
    $key = if ($_.Name -eq 'Group 2726.png' -and $dirName -eq 'Offer deals 2') {
        if (-not $copiedMidBoltBadge) {
            $copiedMidBoltBadge = $true
            'Group 2726.png|Offer deals 2|mid'
        }
        elseif (-not $copiedRightBoltBadge) {
            $copiedRightBoltBadge = $true
            'Group 2726.png|Offer deals 2|right'
        }
        else {
            'Group 2726.png|Offer deals 2'
        }
    }
    elseif ($_.Name -eq 'Group 2726.png' -and $dirName -eq 'Offer deals') {
        $_.Name
    }
    else {
        $_.Name
    }

    if (-not $assetMap.ContainsKey($key)) {
        return
    }

    Copy-Item -Path $_.FullName -Destination (Join-Path $outputDir $assetMap[$key]) -Force
}

$assetAliases = @(
    @{ Source = 'badge_256_offer_alt.png'; Target = 'badge_256_offer_alt2.png' },
    @{ Source = 'badge_256_bolt_mid.png'; Target = 'badge_256_bolt.png' },
    @{ Source = 'badge_256_bolt_mid.png'; Target = 'badge_256_bolt_right.png' }
)

foreach ($alias in $assetAliases) {
    $sourcePath = Join-Path $outputDir $alias.Source
    $targetPath = Join-Path $outputDir $alias.Target

    if ((Test-Path $sourcePath) -and -not (Test-Path $targetPath)) {
        Copy-Item -Path $sourcePath -Destination $targetPath -Force
    }
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