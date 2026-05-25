Add-Type -AssemblyName System.IO.Compression.FileSystem

$publishedRoot = "C:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113057  ROA A Series Sustain _ Mailer 2 _ W22\published"

function Update-KvSection($htmlContent) {
    # Match only the KV section: from the comment to the closing </table> of emailContainer
    # Non-greedy so it stops at the first </table> (emailContainer has no nested tables)
    $kvRegex = [System.Text.RegularExpressions.Regex]::new(
        '<!-- KV \+ Main copy section -->.*?</table>',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
    $kvMatch = $kvRegex.Match($htmlContent)
    if (-not $kvMatch.Success) { return $null }

    $original = $kvMatch.Value
    $modified = $original

    # Half the spacers in the KV area
    $modified = $modified -replace 'height="50"', 'height="25"'
    $modified = $modified -replace 'height="35"', 'height="18"'

    # Increase main KV headline from 36px to 48px
    $modified = $modified -replace 'font-size:36px', 'font-size:48px'

    return $htmlContent.Replace($original, $modified)
}

# --- Update all HTML files (subfolders + root copies) ---
$htmlFiles = Get-ChildItem -Path $publishedRoot -Filter "*.html" -Recurse
foreach ($file in $htmlFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $updated = Update-KvSection $content
    if ($updated) {
        [System.IO.File]::WriteAllText($file.FullName, $updated, [System.Text.Encoding]::UTF8)
        Write-Host "Updated:  $($file.Name)"
    } else {
        Write-Host "SKIPPED (KV not found): $($file.Name)"
    }
}

# --- Recreate ZIPs for each subfolder ---
$subfolders = Get-ChildItem -Path $publishedRoot -Directory
foreach ($folder in $subfolders) {
    # Remove old ZIP
    $existingZip = Get-ChildItem -Path $folder.FullName -Filter "*.zip" -ErrorAction SilentlyContinue
    if ($existingZip) { Remove-Item $existingZip.FullName -Force }

    # Create fresh ZIP
    $zipPath = Join-Path $folder.FullName "$($folder.Name).zip"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($folder.FullName, $zipPath)
    Write-Host "ZIP done:  $($folder.Name).zip"
}

Write-Host ""
Write-Host "All done."
