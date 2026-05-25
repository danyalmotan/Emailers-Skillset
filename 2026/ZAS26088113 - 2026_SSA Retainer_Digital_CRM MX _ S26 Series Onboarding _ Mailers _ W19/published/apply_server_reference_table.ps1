param(
    [string] $ServerHtmlPath = (Join-Path $PSScriptRoot 'ALL_IMAGES\server.html'),
    [string] $PublishedDir = $PSScriptRoot,
    [string] $DirectoryNamePattern = '*'
)

$ErrorActionPreference = 'Stop'

Set-StrictMode -Version Latest

if (-not (Test-Path -LiteralPath $ServerHtmlPath)) {
    throw "Server reference file not found: $ServerHtmlPath"
}

$serverHtml = Get-Content -LiteralPath $ServerHtmlPath -Raw -Encoding UTF8
$rowMatches = [regex]::Matches($serverHtml, '(?s)<tr[^>]*data-originals="([^"]+)"[^>]*>.*?<img[^>]+src="([^"]+)"')

$map = @{}
foreach ($match in $rowMatches) {
    $originals = $match.Groups[1].Value -split '\s*\|\s*'
    $src = $match.Groups[2].Value

    if ($src -notmatch '^https?://') {
        continue
    }

    foreach ($original in $originals) {
        if ([string]::IsNullOrWhiteSpace($original)) {
            continue
        }

        $map[$original] = $src
    }
}

if ($map.Count -eq 0) {
    Write-Output 'No CDN image URLs were found in server.html yet. Upload ALL_IMAGES to Everlytic first, then run this script again.'
    exit 0
}

$htmlFiles = Get-ChildItem -LiteralPath $PublishedDir -Directory |
    Where-Object { $_.Name -ne 'ALL_IMAGES' -and $_.Name -like $DirectoryNamePattern } |
    ForEach-Object {
        Get-ChildItem -LiteralPath $_.FullName -File -Filter '*.html'
    }

$updated = 0
foreach ($htmlFile in $htmlFiles) {
    $html = Get-Content -LiteralPath $htmlFile.FullName -Raw -Encoding UTF8
    $originalHtml = $html

    foreach ($originalName in $map.Keys) {
        $escapedOriginal = [regex]::Escape($originalName)
        $replacement = 'src="' + $map[$originalName] + '"'
        $html = [regex]::Replace($html, 'src="' + $escapedOriginal + '"', $replacement)
    }

    if ($html -ne $originalHtml) {
        [System.IO.File]::WriteAllText($htmlFile.FullName, $html, [System.Text.Encoding]::UTF8)
        $updated++
    }
}

Write-Output ("Updated {0} HTML file(s) using CDN references from {1}." -f $updated, $ServerHtmlPath)