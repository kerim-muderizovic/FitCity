param(
  [string]$OutputName = "app-release.apk",
  [string]$ApiBaseUrl
)

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\build_mobile.ps1" -Configuration release -OutputName $OutputName -ApiBaseUrl $ApiBaseUrl
