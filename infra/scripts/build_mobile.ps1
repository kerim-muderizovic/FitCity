param(
  [ValidateSet("debug", "release")]
  [string]$Configuration = "release",
  [switch]$AppBundle,
  [string]$OutputName,
  [string]$ApiBaseUrl
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\..\.."
$uiDir = Join-Path $root "ui\mobile"

if (-not (Test-Path $uiDir)) {
  throw "Flutter UI folder not found at $uiDir"
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw "Flutter not found on PATH. Install Flutter and ensure it is on PATH."
}

Push-Location $uiDir
try {
  flutter pub get

  $defineArgs = @()
  if ($ApiBaseUrl) {
    $defineArgs += "--dart-define=FITCITY_API_BASE_URL=$ApiBaseUrl"
  }

  if ($AppBundle) {
    $mode = $Configuration
    flutter build appbundle "--$mode" -t lib/main_mobile.dart @defineArgs
    $source = "build\app\outputs\bundle\$mode\app-$mode.aab"
    if (-not $OutputName) { $OutputName = "app-$mode.aab" }
  } else {
    $mode = $Configuration
    flutter build apk "--$mode" -t lib/main_mobile.dart @defineArgs
    $source = "build\app\outputs\flutter-apk\app-$mode.apk"
    if (-not $OutputName) { $OutputName = "app-$mode.apk" }
  }

  if (-not (Test-Path $source)) {
    throw "Build artifact not found at $source"
  }

  $distDir = Join-Path $root "builds\mobile"
  New-Item -ItemType Directory -Force -Path $distDir | Out-Null
  Copy-Item -Force $source (Join-Path $distDir $OutputName)
  Write-Host "Mobile artifact copied to $distDir\$OutputName"
} finally {
  Pop-Location
}
