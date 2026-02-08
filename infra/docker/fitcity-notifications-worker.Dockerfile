FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["FitCity.Notifications.Api/FitCity.Notifications.Api.csproj", "FitCity.Notifications.Api/"]
RUN dotnet restore "FitCity.Notifications.Api/FitCity.Notifications.Api.csproj"
COPY . .
WORKDIR /src/FitCity.Notifications.Api
RUN dotnet publish "FitCity.Notifications.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "FitCity.Notifications.Api.dll"]
