param(
  [ValidateSet("debug", "release")]
  [string]$Configuration = "release",
  [switch]$Zip,
  [string]$OutputName,
  [string]$ApiBaseUrl
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path "$PSScriptRoot\.."
$uiDir = Join-Path $root "UI"

if (-not (Test-Path $uiDir)) {
  throw "UI folder not found at $uiDir"
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

  $mode = $Configuration
  flutter build windows "--$mode" -t lib/main_desktop.dart @defineArgs

  if ($mode -eq "debug") {
    $runnerDir = "build\windows\x64\runner\Debug"
  } else {
    $runnerDir = "build\windows\x64\runner\Release"
  }
  if (-not (Test-Path $runnerDir)) {
    throw "Runner output not found at $runnerDir"
  }

  $distDir = Join-Path $root "dist\windows"
  if ($mode -eq "debug") {
    $targetDir = Join-Path $distDir "Debug"
  } else {
    $targetDir = Join-Path $distDir "Release"
  }
  New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
  Copy-Item -Force -Recurse "$runnerDir\*" $targetDir

  $exePath = Join-Path $targetDir "fitcity_flutter.exe"
  if (-not (Test-Path $exePath)) {
    Write-Host "Warning: fitcity_flutter.exe not found at $exePath"
  }

  if ($Zip) {
    if (-not $OutputName) { $OutputName = "fitcity_desktop-$mode.zip" }
    $zipPath = Join-Path $distDir $OutputName
    if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
    Compress-Archive -Path "$targetDir\*" -DestinationPath $zipPath
    Write-Host "Desktop artifact zipped to $zipPath"
  } else {
    Write-Host "Desktop artifact copied to $targetDir"
  }
} finally {
  Pop-Location
}
