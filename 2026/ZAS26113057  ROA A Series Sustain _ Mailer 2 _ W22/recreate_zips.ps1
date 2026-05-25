Add-Type -AssemblyName System.IO.Compression.FileSystem

$publishedRoot = "C:\Users\user\OneDrive\digidanWork\Mailers\2026\ZAS26113057  ROA A Series Sustain _ Mailer 2 _ W22\published"
$tempDir = "$env:TEMP\mailer_zips_$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir | Out-Null

$subfolders = Get-ChildItem -Path $publishedRoot -Directory
foreach ($folder in $subfolders) {
    $destZip = Join-Path $folder.FullName "$($folder.Name).zip"

    # Delete existing ZIP
    if (Test-Path $destZip) {
        Remove-Item $destZip -Force
        Write-Host "Deleted: $($folder.Name).zip"
    }

    # Build fresh ZIP in TEMP (avoids OneDrive locking the destination)
    $tempZip = Join-Path $tempDir "$($folder.Name).zip"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($folder.FullName, $tempZip)

    # Copy to destination
    Copy-Item -Path $tempZip -Destination $destZip -Force
    $size = [math]::Round((Get-Item $destZip).Length / 1KB, 1)
    Write-Host "Created ($($size)KB): $($folder.Name).zip"
}

Remove-Item $tempDir -Recurse -Force
Write-Host ""
Write-Host "All ZIPs recreated."
