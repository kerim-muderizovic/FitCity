param(
  [string]$OutputName = "app-release.apk"
)

$ErrorActionPreference = "Stop"

& "$PSScriptRoot\build_mobile.ps1" -Configuration release -OutputName $OutputName
