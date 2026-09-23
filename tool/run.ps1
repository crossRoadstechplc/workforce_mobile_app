# Loads .env and runs: flutter run --dart-define=...
# Usage (from workforce_employee_app):
#   .\tool\run.ps1
#   .\tool\run.ps1 -d chrome
#   .\tool\run.ps1 -d windows
#   .\tool\run.ps1 -d web-server --web-port 5183
#
# From parent workforce-employee-app folder:
#   .\run.ps1 -d chrome

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$envFile = Join-Path $root ".env"
$example = Join-Path $root ".env.example"
if (-not (Test-Path $envFile)) {
  if (-not (Test-Path $example)) { throw "Missing .env.example" }
  Copy-Item $example $envFile
  Write-Host "Created .env from .env.example - edit URLs if needed."
}

$defines = @()
Get-Content $envFile | ForEach-Object {
  $line = $_.Trim()
  if (-not $line -or $line.StartsWith("#")) { return }
  $idx = $line.IndexOf("=")
  if ($idx -lt 1) { return }
  $key = $line.Substring(0, $idx).Trim()
  $value = $line.Substring($idx + 1).Trim().Trim('"').Trim("'")
  if ($key -and $value) {
    # bool.fromEnvironment expects true/false without quotes
    $defines += "--dart-define=$key=$value"
  }
}

if ($defines.Count -eq 0) {
  throw ".env has no KEY=value entries."
}

$extra = ($args -join " ")
Write-Host ("flutter run " + ($defines -join " ") + " " + $extra)
& flutter run @defines @args
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
