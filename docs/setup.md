# Setup

## Prerequisites
- Docker Desktop
- .NET 8 SDK
- Flutter SDK on PATH
- Windows desktop toolchain for Flutter desktop builds
- Android SDK for APK builds

## First-time local setup
1. Create backend env file:
   - `Copy-Item backend\\.env.example backend\\.env`
2. Start backend services:
   - `docker compose up --build -d`
3. Restore Flutter packages:
   - `cd ui/mobile`
   - `flutter pub get`

## Build artifacts
- Desktop:
  - `powershell -ExecutionPolicy Bypass -File infra/scripts/build_desktop.ps1 -Configuration release`
  - Output: `builds/desktop/Release`
- Android APK:
  - `powershell -ExecutionPolicy Bypass -File infra/scripts/build_apk.ps1 -ApiBaseUrl http://10.0.2.2:8081`
  - Release APK builds require API base URL via `-ApiBaseUrl` or `FITCITY_API_BASE_URL`.
  - Output: `builds/mobile/app-release.apk`

## Validate clean machine
- `powershell -ExecutionPolicy Bypass -File infra/scripts/verify_clean_machine.ps1`
