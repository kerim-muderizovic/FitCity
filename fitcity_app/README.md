# Submission Run Guide

## 1) Start backend (Docker)
Open terminal in:
`submission/repo_source/FitCity`

Run:
`docker compose up --build -d`

Important:
- Correct command is `docker compose up --build -d`
- `docker compose build up -d` is invalid

API should be available on:
`http://localhost:8081`

## 2) Windows desktop app
Run:
`submission/dist/windows/Release/fitcity_flutter.exe`

## 3) Environment files
Both are included:
- `submission/.env`
- `submission/repo_source/FitCity/.env`

## 4) Android APK
Current package does not include `submission/dist/android/app-release.apk` because Android SDK is not installed on this machine.
To generate it on a machine with Android SDK:

1. Install Android Studio + Android SDK
2. From repo root run:
   `powershell -ExecutionPolicy Bypass -File scripts/build_apk.ps1`
3. Copy generated file from:
   `dist/android/app-release.apk`
   into:
   `submission/dist/android/app-release.apk`
