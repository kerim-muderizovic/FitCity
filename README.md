# FitCity Repository

FitCity is a Flutter client + .NET backend platform for gym management, memberships, bookings, chat, notifications, and payments.

## 60-second overview
- `ui/mobile/`: Flutter app source (mobile + desktop entrypoints).
- `backend/`: .NET solution (`FitCity.sln`) with API, application, domain, infrastructure, and notifications worker.
- `infra/docker/`: Docker Compose and Dockerfiles for backend runtime stack.
- `infra/scripts/`: build and verification scripts.
- `builds/`: generated build artifacts (`mobile/`, `desktop/`) and nothing else.
- `docs/`: architecture, setup, deployment, migration notes.

## Quick start
1. Copy env file:
   - `Copy-Item backend\\.env.example backend\\.env`
2. Start backend stack:
   - `docker compose -f infra/docker/docker-compose.yml up --build -d`
3. Build desktop app:
   - `powershell -ExecutionPolicy Bypass -File infra/scripts/build_desktop.ps1 -Configuration release`
4. Build Android APK:
   - `powershell -ExecutionPolicy Bypass -File infra/scripts/build_apk.ps1`

## Key endpoints
- API: `http://localhost:8081`
- RabbitMQ UI: `http://localhost:15672`
- SQL Server: `localhost:1433`

## Artifact policy
- `builds/mobile` and `builds/desktop` are generated outputs.
- Source code must not be committed under generated output folders.
- Keep only `.gitkeep` markers in `builds/*` by default.

## Documentation
- `docs/architecture.md`
- `docs/setup.md`
- `docs/deployment.md`
- `docs/migration-plan.md`
