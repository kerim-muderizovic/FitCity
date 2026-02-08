# Architecture

## System
- Flutter client in `ui/mobile` for mobile and desktop UX.
- .NET API in `backend/src/FitCity.Api`.
- .NET notifications worker in `backend/src/FitCity.Notifications.Api`.
- SQL Server + RabbitMQ provided by `infra/docker/docker-compose.yml`.

## Backend layering
- `backend/src/FitCity.Domain`: entities and enums.
- `backend/src/FitCity.Application`: use-case services, DTOs, interfaces.
- `backend/src/FitCity.Infrastructure`: persistence and EF migrations.
- `backend/src/FitCity.Api`: HTTP API, auth, SignalR hubs, Stripe endpoints.
- `backend/src/FitCity.Notifications.Api`: RabbitMQ consumer hosted service for queued email/notification work.

## Runtime dependency map
1. `ui/mobile` -> HTTP + SignalR -> `FitCity.Api`
2. `FitCity.Api` -> SQL Server
3. `FitCity.Api` -> RabbitMQ publish
4. `FitCity.Notifications.Api` -> RabbitMQ consume -> SQL Server log/send email

## Infra ownership
- Compose and Dockerfiles are centralized in `infra/docker`.
- Build scripts are centralized in `infra/scripts`.
- Generated artifacts are centralized in `builds`.
