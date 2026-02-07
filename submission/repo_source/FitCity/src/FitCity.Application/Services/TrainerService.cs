using FitCity.Application.DTOs;
using FitCity.Application.Exceptions;
using FitCity.Application.Interfaces;
using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using FitCity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using FitCity.Application.Security;

namespace FitCity.Application.Services;

public class TrainerService : ITrainerService
{
    private readonly FitCityDbContext _dbContext;
    private readonly IAppSettingsService _appSettingsService;

    public TrainerService(FitCityDbContext dbContext, IAppSettingsService appSettingsService)
    {
        _dbContext = dbContext;
        _appSettingsService = appSettingsService;
    }

    public async Task<TrainerDto> CreateAsync(TrainerCreateRequest request, CancellationToken cancellationToken)
    {
        var settings = await _appSettingsService.GetAsync(cancellationToken);
        if (!settings.AllowTrainerCreation)
        {
            throw new UserException("Adding new trainers is currently disabled.");
        }

        if (!request.HourlyRate.HasValue || request.HourlyRate.Value <= 0)
        {
            throw new InvalidOperationException("Hourly rate is required.");
        }

        var user = await _dbContext.Users.FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken);
        if (user is null)
        {
            throw new InvalidOperationException("User not found.");
        }

        var trainer = new Trainer
        {
            Id = Guid.NewGuid(),
            UserId = request.UserId,
            Bio = request.Bio,
            Certifications = request.Certifications,
            PhotoUrl = request.PhotoUrl,
            HourlyRate = request.HourlyRate.Value,
            Specialties = request.Specialties.ToList(),
            Styles = request.Styles.ToList(),
            SupportedFitnessLevels = request.SupportedFitnessLevels.ToList(),
            IsActive = true
        };

