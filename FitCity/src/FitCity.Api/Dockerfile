FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["FitCity.Api/FitCity.Api.csproj", "FitCity.Api/"]
COPY ["FitCity.Application/FitCity.Application.csproj", "FitCity.Application/"]
COPY ["FitCity.Infrastructure/FitCity.Infrastructure.csproj", "FitCity.Infrastructure/"]
COPY ["FitCity.Domain/FitCity.Domain.csproj", "FitCity.Domain/"]
RUN dotnet restore "FitCity.Api/FitCity.Api.csproj"
COPY . .
WORKDIR /src/FitCity.Api
RUN dotnet publish "FitCity.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "FitCity.Api.dll"]
