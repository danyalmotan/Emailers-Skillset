$ErrorActionPreference = 'Stop'

Set-StrictMode -Version Latest

$root = 'c:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26088113 - 2026_SSA Retainer_Digital_CRM MX _ S26 Series Onboarding _ Mailers _ W19'
$publishedDir = Join-Path $root 'published'
$footersDir = 'c:\Users\user\OneDrive\digidanWork\Mailers\footers'

$sa1Path = Join-Path $publishedDir 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 1.html'
$sa2Path = Join-Path $publishedDir 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 2.html'
$sa2FolderPath = Join-Path $publishedDir 'ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 2\ZAS26088113  S26 Series Onboarding_Mailers_W19_SA 2.html'

$sa1 = Get-Content -LiteralPath $sa1Path -Raw -Encoding UTF8
$sa2 = Get-Content -LiteralPath $sa2Path -Raw -Encoding UTF8
$sa2Folder = Get-Content -LiteralPath $sa2FolderPath -Raw -Encoding UTF8

$m1Tip1Img = 'https://cdn19.mailercdn.net/users/assets/379/images/138202/WIKjuagC65fqZCPg/Tip1_2x.png?v=1778489742'
$m1Tip2Img = 'https://cdn19.mailercdn.net/users/assets/379/images/138202/WIKjuagC65fqZCPg/Group_2648_2x.png?v=1778489741'
$m1Tip3Img = 'https://cdn19.mailercdn.net/users/assets/379/images/138202/WIKjuagC65fqZCPg/Group_2650_2x.png?v=1778489741'
$m2FrenchButton = 'https://cdn19.mailercdn.net/users/assets/379/images/group_1773-402x_1.png'
$m2EnglishExploreButton = 'https://cdn19.mailercdn.net/users/assets/379/images/group_2654.png'
$m2FrenchWhiteCardButton = 'https://cdn19.mailercdn.net/users/assets/379/images/group_2654_1.png'
$m2WhiteCardIcon = 'https://cdn19.mailercdn.net/users/assets/379/images/138207/yuXqsWHnnq3jCTmL/Image_662_2x.png'
$reviewIcon = 'https://cdn19.mailercdn.net/users/assets/379/images/icon2_1.png'
$reviewButton = 'https://cdn19.mailercdn.net/users/assets/379/images/group_2655.png'
$reviewButtonFr = 'https://cdn19.mailercdn.net/users/assets/379/images/group_2655_1.png'
$reviewLinkEnglish = 'https://www.samsung.com/africa_en/smartphones/galaxy-s26-ultra/reviews/'
$reviewLinkFrench = 'https://www.samsung.com/africa_fr/smartphones/galaxy-s26-ultra/reviews/'
$tryGalaxySection = @"
                        <table align="center" border="0" cellpadding="0" cellspacing="0" style="background-color:#ffffff;" width="600">
                            <tbody>
                                <tr>
                                    <td style="text-align:center; font-size:0; line-height:0;"><a href="https://trygalaxy.com/" target="_blank"><img alt="Try Galaxy AI on your phone" border="0" height="276" src="https://cdn19.mailercdn.net/users/assets/379/images/dfsghhgjm-2Cjytrrrfdg-00005.jpg" style="width:600px; height:276px; display:block;" width="600"></a></td>
                                </tr>
                            </tbody>
                        </table>
"@

$singleCareTable = @"
                                        <table align="center" border="0" cellpadding="12" cellspacing="0" style="width: 520px;">
                                            <tbody>
                                                <tr>
                                                    <td align="center"><img alt="Certified care" height="76" src="https://cdn19.mailercdn.net/users/assets/379/images/138202/WIKjuagC65fqZCPg/Image_646_2x.png?v=1778489741" style="width:50px; height:76px; display:block; margin:auto;" width="50"></td>
                                                </tr>
                                                <tr>
                                                    <td align="center"><span style="font-size:15px;"><strong><span style="font-family:Samsung Sharp Sans, avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;">Certified care</span></strong></span></td>
                                                </tr>
                                            </tbody>
                                        </table>
"@

function Get-Prefix {
    param(
        [string] $Text,
        [string] $Marker
    )

    $index = $Text.IndexOf($Marker)
    if ($index -lt 0) {
        throw "Marker not found: $Marker"
    }

    return $Text.Substring(0, $index)
}

function Get-Section {
    param(
        [string] $Text,
        [string] $StartMarker,
        [string] $EndMarker
    )

    $pattern = '(?s)' + [regex]::Escape($StartMarker) + '.*?(?=' + [regex]::Escape($EndMarker) + ')'
    $match = [regex]::Match($Text, $pattern)
    if (-not $match.Success) {
        throw "Section not found: $StartMarker -> $EndMarker"
    }

    return $match.Value
}

