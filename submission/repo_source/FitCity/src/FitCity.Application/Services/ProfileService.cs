using System;
using FitCity.Application.DTOs;
using FitCity.Application.Interfaces;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Application.Services;

public class ProfileService : IProfileService
{
    private readonly FitCityDbContext _dbContext;

    public ProfileService(FitCityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<CurrentUserResponse> UpdateProfileAsync(
        Guid userId,
        ProfileUpdateRequest request,
        CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (user is null)
        {
            throw new InvalidOperationException("User not found.");
        }

        if (!string.IsNullOrWhiteSpace(request.Email) && !string.Equals(user.Email, request.Email, StringComparison.OrdinalIgnoreCase))
        {
            var emailExists = await _dbContext.Users
                .AsNoTracking()
                .AnyAsync(u => u.Email == request.Email, cancellationToken);
            if (emailExists)
            {
                throw new InvalidOperationException("Email already exists.");
            }
            user.Email = request.Email;
        }

        user.FullName = request.FullName;
        user.PhoneNumber = request.PhoneNumber;

        await _dbContext.SaveChangesAsync(cancellationToken);

        return new CurrentUserResponse
        {
            Id = user.Id,
            Email = user.Email,
            FullName = user.FullName,
            PhoneNumber = user.PhoneNumber,
            PhotoUrl = user.PhotoUrl,
            Role = user.Role.ToString()
        };
    }

    public async Task<CurrentUserResponse> UpdateProfilePhotoAsync(
        Guid userId,
        string photoUrl,
        CancellationToken cancellationToken)
    {
        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);
        if (user is null)
        {
            throw new InvalidOperationException("User not found.");
        }

        user.PhotoUrl = photoUrl;
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new CurrentUserResponse
        {
            Id = user.Id,
            Email = user.Email,
            FullName = user.FullName,
            PhoneNumber = user.PhoneNumber,
            PhotoUrl = user.PhotoUrl,
            Role = user.Role.ToString()
        };
    }
}
