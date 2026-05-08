$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$Python = if ($env:PYTHON) { $env:PYTHON } else { "python" }

$EnvFile = Join-Path $Root ".env"
if ((-not $env:DEEPSEEK_API_KEY) -and (Test-Path $EnvFile)) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match "^\s*DEEPSEEK_API_KEY\s*=\s*(.+?)\s*$") {
            $env:DEEPSEEK_API_KEY = $Matches[1].Trim('"').Trim("'")
        }
    }
}

if (-not $env:DEEPSEEK_API_KEY) {
    Write-Host ""
    Write-Host "DEEPSEEK_API_KEY is not set for this shell."
    Write-Host "Option A, run this once in PowerShell, then reopen this launcher:"
    Write-Host '  [Environment]::SetEnvironmentVariable("DEEPSEEK_API_KEY", "YOUR_KEY_HERE", "User")'
    Write-Host ""
    Write-Host "Option B, create a local .env file next to this launcher:"
    Write-Host '  DEEPSEEK_API_KEY=YOUR_KEY_HERE'
    Write-Host ""
    Write-Host "For safety, this launcher does not store your API key in project files."
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

& $Python "$Root\simulate_hw1_deepseek.py" --json-out "$Root\report.json"
$ExitCode = $LASTEXITCODE

Write-Host ""
if ($ExitCode -eq 0) {
    Write-Host "Done. Full JSON report: $Root\report.json"
} else {
    Write-Host "Finished with failed checks or an API/script error. See output above."
    if (Test-Path "$Root\report.json") {
        Write-Host "Partial/full JSON report: $Root\report.json"
    }
}

Write-Host ""
Read-Host "Press Enter to close"
exit $ExitCode