function Get-FooterContent {
    param(
        [string] $FooterFile
    )

    return Get-Content -LiteralPath (Join-Path $footersDir $FooterFile) -Raw -Encoding UTF8
}

function Set-Title {
    param(
        [string] $Html,
        [string] $Title
    )

    return [regex]::Replace($Html, '<title>.*?</title>', "<title>$Title</title>", 1)
}

function Set-LogoLink {
    param(
        [string] $Html,
        [string] $Url
    )

    return [regex]::Replace($Html, '<a href="https://www\.samsung\.com/za/" target="_blank"><img alt="Samsung"', "<a href=""$Url"" target=""_blank""><img alt=""Samsung""", 1)
}

function Set-Footer {
    param(
        [string] $Html,
        [string] $FooterFile
    )

    $footer = Get-FooterContent -FooterFile $FooterFile
    return [regex]::Replace($Html, '(?s)<!-- FOOTER -->.*$', "<!-- FOOTER -->`r`n$footer")
}

function Replace-Hrefs {
    param(
        [string] $Html,
        [hashtable] $Map
    )

    foreach ($key in $Map.Keys) {
        $escaped = [regex]::Escape($key)
        $Html = [regex]::Replace($Html, $escaped, [string] $Map[$key])
    }

    return $Html
}

function Set-MainHeadersTo40 {
    param(
        [string] $Html
    )

    return $Html -replace 'font-size:48px;', 'font-size:40px;'
}

function Increase-SectionSpacing {
    param(
        [string] $Html
    )

    $Html = $Html -replace 'padding-bottom:30px;', 'padding-bottom:35px;'
    return [regex]::Replace($Html, 'height="(\d+)" style="font-size:1px; line-height:1px;"', [System.Text.RegularExpressions.MatchEvaluator]{
        param($match)

        $height = [int] $match.Groups[1].Value + 5
        return ('height="{0}" style="font-size:1px; line-height:1px;"' -f $height)
    })
}

