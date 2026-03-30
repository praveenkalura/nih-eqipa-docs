$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Join-Path $projectRoot ".venv\Scripts\python.exe"
$devAddr = "127.0.0.1:8000"
$siteUrl = "http://$devAddr/nih-eqipa-docs/"

if (-not (Test-Path $python)) {
    throw "Virtual environment Python not found at $python"
}

Set-Location $projectRoot

# Stop any existing MkDocs dev servers bound to the same dev address so the
# browser always hits the current project instance.
$mkdocsProcs = Get-CimInstance Win32_Process |
    Where-Object {
        $_.CommandLine -and
        $_.CommandLine -match "mkdocs serve" -and
        $_.CommandLine -match [regex]::Escape($devAddr)
    }

foreach ($proc in $mkdocsProcs) {
    Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 2

Remove-Item -LiteralPath "mkdocs.out.log" -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath "mkdocs.err.log" -Force -ErrorAction SilentlyContinue

$proc = Start-Process `
    -FilePath $python `
    -ArgumentList "-m", "mkdocs", "serve", "--dev-addr", $devAddr `
    -WorkingDirectory $projectRoot `
    -RedirectStandardOutput "mkdocs.out.log" `
    -RedirectStandardError "mkdocs.err.log" `
    -PassThru

Start-Sleep -Seconds 5

try {
    $response = Invoke-WebRequest -Uri $siteUrl -UseBasicParsing -TimeoutSec 10
    Write-Host "MkDocs dev server started successfully."
    Write-Host "URL: $siteUrl"
    Write-Host "PID: $($proc.Id)"
    Write-Host "HTTP: $($response.StatusCode)"
} catch {
    Write-Host "MkDocs process started, but the site did not respond as expected yet."
    Write-Host "Check mkdocs.err.log for details."
    throw
}
