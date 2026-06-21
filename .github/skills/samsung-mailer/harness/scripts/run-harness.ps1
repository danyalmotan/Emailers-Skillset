[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ExpectationDirectory
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$validatorPath = Join-Path $scriptPath 'validate-mailer-output.ps1'

if (-not (Test-Path -LiteralPath $validatorPath)) {
    throw "Validator script not found: $validatorPath"
}

$resolvedDir = Resolve-Path -LiteralPath $ExpectationDirectory -ErrorAction Stop
$expectationFiles = Get-ChildItem -LiteralPath $resolvedDir.Path -Filter *.expected.json -File |
    Where-Object { $_.Name -ne 'template.expected.json' } |
    Sort-Object Name

if (-not $expectationFiles) {
    throw "No *.expected.json files found in $($resolvedDir.Path)"
}

$failed = @()

foreach ($file in $expectationFiles) {
    Write-Host "==> Validating $($file.Name)" -ForegroundColor Cyan

    try {
        & $validatorPath -ExpectationPath $file.FullName
        Write-Host "PASS $($file.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "FAIL $($file.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        $failed += $file.FullName
    }

    Write-Host ''
}

if ($failed.Count -gt 0) {
    throw ("Harness failed for {0} expectation file(s).`n{1}" -f $failed.Count, ($failed -join "`n"))
}

Write-Host "Harness passed for $($expectationFiles.Count) expectation file(s)." -ForegroundColor Green