function Set-BadgeImage {
    param(
        [string] $Block,
        [string] $Alt,
        [string] $Src
    )

    $replacement = "<tr>`r`n                                    <td style=""text-align:center;""><img alt=""$Alt"" height=""42"" src=""$Src"" style=""width:73px; height:42px; display:block; margin:auto;"" width=""73""></td>`r`n                                </tr>"
    return [regex]::Replace($Block, '(?s)<tr>\s*<td style="text-align:center;"><img alt="Tip [^"]+".*?</tr>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement }, 1)
}

function Set-FrenchBadge {
    param(
        [string] $Block,
        [string] $Label
    )

    $replacement = @"
<tr>
                                    <td style="text-align:center;"><u><span style="font-size:20px;"><span style="font-family:avant garde,avantgarde,century gothic,centurygothic,applegothic,sans-serif;"><span style="color:#276DDC;"><strong>$Label</strong></span></span></span></u></td>
                                </tr>
"@

    return [regex]::Replace($Block, '(?s)<tr>\s*<td style="text-align:center;"><img alt="Tip [^"]+".*?</tr>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $replacement.TrimEnd() }, 1)
}

function Set-FrenchButtonImage {
    param(
        [string] $Html
    )

    $Html = $Html -replace 'https://cdn19\.mailercdn\.net/users/assets/379/images/138205/DjA0rPEFvqz0VYLs/Group_2651\.png\?v=1778491815', $m2FrenchButton
    $Html = $Html -replace 'https://cdn19\.mailercdn\.net/users/assets/379/images/138202/WIKjuagC65fqZCPg/Group_2646\.png\?v=1778489741', $m2FrenchButton
    $Html = $Html -replace 'https://cdn19\.mailercdn\.net/users/assets/379/images/138202/WIKjuagC65fqZCPg/Group_2640\.png\?v=1778489741', $m2FrenchButton
    $Html = $Html -replace 'https://cdn19\.mailercdn\.net/users/assets/379/images/group_2654\.png', $m2FrenchButton
    return $Html
}

function Set-WhiteCardLightbulb {
    param(
        [string] $Block
    )

    $replacement = @"
                                                <tr>
                                                    <td style="text-align:center; padding:0 30px;"><img alt="Lightbulb icon" border="0" height="72" src="$m2WhiteCardIcon" style="display:block; margin:auto; width:71px; height:72px;" width="71"></td>
                                                </tr>
                                                <tr>
                                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
"@

    return $Block -replace '<!-- ICON NEEDED: sparkle/star icon -->', $replacement.TrimEnd()
}

function Set-ReviewIcon {
    param(
        [string] $Block
    )

    $replacement = @"
                                                <tr>
                                                    <td style="text-align:center; padding:0 30px;"><img alt="Review icon" border="0" height="44" src="$reviewIcon" style="display:block; margin:auto; width:44px; height:44px;" width="44"></td>
                                                </tr>
                                                <tr>
                                                    <td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td>
                                                </tr>
"@

    return $Block -replace '<!-- ICON NEEDED: phone/camera icon -->', $replacement.TrimEnd()
}

function Set-M1FrenchPrefix {
    param(
        [string] $Html,
        [string] $HomeUrl,
        [string] $StartUrl
    )

    $Html = Set-Title -Html $Html -Title '__TITLE__'
    $Html = Set-LogoLink -Html $Html -Url $HomeUrl
    $Html = $Html -replace ' Thank you for your ongoing trust\. Your support and commitment drive us forward\. ', ' Merci pour votre confiance continue. Votre soutien et votre engagement nous font avancer. '
    $Html = $Html -replace 'Grateful to have<br>\s*you with Galaxy', 'Heureux de vous<br>                                        compter parmi les<br>                                        utilisateurs Galaxy'
    $Html = $Html -replace 'alt="Thank you for your ongoing trust\. Your support and commitment drive us forward\."', 'alt="Merci pour votre confiance continue. Votre soutien et votre engagement nous font avancer."'
    $Html = $Html -replace 'What are you<br>\s*curious about\?', 'Qu&rsquo;est-ce qui<br>                                                        vous int&eacute;resse ?'
    $Html = $Html -replace 'How do I move my data\?', 'Comment transf&eacute;rer mes donn&eacute;es ?'
    $Html = $Html -replace 'What are the new features\?', 'Quelles sont les nouvelles fonctionnalit&eacute;s ?'
    $Html = $Html -replace 'What are the tips for better photos\?', 'Quels sont les conseils pour am&eacute;liorer vos photos ?'
    $Html = $Html -replace 'What apps are useful\?', 'Quelles applications sont utiles ?'
    $Html = $Html -replace 'href="https://trygalaxy\.com/" target="_blank"><img alt="Start here"', "href=""$StartUrl"" target=""_blank""><img alt=""Commencez ici"""
    $Html = Set-FrenchButtonImage -Html $Html
    return $Html
}

function Set-M1EnglishPrefix {
    param(
        [string] $Html,
        [string] $HomeUrl,
        [string] $StartUrl,
        [string] $Title
    )

    $Html = Set-Title -Html $Html -Title $Title
    $Html = Set-LogoLink -Html $Html -Url $HomeUrl
    $Html = $Html -replace 'href="https://trygalaxy\.com/" target="_blank"><img alt="Start here"', "href=""$StartUrl"" target=""_blank""><img alt=""Start here"""
    return $Html
}

function Set-M1CareBlock {
    param(
        [string] $Block,
        [string] $CareUrl,
        [bool] $UseSingleCare,
        [string] $BadgeAlt,
        [string] $BadgeSrc
    )

    $Block = Set-BadgeImage -Block $Block -Alt $BadgeAlt -Src $BadgeSrc
    $Block = Replace-Hrefs -Html $Block -Map @{
        'https://www.samsung.com/za/offer/samsung-care-plus/' = $CareUrl
    }

    if ($UseSingleCare) {
        $Block = [regex]::Replace($Block, '(?s)<table align="center" border="0" cellpadding="12" cellspacing="0" style="width: 520px;">.*?</table>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $singleCareTable.TrimEnd() }, 1)
        $Block = $Block -replace 'Always with you through your mobile<br>\s*device journeyand new beginnings,<br>\s*supported by unlimited repair<br>\s*&nbsp;for seamless moments\.', 'Always with you through your mobile<br>                                        device journey and new beginnings,<br>                                        supported by One free screen repair<br>                                        for seamless moments.'
    }

    return $Block
}

function Set-M1MembersBlockEnglish {
    param(
        [string] $Block,
        [string] $MembersUrl,
        [string] $BadgeAlt,
        [string] $BadgeSrc
    )

    $Block = Set-BadgeImage -Block $Block -Alt $BadgeAlt -Src $BadgeSrc
    return Replace-Hrefs -Html $Block -Map @{
        'https://www.samsung.com/za/support/mobile-devices/how-to-use-the-samsung-members-app/' = $MembersUrl
    }
}

function Set-M1MembersBlockFrench {
    param(
        [string] $Block,
        [string] $MembersUrl
    )

    $Block = Set-FrenchBadge -Block $Block -Label 'Astuce 1'
    $Block = Replace-Hrefs -Html $Block -Map @{
        'https://www.samsung.com/za/support/mobile-devices/how-to-use-the-samsung-members-app/' = $MembersUrl
    }
    $Block = $Block -replace 'Connect with<br>\s*the community', 'Connectez-vous &agrave;<br>                                        la communaut&eacute;'
    $Block = [regex]::Replace($Block, '(?s)Join Samsung Members to connect with<br>\s*community members.*?member''s benefits\.', 'Rejoignez Samsung Members pour &eacute;changer<br>                                        avec la communaut&eacute;, d&eacute;couvrez les<br>                                        publications des utilisateurs, les s&eacute;lections de<br>                                        l&rsquo;&eacute;diteur et les avantages membres.')
    $Block = $Block -replace 'alt="Learn more"', 'alt="En savoir plus"'
    $Block = Set-FrenchButtonImage -Html $Block
    return $Block
}

function Set-M1SwitchBlockEnglish {
    param(
        [string] $Block,
        [string] $SwitchUrl,
        [string] $BadgeAlt,
        [string] $BadgeSrc
    )

    $Block = Set-BadgeImage -Block $Block -Alt $BadgeAlt -Src $BadgeSrc
    return Replace-Hrefs -Html $Block -Map @{
        'https://www.samsung.com/za/support/smart-switch/' = $SwitchUrl
    }
}

function Set-M1SwitchBlockFrench {
    param(
        [string] $Block,
        [string] $SwitchUrl
    )

    $Block = Set-FrenchBadge -Block $Block -Label 'Astuce 2'
    $Block = Replace-Hrefs -Html $Block -Map @{
        'https://www.samsung.com/za/support/smart-switch/' = $SwitchUrl
    }
    $Block = $Block -replace 'Move data<br>\s*fast and easy', 'Transf&eacute;rez vos donn&eacute;es<br>                                        facilement et rapidement'
    $Block = $Block -replace 'Smart Switch easily transfers various data<br>\s*to your new Galaxy from different devices\.', 'Smart Switch permet de transf&eacute;rer<br>                                        facilement diff&eacute;rentes donn&eacute;es vers votre<br>                                        nouveau Galaxy depuis divers appareils.'
    $Block = $Block -replace 'alt="Learn more"', 'alt="En savoir plus"'
    $Block = Set-FrenchButtonImage -Html $Block
    return $Block
}

function Set-M2PrefixEnglish {
    param(
        [string] $Html,
        [string] $Title,
        [string] $HomeUrl,
        [string] $LandingUrl
    )

    $Html = Set-Title -Html $Html -Title $Title
    $Html = Set-LogoLink -Html $Html -Url $HomeUrl
    $Html = Replace-Hrefs -Html $Html -Map @{
        'https://www.samsung.com/za/galaxy-ai/' = $LandingUrl
    }
    return $Html
}

function Set-M2PrefixFrench {
    param(
        [string] $Html,
        [string] $HomeUrl,
        [string] $LandingUrl
    )

    $Html = Set-Title -Html $Html -Title '__TITLE__'
    $Html = Set-LogoLink -Html $Html -Url $HomeUrl
    $Html = Replace-Hrefs -Html $Html -Map @{
        'https://www.samsung.com/za/galaxy-ai/' = $LandingUrl
    }
    $Html = $Html -replace ' Easy and effortless AI in every moment ', ' Une IA simple et fluide &agrave; chaque instant '
    $Html = $Html -replace 'Easy and effortless AI<br>\s*in every moment', 'Une IA simple et<br>                                        fluide &agrave; chaque instant'
    $Html = $Html -replace 'A simple way to make life more seamless\.', 'Une mani&egrave;re simple de rendre votre vie plus fluide.'
    $Html = $Html -replace 'alt="Learn more"', 'alt="En savoir plus"'
    $Html = Set-FrenchButtonImage -Html $Html
    return $Html
}

function Set-M2BlockLinks {
    param(
        [string] $Block,
        [string] $LandingUrl
    )

    return [regex]::Replace($Block, 'href="https://www\.samsung\.com/za[^"]*"', "href=""$LandingUrl""")
}

function Set-M2TipFrench {
    param(
        [string] $Block,
        [string] $Label,
        [hashtable] $Replacements,
        [string] $LandingUrl
    )

    $Block = Set-FrenchBadge -Block $Block -Label $Label
    $Block = Set-M2BlockLinks -Block $Block -LandingUrl $LandingUrl
    foreach ($key in $Replacements.Keys) {
        $Block = [regex]::Replace($Block, $key, $Replacements[$key])
    }
    $Block = $Block -replace 'alt="Learn more"', 'alt="En savoir plus"'
    $Block = Set-FrenchButtonImage -Html $Block
    return $Block
}

function Get-M2WhiteCardEnglish {
    param(
        [string] $LandingUrl
    )

    $block = Get-Section -Text $sa2Folder -StartMarker '<!-- Your experience starts here' -EndMarker '<!-- What''s your Galaxy moment'
    $block = $block -replace 'href="https://www.samsung.com/za/mobile/"', "href=""$LandingUrl"""
    $block = $block -replace 'src="Group_2654.png"', "src=""$m2EnglishExploreButton"""
    $block = Set-WhiteCardLightbulb -Block $block
    return $block
}

function Get-M2WhiteCardFrench {
    param(
        [string] $LandingUrl
    )

    $block = Get-M2WhiteCardEnglish -LandingUrl $LandingUrl
    $block = $block -replace 'Your experience<br>starts here', 'Votre exp&eacute;rience<br>commence ici'
    $block = $block -replace 'Just got your new Galaxy\? From setup to smart features,<br>here''s everything you need to get started<br>- all in one place\.', 'Vous venez de recevoir votre nouveau Galaxy ? De la configuration aux fonctionnalit&eacute;s intelligentes,<br>retrouvez ici tout ce dont vous avez besoin pour bien<br>d&eacute;marrer - en un seul endroit.'
    $block = $block -replace 'alt="Explore now"', 'alt="En savoir plus"'
    $block = $block -replace [regex]::Escape($m2EnglishExploreButton), $m2FrenchWhiteCardButton
    $block = $block -replace 'style="display:block; margin:auto; width:172px; height:50px;" width="172"', 'style="display:block; margin:auto; width:250px; height:50px;" width="250"'
    return $block
}

function Get-ReviewSectionEnglish {
    param(
        [string] $ReviewUrl
    )

    $block = Get-Section -Text $sa2Folder -StartMarker '<!-- What''s your Galaxy moment?' -EndMarker '<!-- Just for you'
    $block = $block -replace 'href="https://www.samsung.com/za/smartphones/galaxy-s26-ultra/reviews/"', "href=""$ReviewUrl"""
    $block = $block -replace 'src="Group_2655.png"', "src=""$reviewButton"""
    $block = Set-ReviewIcon -Block $block
    return $block
}

function Get-ReviewSectionFrench {
    param(
        [string] $ReviewUrl
    )

    $block = Get-ReviewSectionEnglish -ReviewUrl $ReviewUrl
    $block = $block -replace 'What''s your<br>Galaxy moment\?<br>Share your experience now\.', 'Quel est votre<br>moment Galaxy ?<br>Partagez votre exp&eacute;rience maintenant.'
    $block = $block -replace 'alt="Leave a review"', 'alt="Laissez un avis"'
    $block = $block -replace [regex]::Escape($reviewButton), $reviewButtonFr
    $block = $block -replace 'style="display:block; margin:auto; width:204px; height:50px;" width="204"', 'style="display:block; margin:auto; width:192px; height:50px;" width="192"'
    return $block
}

$m1Prefix = Get-Prefix -Text $sa1 -Marker '<!-- Just for you'
$m1Care = Get-Section -Text $sa1 -StartMarker '<!-- Tip 1' -EndMarker '<!-- Tip 2'
$m1Members = Get-Section -Text $sa1 -StartMarker '<!-- Tip 3' -EndMarker '<!-- Tip 4'
$m1Switch = Get-Section -Text $sa1 -StartMarker '<!-- Tip 4' -EndMarker '<!-- Your experience starts here'

$m2Prefix = Get-Prefix -Text $sa2 -Marker '<!-- Tip 1'
$m2Tip1 = Get-Section -Text $sa2 -StartMarker '<!-- Tip 1' -EndMarker '<!-- Tip 2'
$m2Tip2 = Get-Section -Text $sa2 -StartMarker '<!-- Tip 2' -EndMarker '<!-- Tip 3'
$m2Tip3 = Get-Section -Text $sa2 -StartMarker '<!-- Tip 3' -EndMarker '<!-- Tip 4'
$m2Tip4 = Get-Section -Text $sa2 -StartMarker '<!-- Tip 4' -EndMarker '<!-- Your experience starts here'

$mailer1Variants = @(
    @{ Code = 'GH'; Title = 'Samsung Ghana'; Footer = 'footer_gh.txt'; Home = 'https://www.samsung.com/africa_en/'; Start = 'https://www.samsung.com/africa_en/'; Care = 'https://www.samsung.com/africa_en/offer/samsung-care-plus/'; Members = 'https://www.samsung.com/africa_en/support/mobile-devices/how-to-use-the-samsung-members-app/'; Switch = 'https://www.samsung.com/africa_en/support/smart-switch/'; IncludeCare = $true; SingleCare = $false; IncludeMembers = $true; IncludeTry = $false; Language = 'en' }
    @{ Code = 'NG'; Title = 'Samsung Nigeria'; Footer = 'footer_ng.txt'; Home = 'https://www.samsung.com/africa_en/'; Start = 'https://www.samsung.com/africa_en/'; Care = 'https://www.samsung.com/africa_en/offer/samsung-care-plus-nigeria-terms/'; Members = 'https://www.samsung.com/africa_en/support/mobile-devices/how-to-use-the-samsung-members-app/'; Switch = 'https://www.samsung.com/africa_en/support/smart-switch/'; IncludeCare = $true; SingleCare = $false; IncludeMembers = $true; IncludeTry = $false; Language = 'en' }
    @{ Code = 'KE'; Title = 'Samsung Kenya'; Footer = 'footer_ke.txt'; Home = 'https://www.samsung.com/africa_en/'; Start = 'https://www.samsung.com/africa_en/'; Care = 'https://www.samsung.com/africa_en/offer/samsung-care-plus-kenya-terms/'; Members = 'https://www.samsung.com/africa_en/support/mobile-devices/how-to-use-the-samsung-members-app/'; Switch = 'https://www.samsung.com/africa_en/support/smart-switch/'; IncludeCare = $true; SingleCare = $false; IncludeMembers = $true; IncludeTry = $true; Language = 'en' }
    @{ Code = 'TZ'; Title = 'Samsung Tanzania'; Footer = 'footer_tz.txt'; Home = 'https://www.samsung.com/africa_en/'; Start = 'https://www.samsung.com/africa_en/'; Care = 'https://www.samsung.com/africa_en/offer/samsung-care-plus-tanzania-terms/'; Members = 'https://www.samsung.com/africa_en/support/mobile-devices/how-to-use-the-samsung-members-app/'; Switch = 'https://www.samsung.com/africa_en/support/smart-switch/'; IncludeCare = $true; SingleCare = $false; IncludeMembers = $true; IncludeTry = $true; Language = 'en' }
    @{ Code = 'MU'; Title = 'Samsung Mauritius'; Footer = 'footer_mu.txt'; Home = 'https://www.samsung.com/africa_en/'; Start = 'https://www.samsung.com/africa_en/'; Care = 'https://www.samsung.com/africa_en/offer/samsung-care-plus/'; Members = 'https://www.samsung.com/africa_en/support/mobile-devices/how-to-use-the-samsung-members-app/'; Switch = 'https://www.samsung.com/africa_en/support/smart-switch/'; IncludeCare = $true; SingleCare = $true; IncludeMembers = $false; IncludeTry = $false; Language = 'en' }
    @{ Code = 'SN'; Title = 'Samsung Senegal'; Footer = 'footer_sn.txt'; Home = 'https://www.samsung.com/africa_fr/'; Start = 'https://www.samsung.com/africa_fr/smartphones/galaxy-s26/'; Care = ''; Members = 'https://www.samsung.com/africa_fr/apps/samsung-members/'; Switch = 'https://www.samsung.com/africa_fr/apps/smart-switch/'; IncludeCare = $false; SingleCare = $false; IncludeMembers = $true; IncludeTry = $false; Language = 'fr' }
    @{ Code = 'CI'; Title = 'Samsung C&ocirc;te d''Ivoire'; Footer = 'footer_ci.txt'; Home = 'https://www.samsung.com/africa_fr/'; Start = 'https://www.samsung.com/africa_fr/smartphones/galaxy-s26/'; Care = ''; Members = 'https://www.samsung.com/africa_fr/apps/samsung-members/'; Switch = 'https://www.samsung.com/africa_fr/apps/smart-switch/'; IncludeCare = $false; SingleCare = $false; IncludeMembers = $true; IncludeTry = $false; Language = 'fr' }
)

$mailer2Variants = @(
    @{ Code = 'GH'; Title = 'Samsung Ghana'; Footer = 'footer_gh.txt'; Home = 'https://www.samsung.com/africa_en/'; Landing = 'https://www.samsung.com/africa_en/offer/welcome-to-samsung-mobile/'; IncludeTry = $false; Language = 'en' }
    @{ Code = 'NG'; Title = 'Samsung Nigeria'; Footer = 'footer_ng.txt'; Home = 'https://www.samsung.com/africa_en/'; Landing = 'https://www.samsung.com/africa_en/offer/welcome-to-samsung-mobile/'; IncludeTry = $false; Language = 'en' }
    @{ Code = 'KE'; Title = 'Samsung Kenya'; Footer = 'footer_ke.txt'; Home = 'https://www.samsung.com/africa_en/'; Landing = 'https://www.samsung.com/africa_en/offer/welcome-to-samsung-mobile/'; IncludeTry = $true; Language = 'en' }
    @{ Code = 'TZ'; Title = 'Samsung Tanzania'; Footer = 'footer_tz.txt'; Home = 'https://www.samsung.com/africa_en/'; Landing = 'https://www.samsung.com/africa_en/offer/welcome-to-samsung-mobile/'; IncludeTry = $true; Language = 'en' }
    @{ Code = 'MU'; Title = 'Samsung Mauritius'; Footer = 'footer_mu.txt'; Home = 'https://www.samsung.com/africa_en/'; Landing = 'https://www.samsung.com/africa_en/offer/welcome-to-samsung-mobile/'; IncludeTry = $false; Language = 'en' }
    @{ Code = 'SN'; Title = 'Samsung Senegal'; Footer = 'footer_sn.txt'; Home = 'https://www.samsung.com/africa_fr/'; Landing = 'https://www.samsung.com/africa_fr/offer/welcome-to-samsung-mobile/'; IncludeTry = $false; Language = 'fr' }
    @{ Code = 'CI'; Title = 'Samsung C&ocirc;te d''Ivoire'; Footer = 'footer_ci.txt'; Home = 'https://www.samsung.com/africa_fr/'; Landing = 'https://www.samsung.com/africa_fr/offer/welcome-to-samsung-mobile/'; IncludeTry = $false; Language = 'fr' }
)

foreach ($variant in $mailer1Variants) {
    if ($variant.Language -eq 'fr') {
        $prefix = Set-M1FrenchPrefix -Html $m1Prefix -HomeUrl $variant.Home -StartUrl $variant.Start
        $prefix = Set-Title -Html $prefix -Title $variant.Title
        $prefix = Increase-SectionSpacing -Html $prefix
        $membersBlock = Set-M1MembersBlockFrench -Block $m1Members -MembersUrl $variant.Members
        $membersBlock = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $membersBlock)
        $switchBlock = Set-M1SwitchBlockFrench -Block $m1Switch -SwitchUrl $variant.Switch
        $switchBlock = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $switchBlock)
        $reviewBlock = Increase-SectionSpacing -Html (Get-ReviewSectionFrench -ReviewUrl $reviewLinkFrench)
        $sections = @($prefix, $membersBlock, $switchBlock, $reviewBlock)
    }
    else {
        $prefix = Set-M1EnglishPrefix -Html $m1Prefix -HomeUrl $variant.Home -StartUrl $variant.Start -Title $variant.Title
        $prefix = Increase-SectionSpacing -Html $prefix
        $careBlock = Set-M1CareBlock -Block $m1Care -CareUrl $variant.Care -UseSingleCare $variant.SingleCare -BadgeAlt 'Tip 1' -BadgeSrc $m1Tip1Img
        $careBlock = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $careBlock)
        $switchBadgeAlt = if ($variant.IncludeMembers) { 'Tip 3' } else { 'Tip 2' }
        $switchBadgeSrc = if ($variant.IncludeMembers) { $m1Tip3Img } else { $m1Tip2Img }
        $switchBlock = Set-M1SwitchBlockEnglish -Block $m1Switch -SwitchUrl $variant.Switch -BadgeAlt $switchBadgeAlt -BadgeSrc $switchBadgeSrc
        $switchBlock = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $switchBlock)
        $sections = @($prefix)
        if ($variant.IncludeCare) {
            $sections += $careBlock
        }
        if ($variant.IncludeMembers) {
            $membersBlock = Set-M1MembersBlockEnglish -Block $m1Members -MembersUrl $variant.Members -BadgeAlt 'Tip 2' -BadgeSrc $m1Tip2Img
            $membersBlock = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $membersBlock)
            $sections += $membersBlock
        }
        $sections += $switchBlock
        $sections += (Increase-SectionSpacing -Html (Get-ReviewSectionEnglish -ReviewUrl $reviewLinkEnglish))
    }

    if ($variant.IncludeTry) {
        $sections += $tryGalaxySection
    }

    $html = ($sections -join "`r`n") + "`r`n<!-- FOOTER -->`r`n"
    $html = Set-Footer -Html $html -FooterFile $variant.Footer
    $outputPath = Join-Path $publishedDir ("ZAS26088113  S26 Series Onboarding_Mailers_W19_{0} 1.html" -f $variant.Code)
    [System.IO.File]::WriteAllText($outputPath, $html, [System.Text.UTF8Encoding]::new($false))
}

