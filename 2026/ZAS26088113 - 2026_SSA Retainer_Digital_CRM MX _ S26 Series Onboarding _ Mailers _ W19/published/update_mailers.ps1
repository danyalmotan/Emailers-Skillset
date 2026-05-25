$files = @(
    "ZAS26088113  S26 Series Onboarding_Mailers_W19_GH 4.html",
    "ZAS26088113  S26 Series Onboarding_Mailers_W19_NG 4.html",
    "ZAS26088113  S26 Series Onboarding_Mailers_W19_KE 4.html",
    "ZAS26088113  S26 Series Onboarding_Mailers_W19_TZ 4.html",
    "ZAS26088113  S26 Series Onboarding_Mailers_W19_MU 4.html"
)
$targetDir = "HTML"
$totalLearnMore = 0
$totalExploreNow = 0
$filesChanged = 0
foreach ($fileName in $files) {
    $filePath = Join-Path $targetDir $fileName
    if (Test-Path $filePath) {
        $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
        $lmOld = "https://cdn19.mailercdn.net/users/assets/379/images/138268/8SWzuRbl5iBMZEiD/007_m3e_learn_more.png?v=1778866946"
        $enOld = "https://cdn19.mailercdn.net/users/assets/379/images/138268/8SWzuRbl5iBMZEiD/004_m3e_explore_now.png?v=1778866946"
        $totalLearnMore += ([regex]::Matches($content, [regex]::Escape($lmOld))).Count
        $totalExploreNow += ([regex]::Matches($content, [regex]::Escape($enOld))).Count
        $content = $content.Replace($lmOld, "https://cdn19.mailercdn.net/users/assets/379/images/m3e_learn_more_1.png")
        $content = $content.Replace($enOld, "https://cdn19.mailercdn.net/users/assets/379/images/138268/8SWzuRbl5iBMZEiD/039_m5e_explore_now.png?v=1778866946")
        $content = [regex]::Replace($content, "(<img[^>]*alt=`"(Learn more|Explore now)`"[^>]*?)\s+height=`"\d+`"", "$1 height=`"50`"")
        $content = [regex]::Replace($content, "(<img\s+(?![^>]*height=`")(?=[^>]*alt=`"(Learn more|Explore now)`"))([^>]+)>", "$1$3 height=`"50`">")
        [System.IO.File]::WriteAllText($filePath, $content, [System.Text.Encoding]::UTF8)
        $filesChanged++
    }
}
Write-Host "Files changed: $filesChanged"
Write-Host "Learn More replacements: $totalLearnMore"
Write-Host "Explore Now replacements: $totalExploreNow"
