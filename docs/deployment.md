# Deployment Notes

## Local container stack
- Compose file: `infra/docker/docker-compose.yml`
- Start:
  - `docker compose -f infra/docker/docker-compose.yml up --build -d`
- Stop:
  - `docker compose -f infra/docker/docker-compose.yml down`
- Reset volumes:
  - `docker compose -f infra/docker/docker-compose.yml down -v`

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
