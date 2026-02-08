using FitCity.Domain.Entities;

namespace FitCity.Application.Interfaces;

public interface IJwtTokenService
{
    string CreateToken(User user, DateTime expiresAtUtc);
}
