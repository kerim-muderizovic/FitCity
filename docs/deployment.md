# Deployment Notes

## Local container stack
- Root compose file: `docker-compose.yml` (includes `infra/docker/compose.stack.yml` and loads `backend/.env`)
- Start:
  - `docker compose up --build -d`
- Stop:
  - `docker compose down`
- Reset volumes:
  - `docker compose down -v`

## Services
- API container: `fitcity-api` (port `8081` mapped to container `8080`)
- Notifications worker: `fitcity-notifications-worker`
- SQL Server: `fitcity-sqlserver` (`1433`)
- RabbitMQ: `fitcity-rabbitmq` (`5672`, UI `15672`)

## Build and packaging
- Desktop package source: `builds/desktop/Release`
- Mobile package source: `builds/mobile`

## Environment configuration
- Local env file path: `backend/.env`
- Template: `backend/.env.example`
