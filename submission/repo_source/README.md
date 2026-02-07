# FitCity

Flutter + .NET + Docker seminar project.

## Repository layout
- `UI/` Flutter frontend (mobile + Windows desktop)
- `FitCity/` .NET backend + Docker Compose
- `scripts/` build + verification helpers
- `dist/` build artifacts (Windows + Android)

## Backend (Docker Compose)
Prerequisites:
- Docker Desktop

Setup:
1. Ensure `FitCity/.env` exists. If missing, copy from `FitCity/.env.example` or unzip `.env.zip` (password: `fit`).
2. Run:

```powershell
cd FitCity
docker compose up --build
```

Services:
- API: `http://localhost:8081`
- Notifications worker: container `fitcity-notifications-worker` (no HTTP port)
- SQL Server: `localhost:1433`
- RabbitMQ: `localhost:5672`
- RabbitMQ UI: `http://localhost:15672`

Notes:
- Connection string, JWT, RabbitMQ, Email, Stripe settings are provided via `.env` and injected into containers.
- If SQL Server fails to initialize, reset volumes:
```powershell
cd FitCity
docker compose down -v
docker compose up --build
```

## Worker (separate container)
The RabbitMQ consumer runs in its own worker project/container (`fitcity-notifications-worker`), not inside the API.

Test flow (queues a message):
```powershell
curl -X POST http://localhost:8081/api/admin/diagnostics/notifications/test-email ^
  -H "Authorization: Bearer <central-admin-token>" ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"central@fitcity.local\",\"name\":\"Central Admin\"}"
```
Worker writes a log entry into the Notifications DB.

## Frontend (Flutter)
Prerequisites:
- Flutter SDK on PATH
- Windows desktop: Visual Studio with "Desktop development with C++"
- Android: Android Studio + SDK, Java 17

### API Base URL config
Central config file: `UI/assets/config/app_config.json`
- Android default: `http://10.0.2.2:8081`
- Desktop default: `http://localhost:8081`

Optional build override:
```powershell
--dart-define=FITCITY_API_BASE_URL=http://localhost:8081
```

## Build artifacts (required for submission)
### Windows Desktop EXE
```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_desktop.ps1 -Configuration release
```
Output:
- `dist/windows/Release/` (full folder, includes `fitcity_flutter.exe` and DLLs)

### Android APK
```powershell
powershell -ExecutionPolicy Bypass -File scripts\build_apk.ps1
```
Output:
- `dist/android/app-release.apk`

If APK build fails with `No Android SDK found`, install Android Studio and set:
- `ANDROID_HOME` or `ANDROID_SDK_ROOT`

## Test credentials
Central admin:
- `central@fitcity.local` / `central`

Gym admins:
- `admin.novosarajevo@fitcity.local` / `gymnovo1`
- `admin.grbavica@fitcity.local` / `gymgrb1`
- `admin.bosna@fitcity.local` / `gymbosna1`
- `admin.grada@fitcity.local` / `gymgrada1`

Trainers:
- `trainer1@gym.local` / `trainer1pass`
- `trainer2@gym.local` / `trainer2pass`
- `trainer3@gym.local` / `trainer3pass`
- `trainer4@gym.local` / `trainer4pass`
- `trainer5@gym.local` / `trainer5pass`
- `trainer6@gym.local` / `trainer6pass`

Users:
- `user1@gym.local` / `user1pass`
- `user2@gym.local` / `user2pass`
- `user3@gym.local` / `user3pass`
- `user4@gym.local` / `user4pass`
- `user5@gym.local` / `user5pass`

## Clean machine checklist
Use:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify_clean_machine.ps1
```

Manual steps:
1. `git clone ...`
2. Ensure `FitCity/.env` exists (or unzip `.env.zip`, password `fit`).
3. `cd FitCity` and run `docker compose up --build`.
4. Run Windows app from `dist/windows/Release/fitcity_flutter.exe`.
5. Install `dist/android/app-release.apk` on AVD and login.

## Manual QA checklist
1. Central admin login (desktop): `central@fitcity.local` / `central`.
2. Create a booking or membership and confirm worker logs an entry (RabbitMQ consumer).
3. Toggle registration/trainer creation in Admin Settings and verify errors are shown when disabled.
4. Mobile login (AVD) using `user1@gym.local` / `user1pass`.

## No PayPal
This project does not use PayPal.
