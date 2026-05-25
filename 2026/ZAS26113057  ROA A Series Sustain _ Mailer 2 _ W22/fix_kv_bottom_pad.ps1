Add-Type -AssemblyName System.IO.Compression.FileSystem

$publishedRoot = "C:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113057  ROA A Series Sustain _ Mailer 2 _ W22\published"

$kvRegex = [System.Text.RegularExpressions.Regex]::new(
    '<!-- KV \+ Main copy section -->.*?</table>',
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)
# RightToLeft finds the LAST height="25" in the KV section = the one after the CTA button
$spacerRegex = [System.Text.RegularExpressions.Regex]::new(
    'height="25"',
    [System.Text.RegularExpressions.RegexOptions]::RightToLeft
)

$htmlFiles = Get-ChildItem -Path $publishedRoot -Filter "*.html" -Recurse
foreach ($file in $htmlFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

    $kvMatch = $kvRegex.Match($content)
    if (-not $kvMatch.Success) { Write-Host "KV not found: $($file.Name)"; continue }

    $kvSection = $kvMatch.Value
    $lastSpacer = $spacerRegex.Match($kvSection)
    if (-not $lastSpacer.Success) { Write-Host "Spacer not found: $($file.Name)"; continue }

    # Replace only that last height="25" with height="60" using index position
    $modifiedKv = $kvSection.Remove($lastSpacer.Index, $lastSpacer.Length).Insert($lastSpacer.Index, 'height="60"')
    $content = $content.Replace($kvSection, $modifiedKv)

    [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    Write-Host "Updated: $($file.Name)"
}

# Recreate ZIPs via TEMP to avoid OneDrive locking
$tempDir = "$env:TEMP\mailer_zips_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir | Out-Null

$subfolders = Get-ChildItem -Path $publishedRoot -Directory
foreach ($folder in $subfolders) {
    $tempZip = Join-Path $tempDir "$($folder.Name).zip"
    $destZip = Join-Path $folder.FullName "$($folder.Name).zip"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($folder.FullName, $tempZip)
    Copy-Item -Path $tempZip -Destination $destZip -Force
    Write-Host "ZIP ok: $($folder.Name)"
}

Remove-Item $tempDir -Recurse -Force
Write-Host "All done."