foreach ($variant in $mailer2Variants) {
    if ($variant.Language -eq 'fr') {
        $prefix = Set-M2PrefixFrench -Html $m2Prefix -HomeUrl $variant.Home -LandingUrl $variant.Landing
        $prefix = Set-Title -Html $prefix -Title $variant.Title
        $prefix = Increase-SectionSpacing -Html $prefix
        $tip1 = Set-M2TipFrench -Block $m2Tip1 -Label 'Astuce 1' -LandingUrl $variant.Landing -Replacements @{
            'Studio-level edits\.<br>\s*Built-in\.' = 'Des retouches de<br>                                        niveau studio, int&eacute;gr&eacute;es'
            '(?s)<strong>Photo Assist</strong> helps you get<br>\s*quick and easy photo editing<br>\s*with just a few words and AI\.' = 'L&rsquo;Assistant Photo vous permet de retoucher<br>                                        vos photos facilement et rapidement, gr&acirc;ce &agrave;<br>                                        quelques mots et &agrave; l&rsquo;IA.'
        }
        $tip1 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip1)
        $tip2 = Set-M2TipFrench -Block $m2Tip2 -Label 'Astuce 2' -LandingUrl $variant.Landing -Replacements @{
            'Go live, get answers' = 'Obtenez des<br>                                        r&eacute;ponses en direct'
            '(?s)Speak freely and naturally with <strong>Gemini Live</strong><br>\s*to get information in real time by sharing<br>\s*moments through the camera\.' = 'Parlez librement et naturellement avec<br>                                        <strong>Gemini Live</strong> pour obtenir des informations en<br>                                        temps r&eacute;el en partageant ce que vous voyez<br>                                        via la cam&eacute;ra.'
        }
        $tip2 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip2)
        $tip3 = Set-M2TipFrench -Block $m2Tip3 -Label 'Astuce 3' -LandingUrl $variant.Landing -Replacements @{
            'Circle it, find it' = 'Entourez, trouvez'
            '(?s)Circle the outfit on your screen<br>\s*or type a question into Google''s<br>\s*Ask anything search bar and get<br>\s*AI-powered information\.' = 'Entourez un &eacute;l&eacute;ment &agrave; l&rsquo;&eacute;cran ou posez une<br>                                        question dans la barre de recherche Google<br>                                        pour obtenir des informations gr&acirc;ce &agrave; l&rsquo;IA.'
        }
        $tip3 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip3)
        $tip4 = Set-M2TipFrench -Block $m2Tip4 -Label 'Astuce 4' -LandingUrl $variant.Landing -Replacements @{
            'Boost productivity<br>\s*with AI assist' = 'Boostez votre<br>                                        productivit&eacute; gr&acirc;ce &agrave; l&rsquo;IA'
            'Translates phone calls<br>\s*in real-time with<br>\s*<strong>Call Assist</strong>\.' = 'Traduisez vos appels<br>                                                        en temps r&eacute;el avec<br>                                                        <strong>l&rsquo;Assistant Appel</strong>.'
            'Polish grammar, rephrase and match<br>\s*the right tone with<br>\s*<strong>Writing Assist</strong>\.' = 'Am&eacute;liorez votre<br>                                                        grammaire, reformulez<br>                                                        vos messages et adaptez<br>                                                        le ton juste avec<br>                                                        <strong>l&rsquo;Assistant d&rsquo;&eacute;criture</strong>.'
            'Digest long articles,<br>\s*summarize and<br>\s*translate web<br>\s*pages with<br>\s*<strong>Browsing Assist</strong>\.' = 'Consultez, r&eacute;sumez et<br>                                                        traduisez facilement de<br>                                                        longs articles et pages<br>                                                        web avec<br>                                                        <strong>l&rsquo;Assistant Navigation</strong>.'
        }
        $tip4 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip4)
        $whiteCard = Get-M2WhiteCardFrench -LandingUrl $variant.Landing
        $whiteCard = Increase-SectionSpacing -Html $whiteCard
        $reviewBlock = Increase-SectionSpacing -Html (Get-ReviewSectionFrench -ReviewUrl $reviewLinkFrench)
        $sections = @($prefix, $tip1, $tip2, $tip3, $tip4, $whiteCard, $reviewBlock)
    }
    else {
        $prefix = Set-M2PrefixEnglish -Html $m2Prefix -Title $variant.Title -HomeUrl $variant.Home -LandingUrl $variant.Landing
        $prefix = Increase-SectionSpacing -Html $prefix
        $tip1 = Set-M2BlockLinks -Block $m2Tip1 -LandingUrl $variant.Landing
        $tip1 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip1)
        $tip2 = Set-M2BlockLinks -Block $m2Tip2 -LandingUrl $variant.Landing
        $tip2 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip2)
        $tip3 = Set-M2BlockLinks -Block $m2Tip3 -LandingUrl $variant.Landing
        $tip3 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip3)
        $tip4 = Set-M2BlockLinks -Block $m2Tip4 -LandingUrl $variant.Landing
        $tip4 = Increase-SectionSpacing -Html (Set-MainHeadersTo40 -Html $tip4)
        $whiteCard = Get-M2WhiteCardEnglish -LandingUrl $variant.Landing
        $whiteCard = Increase-SectionSpacing -Html $whiteCard
        $reviewBlock = Increase-SectionSpacing -Html (Get-ReviewSectionEnglish -ReviewUrl $reviewLinkEnglish)
        $sections = @($prefix, $tip1, $tip2, $tip3, $tip4, $whiteCard, $reviewBlock)
    }

    if ($variant.IncludeTry) {
        $sections += $tryGalaxySection
    }

    $html = ($sections -join "`r`n") + "`r`n<!-- FOOTER -->`r`n"
    $html = Set-Footer -Html $html -FooterFile $variant.Footer
    $outputPath = Join-Path $publishedDir ("ZAS26088113  S26 Series Onboarding_Mailers_W19_{0} 2.html" -f $variant.Code)
    [System.IO.File]::WriteAllText($outputPath, $html, [System.Text.UTF8Encoding]::new($false))
}