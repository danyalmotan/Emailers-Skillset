$countries = @("GH", "NG", "KE", "TZ", "MU", "SN", "CI")
$mailers = @("3", "4", "5")
$basePath = "published"
$failures = @()
$passCount = 0

if (Test-Path "$basePath\ALL_IMAGES\server.html") { $passCount++ } else { $failures += "Missing: $basePath\ALL_IMAGES\server.html" }

foreach ($c in $countries) {
    foreach ($m in $mailers) {
        $filter = "*_$c $m"
        $folders = Get-ChildItem -Path $basePath -Directory -Filter $filter
        if ($folders.Count -eq 0) {
            $failures += "Missing: Folder for $c Mailer $m (filter: $filter)"
            continue
        }
        foreach ($folder in $folders) {
            $passCount++
            $zips = Get-ChildItem -Path $folder.FullName -Filter "*.zip"
            if ($zips.Count -eq 0) { $failures += "Missing: Zip in $($folder.Name)" }
            else {
                foreach($zip in $zips) {
                    if ($zip.BaseName -ne $folder.Name) { $failures += "Zip name mismatch: $($zip.Name) in $($folder.Name)" }
                }
            }
            
            $htmls = Get-ChildItem -Path $folder.FullName -Filter "*.html"
            foreach ($html in $htmls) {
                $content = Get-Content $html.FullName -Raw
                if ($content -notmatch "YYYYY") { $failures += "Fail: 'YYYYY' missing in $($html.Name) in $($folder.Name)" }
                if ($content -notmatch "ZZZZZ") { $failures += "Fail: 'ZZZZZ' missing in $($html.Name) in $($folder.Name)" }
                if ($content -match "https?://[^""]*unsubscribe") { $failures += "Fail: Live unsubscribe in $($html.Name) in $($folder.Name)" }
                if ($content -match "©") { $failures += "Fail: Raw copy symbol in $($html.Name) in $($folder.Name)" }
                
                $matches = [regex]::Matches($content, 'src=["''](?!(http|https|#|mailto:))([^"''?#]+)["'']')
                foreach ($match in $matches) {
                    $ref = $match.Groups[2].Value
                    if (-not (Test-Path (Join-Path $folder.FullName $ref))) {
                        $failures += "Fail: Broken src '$ref' in $($html.Name) ($($folder.Name))"
                    }
                }
            }
        }
    }
}
if ($failures.Count -eq 0) { "All systems go. Checked $passCount packages." } else { $failures }