        _dbContext.Trainers.Add(trainer);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new TrainerDto
        {
            Id = trainer.Id,
            UserId = trainer.UserId,
            Bio = trainer.Bio,
            Certifications = trainer.Certifications,
            PhotoUrl = trainer.PhotoUrl,
            HourlyRate = trainer.HourlyRate,
            Specialties = trainer.Specialties.ToList(),
            Styles = trainer.Styles.ToList(),
            SupportedFitnessLevels = trainer.SupportedFitnessLevels.ToList(),
            IsActive = trainer.IsActive,
            UserName = user.FullName
        };
    }

    public async Task<TrainerDto> CreateForGymAdminAsync(
        Guid adminUserId,
        GymAdminTrainerCreateRequest request,
        CancellationToken cancellationToken)
    {
        var settings = await _appSettingsService.GetAsync(cancellationToken);
        if (!settings.AllowTrainerCreation)
        {
            throw new UserException("Adding new trainers is currently disabled.");
        }

        if (!request.HourlyRate.HasValue || request.HourlyRate.Value <= 0)
        {
            throw new InvalidOperationException("Hourly rate is required.");
        }

        var gymId = await GetGymIdForAdminAsync(adminUserId, cancellationToken);

        var exists = await _dbContext.Users.AnyAsync(u => u.Email == request.Email, cancellationToken);
        if (exists)
        {
            throw new InvalidOperationException("Email already exists.");
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = request.Email,
            FullName = request.FullName,
            PasswordHash = PasswordHasher.Hash(request.Password),
            Role = UserRole.Trainer,
            CreatedAtUtc = DateTime.UtcNow
        };

        var trainer = new Trainer
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            Bio = request.Bio,
            PhotoUrl = request.PhotoUrl,
            HourlyRate = request.HourlyRate.Value,
            IsActive = true
        };

        var link = new GymTrainer
        {
            GymId = gymId,
            TrainerId = trainer.Id
        };

        _dbContext.Users.Add(user);
        _dbContext.Trainers.Add(trainer);
        _dbContext.GymTrainers.Add(link);
        await _dbContext.SaveChangesAsync(cancellationToken);

        return new TrainerDto
        {
            Id = trainer.Id,
            UserId = trainer.UserId,
            Bio = trainer.Bio,
            Certifications = trainer.Certifications,
            PhotoUrl = trainer.PhotoUrl,
            HourlyRate = trainer.HourlyRate,
            Specialties = trainer.Specialties.ToList(),
            Styles = trainer.Styles.ToList(),
            SupportedFitnessLevels = trainer.SupportedFitnessLevels.ToList(),
            IsActive = trainer.IsActive,
            UserName = user.FullName
        };
    }

    public async Task<IReadOnlyList<TrainerDto>> GetAllAsync(
        string? search,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        IQueryable<Trainer> query;

        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            query = _dbContext.GymTrainers
                .AsNoTracking()
                .Where(gt => gt.GymId == gymId)
                .Include(gt => gt.Trainer)
                    .ThenInclude(t => t.User)
                .Select(gt => gt.Trainer)
                .AsQueryable();
        }
        else if (string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            query = _dbContext.Trainers
                .AsNoTracking()
                .Include(t => t.User)
                .AsQueryable();
        }
        else
        {
            throw new InvalidOperationException("Only administrators can access trainers.");
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(t =>
                t.User.FullName.ToLower().Contains(term) ||
                (t.Certifications != null && t.Certifications.ToLower().Contains(term)) ||
                (t.Bio != null && t.Bio.ToLower().Contains(term)));
        }

        var trainers = await query.ToListAsync(cancellationToken);
        return trainers.Select(t => new TrainerDto
        {
            Id = t.Id,
            UserId = t.UserId,
            Bio = t.Bio,
            Certifications = t.Certifications,
            PhotoUrl = t.PhotoUrl,
            HourlyRate = t.HourlyRate,
            Specialties = t.Specialties.ToList(),
            Styles = t.Styles.ToList(),
            SupportedFitnessLevels = t.SupportedFitnessLevels.ToList(),
            IsActive = t.IsActive,
            UserName = t.User.FullName
        }).ToList();
    }

    public async Task<IReadOnlyList<TrainerDto>> GetByGymAsync(Guid gymId, CancellationToken cancellationToken)
    {
        var trainers = await _dbContext.GymTrainers
            .AsNoTracking()
            .Where(gt => gt.GymId == gymId)
            .Include(gt => gt.Trainer)
                .ThenInclude(t => t.User)
            .Select(gt => gt.Trainer)
            .ToListAsync(cancellationToken);

        return trainers.Select(t => new TrainerDto
        {
            Id = t.Id,
            UserId = t.UserId,
            Bio = t.Bio,
            Certifications = t.Certifications,
            PhotoUrl = t.PhotoUrl,
            HourlyRate = t.HourlyRate,
            Specialties = t.Specialties.ToList(),
            Styles = t.Styles.ToList(),
            SupportedFitnessLevels = t.SupportedFitnessLevels.ToList(),
            IsActive = t.IsActive,
            UserName = t.User.FullName
        }).ToList();
    }

    public async Task<TrainerDto?> GetByIdAsync(Guid trainerId, CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == trainerId, cancellationToken);

        return trainer is null
            ? null
            : new TrainerDto
            {
                Id = trainer.Id,
                UserId = trainer.UserId,
                Bio = trainer.Bio,
                Certifications = trainer.Certifications,
                PhotoUrl = trainer.PhotoUrl,
                HourlyRate = trainer.HourlyRate,
                Specialties = trainer.Specialties.ToList(),
                Styles = trainer.Styles.ToList(),
                SupportedFitnessLevels = trainer.SupportedFitnessLevels.ToList(),
                IsActive = trainer.IsActive,
                UserName = trainer.User.FullName
            };
    }

    public async Task<TrainerDto?> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.UserId == userId, cancellationToken);

        return trainer is null
            ? null
            : new TrainerDto
            {
                Id = trainer.Id,
                UserId = trainer.UserId,
                Bio = trainer.Bio,
                Certifications = trainer.Certifications,
                PhotoUrl = trainer.PhotoUrl,
                HourlyRate = trainer.HourlyRate,
                Specialties = trainer.Specialties.ToList(),
                Styles = trainer.Styles.ToList(),
                SupportedFitnessLevels = trainer.SupportedFitnessLevels.ToList(),
                IsActive = trainer.IsActive,
                UserName = trainer.User.FullName
            };
    }

    public async Task<TrainerDetailDto?> GetDetailAsync(
        Guid trainerId,
        Guid requesterId,
        string requesterRole,
        CancellationToken cancellationToken)
    {
        if (string.Equals(requesterRole, UserRole.GymAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            var gymId = await GetGymIdForAdminAsync(requesterId, cancellationToken);
            var inGym = await _dbContext.GymTrainers
                .AsNoTracking()
                .AnyAsync(gt => gt.TrainerId == trainerId && gt.GymId == gymId, cancellationToken);
            if (!inGym)
            {
                throw new InvalidOperationException("Gym administrator access is limited to their assigned gym.");
            }
        }
        else if (!string.Equals(requesterRole, UserRole.CentralAdministrator.ToString(), StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Only administrators can access trainer details.");
        }

        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == trainerId, cancellationToken);

        if (trainer is null)
        {
            return null;
        }

        var gyms = await _dbContext.GymTrainers
            .AsNoTracking()
            .Include(gt => gt.Gym)
                .ThenInclude(g => g.Photos)
            .Where(gt => gt.TrainerId == trainerId && gt.Gym != null)
            .Select(gt => gt.Gym!)
            .ToListAsync(cancellationToken);

        var schedules = await _dbContext.TrainerSchedules
            .AsNoTracking()
            .Where(s => s.TrainerId == trainerId)
            .OrderBy(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        var sessions = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => s.TrainerId == trainerId)
            .OrderByDescending(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        return new TrainerDetailDto
        {
            Trainer = new TrainerDto
            {
                Id = trainer.Id,
                UserId = trainer.UserId,
                Bio = trainer.Bio,
                Certifications = trainer.Certifications,
                PhotoUrl = trainer.PhotoUrl,
                HourlyRate = trainer.HourlyRate,
                Specialties = trainer.Specialties?.ToList() ?? new List<TrainerSpecialty>(),
                Styles = trainer.Styles?.ToList() ?? new List<TrainerStyle>(),
                SupportedFitnessLevels = trainer.SupportedFitnessLevels?.ToList() ?? new List<FitnessLevel>(),
                IsActive = trainer.IsActive,
                UserName = trainer.User?.FullName ?? string.Empty
            },
            Gyms = gyms.Select(g => new GymDto
            {
                Id = g.Id,
                Name = g.Name,
                Address = g.Address,
                City = g.City,
                Latitude = g.Latitude,
                Longitude = g.Longitude,
                PhoneNumber = g.PhoneNumber,
                Description = g.Description,
                PhotoUrl = g.PhotoUrl,
                WorkHours = g.WorkHours,
                PhotoUrls = (g.Photos ?? new List<GymPhoto>())
                    .Where(p => p != null)
                    .OrderBy(p => p.SortOrder)
                    .Select(p => p.Url)
                    .ToList(),
                IsActive = g.IsActive
            }).ToList(),
            Schedules = schedules.Select(s => new TrainerScheduleDto
            {
                Id = s.Id,
                TrainerId = s.TrainerId,
                GymId = s.GymId,
                StartUtc = s.StartUtc,
                EndUtc = s.EndUtc,
                IsAvailable = s.IsAvailable
            }).ToList(),
            Sessions = sessions.Select(s => new BookingDto
            {
                Id = s.Id,
                UserId = s.UserId,
                TrainerId = s.TrainerId,
                TrainerUserId = trainer.UserId,
                TrainerName = trainer.User?.FullName ?? string.Empty,
                GymId = s.GymId,
                StartUtc = s.StartUtc,
                EndUtc = s.EndUtc,
                Status = s.Status.ToString(),
                PaymentMethod = s.PaymentMethod.ToString(),
                PaymentStatus = s.PaymentStatus.ToString(),
                Price = s.Price,
                PaidAtUtc = s.PaidAtUtc
            }).ToList()
        };
    }

    public async Task<TrainerDetailDto?> GetPublicDetailAsync(Guid trainerId, CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == trainerId, cancellationToken);

        if (trainer is null)
        {
            return null;
        }

        var gyms = await _dbContext.GymTrainers
            .AsNoTracking()
            .Include(gt => gt.Gym)
                .ThenInclude(g => g.Photos)
            .Where(gt => gt.TrainerId == trainerId && gt.Gym != null)
            .Select(gt => gt.Gym!)
            .ToListAsync(cancellationToken);

        var schedules = await _dbContext.TrainerSchedules
            .AsNoTracking()
            .Where(s => s.TrainerId == trainerId)
            .OrderBy(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        return new TrainerDetailDto
        {
            Trainer = new TrainerDto
            {
                Id = trainer.Id,
                UserId = trainer.UserId,
                Bio = trainer.Bio,
                Certifications = trainer.Certifications,
                PhotoUrl = trainer.PhotoUrl,
                HourlyRate = trainer.HourlyRate,
                Specialties = trainer.Specialties?.ToList() ?? new List<TrainerSpecialty>(),
                Styles = trainer.Styles?.ToList() ?? new List<TrainerStyle>(),
                SupportedFitnessLevels = trainer.SupportedFitnessLevels?.ToList() ?? new List<FitnessLevel>(),
                IsActive = trainer.IsActive,
                UserName = trainer.User?.FullName ?? string.Empty
            },
            Gyms = gyms.Select(g => new GymDto
            {
                Id = g.Id,
                Name = g.Name,
                Address = g.Address,
                City = g.City,
                Latitude = g.Latitude,
                Longitude = g.Longitude,
                PhoneNumber = g.PhoneNumber,
                Description = g.Description,
                PhotoUrl = g.PhotoUrl,
                WorkHours = g.WorkHours,
                PhotoUrls = (g.Photos ?? new List<GymPhoto>())
                    .Where(p => p != null)
                    .OrderBy(p => p.SortOrder)
                    .Select(p => p.Url)
                    .ToList(),
                IsActive = g.IsActive
            }).ToList(),
            Schedules = schedules.Select(s => new TrainerScheduleDto
            {
                Id = s.Id,
                TrainerId = s.TrainerId,
                GymId = s.GymId,
                StartUtc = s.StartUtc,
                EndUtc = s.EndUtc,
                IsAvailable = s.IsAvailable
            }).ToList()
        };
    }

    public async Task<TrainerScheduleResponseDto> GetAvailabilityAsync(
        Guid trainerId,
        DateTime fromUtc,
        DateTime toUtc,
        CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.Id == trainerId, cancellationToken);

        var schedules = await _dbContext.TrainerSchedules
            .AsNoTracking()
            .Where(s => s.TrainerId == trainerId && s.StartUtc >= fromUtc && s.EndUtc <= toUtc)
            .OrderBy(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        var sessions = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => s.TrainerId == trainerId
                        && s.StartUtc < toUtc
                        && s.EndUtc > fromUtc
                        && s.Status != TrainingSessionStatus.Cancelled)
            .OrderBy(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        var sessionRanges = sessions
            .Select(s => (StartUtc: s.StartUtc, EndUtc: s.EndUtc))
            .ToList();

        var scheduleUsed = schedules.Count > 0 ? "configured" : "default";
        var scheduleDtos = schedules.Count > 0
            ? schedules.Select(s => new TrainerScheduleDto
                {
                    Id = s.Id,
                    TrainerId = s.TrainerId,
                    GymId = s.GymId,
                    StartUtc = s.StartUtc,
                    EndUtc = s.EndUtc,
                    IsAvailable = s.IsAvailable && !sessionRanges.Any(r => s.StartUtc < r.EndUtc && s.EndUtc > r.StartUtc)
                })
                .ToList()
            : BuildDefaultSchedule(trainerId, fromUtc, toUtc, sessionRanges);

        return new TrainerScheduleResponseDto
        {
            Schedules = scheduleDtos,
            Sessions = sessions.Select(s => new BookingDto
            {
                Id = s.Id,
                UserId = s.UserId,
                TrainerId = s.TrainerId,
                TrainerUserId = trainer?.UserId ?? Guid.Empty,
                TrainerName = trainer?.User.FullName ?? string.Empty,
                GymId = s.GymId,
                StartUtc = s.StartUtc,
                EndUtc = s.EndUtc,
                Status = s.Status.ToString(),
                PaymentMethod = s.PaymentMethod.ToString(),
                PaymentStatus = s.PaymentStatus.ToString(),
                Price = s.Price,
                PaidAtUtc = s.PaidAtUtc
            }).ToList(),
            Reason = scheduleDtos.Count == 0 ? "No slots available in the selected range." : null,
            ScheduleUsed = scheduleUsed
        };
    }

    private static List<TrainerScheduleDto> BuildDefaultSchedule(
        Guid trainerId,
        DateTime fromUtc,
        DateTime toUtc,
        List<(DateTime StartUtc, DateTime EndUtc)> sessionRanges)
    {
        var slots = new List<TrainerScheduleDto>();
        var day = fromUtc.Date;
        var lastDay = toUtc.Date;

        while (day <= lastDay)
        {
            if (day.DayOfWeek != DayOfWeek.Sunday)
            {
                for (var hour = 8; hour < 16; hour++)
                {
                    var startUtc = day.AddHours(hour);
                    var endUtc = startUtc.AddHours(1);

                    if (startUtc < fromUtc || endUtc > toUtc)
                    {
                        continue;
                    }

                    var overlaps = sessionRanges.Any(r => startUtc < r.EndUtc && endUtc > r.StartUtc);
                    if (overlaps)
                    {
                        continue;
                    }

                    slots.Add(new TrainerScheduleDto
                    {
                        Id = Guid.Empty,
                        TrainerId = trainerId,
                        GymId = null,
                        StartUtc = startUtc,
                        EndUtc = endUtc,
                        IsAvailable = true
                    });
                }
            }

            day = day.AddDays(1);
        }

        return slots;
    }

    public async Task<TrainerScheduleResponseDto> GetMyScheduleAsync(Guid userId, CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .AsNoTracking()
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.UserId == userId, cancellationToken);
        if (trainer is null)
        {
            throw new InvalidOperationException("Trainer profile not found.");
        }

        var schedules = await _dbContext.TrainerSchedules
            .AsNoTracking()
            .Where(s => s.TrainerId == trainer.Id)
            .OrderBy(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        var sessions = await _dbContext.TrainingSessions
            .AsNoTracking()
            .Where(s => s.TrainerId == trainer.Id)
            .OrderBy(s => s.StartUtc)
            .ToListAsync(cancellationToken);

        return new TrainerScheduleResponseDto
        {
            Schedules = schedules.Select(s => new TrainerScheduleDto
            {
                Id = s.Id,
                TrainerId = s.TrainerId,
                GymId = s.GymId,
                StartUtc = s.StartUtc,
                EndUtc = s.EndUtc,
                IsAvailable = s.IsAvailable
            }).ToList(),
            Sessions = sessions.Select(s => new BookingDto
            {
                Id = s.Id,
                UserId = s.UserId,
                TrainerId = s.TrainerId,
                TrainerUserId = trainer.UserId,
                TrainerName = trainer.User?.FullName ?? string.Empty,
                GymId = s.GymId,
                StartUtc = s.StartUtc,
                EndUtc = s.EndUtc,
                Status = s.Status.ToString(),
                PaymentMethod = s.PaymentMethod.ToString(),
                PaymentStatus = s.PaymentStatus.ToString(),
                Price = s.Price,
                PaidAtUtc = s.PaidAtUtc
            }).ToList()
        };
    }

    private async Task<Guid> GetGymIdForAdminAsync(Guid adminUserId, CancellationToken cancellationToken)
    {
        var admin = await _dbContext.GymAdministrators
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.UserId == adminUserId, cancellationToken);

        if (admin is null)
        {
            throw new InvalidOperationException("Gym administrator is not assigned to a gym.");
        }

        return admin.GymId;
    }
}
