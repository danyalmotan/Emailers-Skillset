Add-Type -AssemblyName 'System.IO.Compression'
Add-Type -AssemblyName 'System.IO.Compression.FileSystem'

$pub = 'C:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113057  ROA A Series Sustain _ Mailer 2 _ W22\published'

function Recreate-Zip([string]$folderPath) {
    $zipName = (Split-Path $folderPath -Leaf) + '.zip'
    $zipPath = "$folderPath\$zipName"
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Extension -ne '.zip' }
    $zipStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::Create)
    $archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
    foreach ($f in $files) {
        $entry = $archive.CreateEntry($f.Name, [System.IO.Compression.CompressionLevel]::Optimal)
        $es = $entry.Open()
        $fs = [System.IO.File]::OpenRead($f.FullName)
        $fs.CopyTo($es)
        $fs.Close()
        $es.Close()
    }
    $archive.Dispose()
    $zipStream.Close()
    Write-Host "  Zip recreated: $zipName"
}

$subFolders = Get-ChildItem $pub -Directory

foreach ($folder in $subFolders) {
    $htmlFile = Get-ChildItem $folder.FullName -Filter '*.html' | Select-Object -First 1
    if (-not $htmlFile) { continue }

    Write-Host "Processing: $($htmlFile.Name)"
    $c = [System.IO.File]::ReadAllText($htmlFile.FullName, [System.Text.Encoding]::UTF8)

    # 1. emailContainer background #ffffff -> #EDEDED
    $c = $c -replace 'id="emailContainer" style="background-color:#ffffff;', 'id="emailContainer" style="background-color:#EDEDED;'

    # 2. Increase spacer row heights (largest first to avoid double-replace)
    $c = $c -replace '<tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>', '<tr><td height="50" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>'
    $c = $c -replace '<tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>', '<tr><td height="40" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>'
    $c = $c -replace '<tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>', '<tr><td height="35" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>'
    $c = $c -replace '<tr><td height="20" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>', '<tr><td height="30" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>'
    $c = $c -replace '<tr><td height="15" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>', '<tr><td height="25" style="font-size:1px; line-height:1px;">&nbsp;</td></tr>'

    [System.IO.File]::WriteAllText($htmlFile.FullName, $c, [System.Text.Encoding]::UTF8)
    Write-Host "  HTML updated"

    # 3. Recreate zip with updated HTML
    Recreate-Zip $folder.FullName

    # 4. Copy HTML to published root
    Copy-Item -Path $htmlFile.FullName -Destination "$pub\$($htmlFile.Name)" -Force
    Write-Host "  Copied to published root"
}

Write-Host ""
Write-Host "Done. Root HTML files:"
Get-ChildItem $pub -Filter '*.html' | ForEach-Object { Write-Host "  $($_.Name)" }
