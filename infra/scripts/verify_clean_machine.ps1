param(
  [switch]$SkipDocker,
  [switch]$SkipDesktop,
  [switch]$SkipAndroid
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path "$PSScriptRoot\..\.."

Write-Host "FitCity clean-machine verification"
Write-Host "Step 1: Ensure .env exists in backend/"
if (-not (Test-Path (Join-Path $root "backend\\.env"))) {
  throw "backend\\.env not found. Copy from backend\\.env.example."
}

if (-not $SkipDocker) {
  Write-Host "Step 2: Backend up"
  Push-Location (Join-Path $root "infra\\docker")
  try {
    docker compose up --build -d
  } finally {
    Pop-Location
  }
}

if (-not $SkipDesktop) {
  Write-Host "Step 3: Windows desktop build"
  powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\\build_desktop.ps1" -Configuration release
  Write-Host "Desktop output: builds\\desktop\\Release\\fitcity_flutter.exe"
}

if (-not $SkipAndroid) {
  Write-Host "Step 4: Android APK build"
  powershell -ExecutionPolicy Bypass -File "$PSScriptRoot\\build_apk.ps1"
  Write-Host "APK output: builds\\mobile\\app-release.apk"
}

Write-Host "Step 5: Manual smoke checks"
Write-Host " - Run builds\\desktop\\Release\\fitcity_flutter.exe and login with central@fitcity.local / central"
Write-Host " - Install builds\\mobile\\app-release.apk on emulator and login with user1@gym.local / user1pass"
