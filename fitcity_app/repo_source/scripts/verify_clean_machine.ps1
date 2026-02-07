param(
  [switch]$SkipDocker,
  [switch]$SkipDesktop,
  [switch]$SkipAndroid
)

$ErrorActionPreference = "Stop"

Write-Host "FitCity clean-machine verification"
Write-Host "Step 1: Ensure .env exists in FitCity/"
if (-not (Test-Path "FitCity\\.env")) {
  throw "FitCity\\.env not found. Copy from FitCity\\.env.example or unzip .env.zip (password: fit)."
}

if (-not $SkipDocker) {
  Write-Host "Step 2: Backend up"
  Push-Location "FitCity"
  try {
    docker compose up --build -d
  } finally {
    Pop-Location
  }
}

if (-not $SkipDesktop) {
  Write-Host "Step 3: Windows desktop build"
  powershell -ExecutionPolicy Bypass -File scripts\\build_desktop.ps1 -Configuration release
  Write-Host "Desktop output: dist\\windows\\Release\\fitcity_flutter.exe"
}

if (-not $SkipAndroid) {
  Write-Host "Step 4: Android APK build"
  powershell -ExecutionPolicy Bypass -File scripts\\build_apk.ps1
  Write-Host "APK output: dist\\android\\app-release.apk"
}

Write-Host "Step 5: Manual smoke checks"
Write-Host " - Run dist\\windows\\Release\\fitcity_flutter.exe and login with central@fitcity.local / central"
Write-Host " - Install dist\\android\\app-release.apk on emulator and login with user1@gym.local / user1pass"
