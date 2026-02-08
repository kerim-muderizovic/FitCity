# Backend

This folder contains the .NET solution and tests.

## Layout
- `src/FitCity.Api`: HTTP API + SignalR hubs
- `src/FitCity.Application`: application services and interfaces
- `src/FitCity.Domain`: domain entities/enums
- `src/FitCity.Infrastructure`: EF Core persistence and migrations
- `src/FitCity.Notifications.Api`: notifications worker service
- `tests/FitCity.Application.Tests`: xUnit tests

## Build
- `dotnet build backend/FitCity.sln`
- `dotnet test backend/tests/FitCity.Application.Tests/FitCity.Application.Tests.csproj`

## Runtime
- Compose stack is managed from `infra/docker/docker-compose.yml`.
