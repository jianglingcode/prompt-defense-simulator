$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$PythonCandidates = @()
if ($env:PYTHON) {
    $PythonCandidates += $env:PYTHON
}
$PythonCandidates += "python"
$PythonCandidates += "py"

$Python = $null
foreach ($Candidate in $PythonCandidates) {
    try {
        & $Candidate --version *> $null
        if ($LASTEXITCODE -eq 0) {
            $Python = $Candidate
            break
        }
    } catch {
    }
}

if (-not $Python) {
    Write-Host "Could not find Python. Please install Python 3 or set the PYTHON environment variable."
    Read-Host "Press Enter to exit"
    exit 1
}

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
    $Key = Read-Host "Paste your DeepSeek API key for this run"
    if (-not $Key) {
        Write-Host "No API key entered."
        Read-Host "Press Enter to exit"
        exit 1
    }
    $env:DEEPSEEK_API_KEY = $Key
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
