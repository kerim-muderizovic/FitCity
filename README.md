# FitCity

## Repository layout
- `UI/` - Flutter frontend
- `FitCity/` - .NET backend solution and Docker Compose

## Backend (Docker Compose)
Prerequisites:
- Docker Desktop

Run:
```powershell
cd FitCity
docker compose up --build
```

Services and ports:
- API: http://localhost:8081
- Notifications API: http://localhost:8082
- SQL Server: localhost:1433
- RabbitMQ Management UI: http://localhost:15672

Stop:
```powershell
docker compose down
```

Notes:
- The default SQL Server password is set in `FitCity/docker-compose.yml` as `Your_password123`. Update it if needed.

## Frontend (Flutter)
Prerequisites:
- Flutter SDK installed and on PATH

Run:
```powershell
cd UI
flutter pub get
flutter run
```
