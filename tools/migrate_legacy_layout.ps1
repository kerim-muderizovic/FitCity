param(
  [switch]$Apply,
  [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = (git rev-parse --show-toplevel).Trim()
Set-Location $repoRoot

if (-not $Force) {
  $dirty = git status --porcelain
  if ($dirty) {
    throw "Working tree is not clean. Commit or stash changes, or run with -Force."
  }
}

function Ensure-Dir([string]$Path) {
  if ($Apply) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  } else {
    Write-Host "[DRY] mkdir $Path"
  }
}

function Move-Path([string]$From, [string]$To) {
  if (-not (Test-Path $From)) {
    Write-Host "[SKIP] Missing: $From"
    return
  }

  $parent = Split-Path -Parent $To
  if ($parent) { Ensure-Dir $parent }

  if ($Apply) {
    git mv $From $To
  } else {
    Write-Host "[DRY] git mv $From $To"
  }
}

function Remove-Path([string]$Path) {
  if (-not (Test-Path $Path)) {
    return
  }
  if ($Apply) {
    git rm -r -f --ignore-unmatch $Path | Out-Null
  } else {
    Write-Host "[DRY] git rm -r -f $Path"
  }
}

Write-Host "Legacy migration script running in: $repoRoot"
if ($Apply) {
  Write-Host "Mode: APPLY"
} else {
  Write-Host "Mode: DRY-RUN"
}

Move-Path "fitcity_app/repo_source/UI" "ui/mobile"
Ensure-Dir "ui/desktop"
Move-Path "fitcity_app/repo_source/FitCity" "backend"
Move-Path "fitcity_app/repo_source/scripts" "infra/scripts"
Move-Path "fitcity_app/repo_source/.gitignore" ".gitignore"
Move-Path "fitcity_app/.env.example" "backend/.env.example"

Move-Path "backend/docker-compose.yml" "infra/docker/docker-compose.yml"
Move-Path "backend/src/FitCity.Api/Dockerfile" "infra/docker/fitcity-api.Dockerfile"
Move-Path "backend/src/FitCity.Notifications.Api/Dockerfile" "infra/docker/fitcity-notifications-worker.Dockerfile"

Remove-Path "fitcity_app/.env.zip"
Remove-Path "backend/.env.zip"

if ($Apply) {
  Write-Host "Migration apply complete."
} else {
  Write-Host "Dry run complete. Re-run with -Apply to execute."
}
