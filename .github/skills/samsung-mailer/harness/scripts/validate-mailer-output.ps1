[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ExpectationPath
)

$script:Failures = New-Object System.Collections.Generic.List[string]
$script:Warnings = New-Object System.Collections.Generic.List[string]

function Add-Failure {
    param([string]$Message)
    $script:Failures.Add($Message)
}

function Add-Warning {
    param([string]$Message)
    $script:Warnings.Add($Message)
}

function Test-RequiredPath {
    param(
        [string]$Path,
        [string]$Label,
        [switch]$Directory
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        Add-Failure("Missing ${Label}: $Path")
        return $false
    }

    if ($Directory -and -not (Get-Item -LiteralPath $Path).PSIsContainer) {
        Add-Failure("Expected directory for ${Label}: $Path")
        return $false
    }

    if (-not $Directory -and (Get-Item -LiteralPath $Path).PSIsContainer) {
        Add-Failure("Expected file for ${Label}: $Path")
        return $false
    }

    return $true
}

function Get-NormalizedText {
    param([string]$Text)
    return ($Text -replace "`r`n", "`n") -replace "`r", "`n"
}

function Assert-ContainsAll {
    param(
        [string]$Text,
        [object[]]$Needles,
        [string]$Label
    )

    foreach ($needle in ($Needles | Where-Object { $_ })) {
        if ($Text.IndexOf([string]$needle, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
            Add-Failure("$Label missing required text: $needle")
        }
    }
}

function Assert-ContainsNone {
    param(
        [string]$Text,
        [object[]]$Needles,
        [string]$Label
    )

    foreach ($needle in ($Needles | Where-Object { $_ })) {
        if ($Text.IndexOf([string]$needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            Add-Failure("$Label contains forbidden text: $needle")
        }
    }
}

function Get-UniqueImageSources {
    param([string]$Html)

    $matches = [regex]::Matches($Html, '(?i)<img\b[^>]*\bsrc\s*=\s*["'']([^"'']+)["'']')
    $results = New-Object System.Collections.Generic.List[string]

    foreach ($match in $matches) {
        $src = $match.Groups[1].Value.Trim()
        if ($src -and -not $results.Contains($src)) {
            $results.Add($src)
        }
    }

    return $results
}

function Test-LocalFilenameSanitized {
    param([string]$FileName)

    if ($FileName -match '[\\/]') {
        Add-Failure("Local image src must be flat, but contains a path separator: $FileName")
        return
    }

    if ($FileName -match '\s') {
        Add-Failure("Local image src contains whitespace: $FileName")
    }

    if ($FileName -notmatch '^[A-Za-z0-9._-]+$') {
        Add-Failure("Local image src contains unsupported characters: $FileName")
    }
}

function Get-AllowedRemoteAssetBasenames {
    param([object[]]$ExtraBasenames)

    $defaults = @(
        'group_137.png',
        'group_138.png',
        'group_139.png',
        'group_140.png',
        'group_141.png',
        'group_142.png',
        'group_143.png',
        'group_144.png',
        'group_2418-402x.png',
        'group_2438-402x.png',
        'group_2451-402x_1.png',
        'group_2574-402x.png',
        '512gb-402x.png',
        'esrdgthjyukhhg-0001.jpg',
        'line_22.png',
        'line_28.png',
        'rgtfdss-0001.png',
        'rgtfdss-0002.png'
    )

    $all = $defaults + ($ExtraBasenames | Where-Object { $_ })
    return $all | Select-Object -Unique
}

function Test-RemoteImageAllowed {
    param(
        [string]$Source,
        [string[]]$AllowedHosts,
        [string[]]$AllowedBasenames
    )

    try {
        $uri = [System.Uri]$Source
    }
    catch {
        Add-Failure("Invalid remote image src: $Source")
        return
    }

    if ($AllowedHosts -notcontains $uri.Host) {
        Add-Failure("Remote image src uses a non-approved host: $Source")
    }

    $basename = [System.IO.Path]::GetFileName($uri.AbsolutePath)
    if ($AllowedBasenames -notcontains $basename) {
        Add-Failure("Remote image src is not an approved reusable asset: $Source")
    }
}

function Test-2xUsage {
    param(
        [string]$Source,
        [string]$MailerFolderPath,
        [string[]]$Allowed2xImages
    )

    if ($Allowed2xImages -contains $Source) {
        return
    }

    if ($Source -match '^(?<base>.+)_2x(?<ext>\.[^.]+)$') {
        $oneXName = "$($Matches.base)$($Matches.ext)"
        $oneXPath = Join-Path $MailerFolderPath $oneXName

        if (Test-Path -LiteralPath $oneXPath) {
            Add-Failure("2x asset referenced even though a 1x version exists beside it: $Source")
        }
        else {
            Add-Warning("2x asset referenced with no 1x sibling found. Confirm this was intentional: $Source")
        }
    }
}

function Read-Expectation {
    param([string]$Path)

    $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    return $raw | ConvertFrom-Json
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedExpectationPath = (Resolve-Path -LiteralPath $ExpectationPath -ErrorAction Stop).Path
$expectationDirectory = Split-Path -Parent $resolvedExpectationPath
$expectation = Read-Expectation -Path $resolvedExpectationPath

if (-not $expectation.jobFolder) {
    throw "Expectation file is missing jobFolder: $resolvedExpectationPath"
}

$jobFolder = if ([System.IO.Path]::IsPathRooted([string]$expectation.jobFolder)) {
    [string]$expectation.jobFolder
}
else {
    Join-Path $expectationDirectory ([string]$expectation.jobFolder)
}

$publishedPath = Join-Path $jobFolder 'Published'
$rootHtmlName = if ($expectation.rootHtml) { [string]$expectation.rootHtml } else { [string]$expectation.mailerHtml }
$mailerFolderName = if ($expectation.mailerFolder) { [string]$expectation.mailerFolder } else { [System.IO.Path]::GetFileNameWithoutExtension([string]$expectation.mailerHtml) }
$mailerHtmlName = [string]$expectation.mailerHtml
$zipName = if ($expectation.zipName) { [string]$expectation.zipName } else { ([System.IO.Path]::GetFileNameWithoutExtension($mailerHtmlName) + '.zip') }

$rootHtmlPath = Join-Path $publishedPath $rootHtmlName
$mailerFolderPath = Join-Path $publishedPath $mailerFolderName
$mailerHtmlPath = Join-Path $mailerFolderPath $mailerHtmlName
$zipPath = Join-Path $mailerFolderPath $zipName

$null = Test-RequiredPath -Path $jobFolder -Label 'job folder' -Directory
$null = Test-RequiredPath -Path $publishedPath -Label 'Published folder' -Directory
$null = Test-RequiredPath -Path $rootHtmlPath -Label 'Published root HTML copy'
$null = Test-RequiredPath -Path $mailerFolderPath -Label 'mailer folder' -Directory
$null = Test-RequiredPath -Path $mailerHtmlPath -Label 'mailer folder HTML copy'
$null = Test-RequiredPath -Path $zipPath -Label 'mailer ZIP'

if ($script:Failures.Count -eq 0) {
    $rootHtml = Get-NormalizedText (Get-Content -LiteralPath $rootHtmlPath -Raw -Encoding UTF8)
    $folderHtml = Get-NormalizedText (Get-Content -LiteralPath $mailerHtmlPath -Raw -Encoding UTF8)

    if ($rootHtml -ne $folderHtml) {
        Add-Failure('Published root HTML copy does not match the mailer-folder HTML copy.')
    }

    if ($expectation.titleContains -and $folderHtml.IndexOf([string]$expectation.titleContains, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        Add-Failure("HTML title or body does not contain expected text: $($expectation.titleContains)")
    }

    Assert-ContainsAll -Text $folderHtml -Needles $expectation.mustContain -Label 'HTML'
    Assert-ContainsNone -Text $folderHtml -Needles $expectation.mustNotContain -Label 'HTML'

    $imageSources = Get-UniqueImageSources -Html $folderHtml
    $localImages = New-Object System.Collections.Generic.List[string]
    $allowedHosts = @('cdn19.mailercdn.net')
    $allowedRemoteBasenames = Get-AllowedRemoteAssetBasenames -ExtraBasenames $expectation.allowedRemoteAssetBasenames

    foreach ($src in $imageSources) {
        if ($src -match '^(?i)https?://') {
            Test-RemoteImageAllowed -Source $src -AllowedHosts $allowedHosts -AllowedBasenames $allowedRemoteBasenames
            continue
        }

        $localImages.Add($src)
        Test-LocalFilenameSanitized -FileName $src

        $localImagePath = Join-Path $mailerFolderPath $src
        if (-not (Test-Path -LiteralPath $localImagePath)) {
            Add-Failure("Referenced local image is missing beside the folder HTML: $src")
        }

        Test-2xUsage -Source $src -MailerFolderPath $mailerFolderPath -Allowed2xImages $expectation.allowed2xImages
    }

    foreach ($requiredLocalImage in ($expectation.requiredLocalImages | Where-Object { $_ })) {
        if ($localImages -notcontains [string]$requiredLocalImage) {
            Add-Failure("Required local image is not referenced in the HTML: $requiredLocalImage")
        }
    }

    $expectedZipEntries = @($mailerHtmlName) + @($localImages | Select-Object -Unique)

    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $zipEntries = @($zip.Entries | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Name) } | ForEach-Object { $_.FullName })

        foreach ($entry in $zipEntries) {
            if ($entry -match '[\\/]') {
                Add-Failure("ZIP entry is not flat. Expected files only at archive root: $entry")
            }
        }

        foreach ($expectedEntry in $expectedZipEntries) {
            if ($zipEntries -notcontains $expectedEntry) {
                Add-Failure("ZIP is missing expected file: $expectedEntry")
            }
        }

        foreach ($zipEntry in $zipEntries) {
            if ($expectedZipEntries -notcontains $zipEntry) {
                Add-Failure("ZIP contains an unexpected extra file: $zipEntry")
            }
        }
    }
    finally {
        $zip.Dispose()
    }
}

if ($script:Warnings.Count -gt 0) {
    foreach ($warning in $script:Warnings) {
        Write-Warning $warning
    }
}

if ($script:Failures.Count -gt 0) {
    $message = "Samsung mailer harness validation failed:`n- " + ($script:Failures -join "`n- ")
    throw $message
}

Write-Host 'Samsung mailer harness validation passed.' -ForegroundColor Green