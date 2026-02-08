# Migration Plan (Legacy -> Current Layout)

## Completed moves
1. Moved source roots out of `fitcity_app`:
   - `fitcity_app/repo_source/FitCity` -> `backend`
   - `fitcity_app/repo_source/UI` -> `ui/mobile`
   - `fitcity_app/repo_source/scripts` -> `infra/scripts`
   - `fitcity_app/dist` -> `builds` (then normalized to `builds/mobile`, `builds/desktop`)
2. Consolidated Docker files:
   - `backend/docker-compose.yml` -> `infra/docker/docker-compose.yml`
   - project Dockerfiles -> `infra/docker/*.Dockerfile`
3. Removed legacy backend template files from `backend/` root.
4. Removed committed runtime artifacts and secret zip files.
5. Updated scripts and docs to new paths.

## Risk controls used
- Migration done on branch `refactor/repo-layout-v1`.
- File moves done with `git mv` to preserve history.
- Solution updated with `dotnet sln` to avoid manual sln corruption.
- Path validation done with `rg` and `docker compose config`.

## Validation checklist
1. `dotnet build backend/FitCity.sln`
2. `dotnet test backend/tests/FitCity.Application.Tests/FitCity.Application.Tests.csproj`
3. `docker compose -f infra/docker/docker-compose.yml config`
4. `powershell -ExecutionPolicy Bypass -File infra/scripts/build_desktop.ps1 -Configuration release`
5. `powershell -ExecutionPolicy Bypass -File infra/scripts/build_apk.ps1`
