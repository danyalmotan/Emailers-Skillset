param()

$publishedRoot = "C:\Users\user\OneDrive\digidanWork\Mailers\2026\2 ZAS26088109  2026_SSA Retainer_Digital_CRM MX _ Galaxy A Series Launch 2 _ Mailer _ W17\Published"
$learnMoreSrc = "https://cdn19.mailercdn.net/users/assets/379/images/138131/4fc4x2Q5agryS9m7/Button_Learn_More.png?v=1777935474"
$tryGalaxySrc = "https://cdn19.mailercdn.net/users/assets/379/images/trygalaxy.jpg"

function Get-ContentImageSequence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $html = Get-Content -LiteralPath $Path -Raw
    $matches = [regex]::Matches($html, 'src="([^"]+)"')
    $sequence = New-Object System.Collections.Generic.List[string]

    foreach ($match in $matches) {
        $src = $match.Groups[1].Value

        if ($src -notmatch '^https?://') {
            continue
        }

        if ($src -match 'cloudflareinsights') {
            continue
        }

        if ($src -match '/group_13[7-9]\.png|/group_14[0-4]\.png') {
            continue
        }

        if ($src -match 'Button_') {
            continue
        }

        $sequence.Add($src)
    }

    return $sequence
}

function Get-MailerKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ($Path -match '_M(3|4)_') {
        return "M$($Matches[1])"
    }

    throw "Could not determine mailer type for: $Path"
}

function Is-ButtonSource {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Src
    )

    return ($Src -match '(?i)(^|[\\/])Buttons([\\/]|$)') -or
        ($Src -match '(?i)Group 2624\.png$') -or
        ($Src -match '(?i)Group 2633\.png$')
}

$sourceByMailer = @{
    M3 = Get-ContentImageSequence -Path (Join-Path $publishedRoot 'ZAS26088109_Galaxy A Series L2_W17_M3_SA.html')
    M4 = Get-ContentImageSequence -Path (Join-Path $publishedRoot 'ZAS26088109_Galaxy A Series L2_W17_M4_SA.html')
}

$targetFiles = Get-ChildItem -Path $publishedRoot -Recurse -Filter '*.html' | Where-Object {
    $_.FullName -notmatch '_SA(?:\\|\.html$)'
}

foreach ($file in $targetFiles) {
    $mailerKey = Get-MailerKey -Path $file.FullName
    $contentSequence = $sourceByMailer[$mailerKey]
    $html = Get-Content -LiteralPath $file.FullName -Raw

    $localMatches = [regex]::Matches($html, 'src="([^"]+)"')
    $contentCount = 0
    foreach ($match in $localMatches) {
        $src = $match.Groups[1].Value

        if ($src -match '^(https?:|data:)') {
            continue
        }

        if ($src -match '(?i)TryGalaxy\.jpg$') {
            continue
        }

        if (Is-ButtonSource -Src $src) {
            continue
        }

        $contentCount++
    }

    if ($contentCount -ne $contentSequence.Count) {
        throw "Content image count mismatch for $($file.FullName). Expected $($contentSequence.Count), found $contentCount."
    }

    $contentIndex = 0
    $replacementMap = @{}
    foreach ($match in $localMatches) {
        $src = $match.Groups[1].Value

        if ($src -match '^(https?:|data:)') {
            continue
        }

        if ($src -match '(?i)TryGalaxy\.jpg$') {
            $replacementMap[$src] = $tryGalaxySrc
            continue
        }

        if (Is-ButtonSource -Src $src) {
            $replacementMap[$src] = $learnMoreSrc
            continue
        }

        $replacement = $contentSequence[$contentIndex]
        $contentIndex++

        if ($replacementMap.ContainsKey($src) -and $replacementMap[$src] -ne $replacement) {
            throw "Inconsistent replacement mapping for $src in $($file.FullName)."
        }

        $replacementMap[$src] = $replacement
    }

    if ($contentIndex -ne $contentSequence.Count) {
        throw "Not all source CDN image URLs were consumed for $($file.FullName). Used $contentIndex of $($contentSequence.Count)."
    }

    $updated = $html
    foreach ($entry in $replacementMap.GetEnumerator()) {
        $old = 'src="' + $entry.Key + '"'
        $new = 'src="' + $entry.Value + '"'
        $updated = $updated.Replace($old, $new)
    }

    Set-Content -LiteralPath $file.FullName -Value $updated -Encoding UTF8
}

Write-Output "Updated $($targetFiles.Count) non-SA HTML files."