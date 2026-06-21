[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MailerFolderPath,

    [string]$OutputPath,

    [string]$Name,

    [switch]$Validate
)

function Get-NormalizedText {
    param([string]$Text)
    return ($Text -replace "`r`n", "`n") -replace "`r", "`n"
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

function Get-Slug {
    param([string]$Value)

    $slug = $Value.ToLowerInvariant()
    $slug = $slug -replace '[^a-z0-9]+', '-'
    $slug = $slug.Trim('-')

    if (-not $slug) {
        throw 'Could not derive a slug for the expectation file name.'
    }

    return $slug
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $baseUri = [System.Uri]((Resolve-Path -LiteralPath $BasePath).Path + [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri](Resolve-Path -LiteralPath $TargetPath).Path
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace('/', '\\')
}

$resolvedMailerFolder = Resolve-Path -LiteralPath $MailerFolderPath -ErrorAction Stop
$mailerFolder = Get-Item -LiteralPath $resolvedMailerFolder.Path

if (-not $mailerFolder.PSIsContainer) {
    throw "MailerFolderPath must be a directory: $MailerFolderPath"
}

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$harnessDirectory = Split-Path -Parent $scriptDirectory
$expectedDirectory = Join-Path $harnessDirectory 'expected'

$htmlFiles = Get-ChildItem -LiteralPath $mailerFolder.FullName -Filter *.html -File | Sort-Object Name
if ($htmlFiles.Count -ne 1) {
    throw "Expected exactly one HTML file in the mailer folder, found $($htmlFiles.Count): $($mailerFolder.FullName)"
}

$mailerHtmlFile = $htmlFiles[0]
$mailerName = [System.IO.Path]::GetFileNameWithoutExtension($mailerHtmlFile.Name)

$publishedFolder = Split-Path -Parent $mailerFolder.FullName
$jobFolder = Split-Path -Parent $publishedFolder

$rootHtmlPath = Join-Path $publishedFolder $mailerHtmlFile.Name
$requireRootHtmlCopy = Test-Path -LiteralPath $rootHtmlPath

$zipFiles = Get-ChildItem -LiteralPath $mailerFolder.FullName -Filter *.zip -File | Sort-Object Name
$requireFolderZip = $zipFiles.Count -gt 0

$zipName = if ($requireFolderZip) {
    $matchingZip = $zipFiles | Where-Object { $_.BaseName -eq $mailerHtmlFile.BaseName } | Select-Object -First 1
    if ($matchingZip) {
        $matchingZip.Name
    }
    elseif ($zipFiles.Count -eq 1) {
        $zipFiles[0].Name
    }
    else {
        throw "Multiple ZIP files found in mailer folder and none match the HTML name: $($mailerFolder.FullName)"
    }
}
else {
    "$mailerName.zip"
}

$html = Get-NormalizedText (Get-Content -LiteralPath $mailerHtmlFile.FullName -Raw -Encoding UTF8)

$titleMatch = [regex]::Match($html, '(?is)<title>(.*?)</title>')
$titleContains = if ($titleMatch.Success) { $titleMatch.Groups[1].Value.Trim() } else { '' }

$mustContain = New-Object System.Collections.Generic.List[string]
foreach ($needle in @(
    'MirrorPageUrl',
    'smgUnsub?id=<%= escapeUrl(recipient.cryptedId) %>&lang=en&unsub=true',
    'class="preheader"'
)) {
    if ($html.IndexOf($needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 -and -not $mustContain.Contains($needle)) {
        $mustContain.Add($needle)
    }
}

$bodyBackgroundMatch = [regex]::Match($html, '(?i)<body\b[^>]*style\s*=\s*["''][^"'']*background-color\s*:\s*([^;"'']+)')
if ($bodyBackgroundMatch.Success) {
    $bodyBackground = ('background-color:' + $bodyBackgroundMatch.Groups[1].Value.Trim())
    if (-not $mustContain.Contains($bodyBackground)) {
        $mustContain.Add($bodyBackground)
    }
}

$imageSources = Get-UniqueImageSources -Html $html
$requiredLocalImages = @()
$allowedRemoteHosts = New-Object System.Collections.Generic.List[string]
$allowedRemoteAssetBasenames = New-Object System.Collections.Generic.List[string]

foreach ($source in $imageSources) {
    if ($source -match '^(?i)https?://') {
        try {
            $uri = [System.Uri]$source
            if ($uri.Host -ne 'cdn19.mailercdn.net' -and -not $allowedRemoteHosts.Contains($uri.Host)) {
                $allowedRemoteHosts.Add($uri.Host)
            }

            $basename = [System.IO.Path]::GetFileName($uri.AbsolutePath)
            if ($basename -and -not $allowedRemoteAssetBasenames.Contains($basename)) {
                $allowedRemoteAssetBasenames.Add($basename)
            }
        }
        catch {
            # Leave invalid URLs for the validator to catch later.
        }

        continue
    }

    $requiredLocalImages += $source
}

foreach ($localImage in ($requiredLocalImages | Select-Object -First 3)) {
    if (-not $mustContain.Contains($localImage)) {
        $mustContain.Add($localImage)
    }
}

$expectationName = if ($Name) { $Name } else { Get-Slug -Value $mailerName }
$outputFilePath = if ($OutputPath) {
    $OutputPath
}
else {
    Join-Path $expectedDirectory ($expectationName + '.expected.json')
}

$outputDirectory = Split-Path -Parent $outputFilePath
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    throw "Expectation output directory does not exist: $outputDirectory"
}

$expectation = [ordered]@{
    name = $expectationName
    jobFolder = Get-RelativePath -BasePath $outputDirectory -TargetPath $jobFolder
    rootHtml = $mailerHtmlFile.Name
    mailerFolder = $mailerFolder.Name
    mailerHtml = $mailerHtmlFile.Name
    zipName = $zipName
    requireRootHtmlCopy = $requireRootHtmlCopy
    requireFolderZip = $requireFolderZip
    titleContains = $titleContains
    mustContain = @($mustContain)
    mustNotContain = @('ZZZZZ', 'YYYYY')
    requiredLocalImages = @($requiredLocalImages)
    allowed2xImages = @()
    allowedRemoteHosts = @($allowedRemoteHosts)
    allowedRemoteAssetBasenames = @($allowedRemoteAssetBasenames)
}

$expectation | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $outputFilePath -Encoding UTF8

Write-Host "Created expectation: $outputFilePath" -ForegroundColor Green

if ($Validate) {
    $validatorPath = Join-Path $scriptDirectory 'validate-mailer-output.ps1'
    & $validatorPath -ExpectationPath $outputFilePath
}