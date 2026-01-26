param(
  [string]$OutputName = "fitcity_mobile.apk"
)

$ErrorActionPreference = "Stop"

Push-Location "$PSScriptRoot\..\fitcity_flutter"
try {
  flutter build apk --release -t lib/main_mobile.dart
  $sourceApk = "build\app\outputs\flutter-apk\app-release.apk"
  if (-not (Test-Path $sourceApk)) {
    throw "APK not found at $sourceApk"
  }
  $targetDir = "..\artifacts\apk"
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
  Copy-Item -Force $sourceApk (Join-Path $targetDir $OutputName)
  Write-Host "APK copied to $targetDir\$OutputName"
} finally {
  Pop-Location
}
