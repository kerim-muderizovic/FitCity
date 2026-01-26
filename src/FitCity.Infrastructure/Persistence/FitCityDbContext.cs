using FitCity.Domain.Entities;
using FitCity.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace FitCity.Infrastructure.Persistence;

public class FitCityDbContext : DbContext
{
    public FitCityDbContext(DbContextOptions<FitCityDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Gym> Gyms => Set<Gym>();
    public DbSet<GymPhoto> GymPhotos => Set<GymPhoto>();
    public DbSet<Trainer> Trainers => Set<Trainer>();
    public DbSet<GymAdministrator> GymAdministrators => Set<GymAdministrator>();
    public DbSet<CentralAdministrator> CentralAdministrators => Set<CentralAdministrator>();
    public DbSet<GymPlan> GymPlans => Set<GymPlan>();
    public DbSet<MembershipRequest> MembershipRequests => Set<MembershipRequest>();
    public DbSet<Membership> Memberships => Set<Membership>();
    public DbSet<QRCode> QRCodes => Set<QRCode>();
    public DbSet<CheckInLog> CheckInLogs => Set<CheckInLog>();
    public DbSet<TrainerSchedule> TrainerSchedules => Set<TrainerSchedule>();
    public DbSet<TrainingSession> TrainingSessions => Set<TrainingSession>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<UserTrainerInteraction> UserTrainerInteractions => Set<UserTrainerInteraction>();
    public DbSet<Preference> Preferences => Set<Preference>();
    public DbSet<Conversation> Conversations => Set<Conversation>();
    public DbSet<ConversationParticipant> ConversationParticipants => Set<ConversationParticipant>();
    public DbSet<Message> Messages => Set<Message>();
    public DbSet<GymTrainer> GymTrainers => Set<GymTrainer>();
    public DbSet<Notification> Notifications => Set<Notification>();

    public override int SaveChanges()
    {
        ValidateAdminRoleAssignments();
        return base.SaveChanges();
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        ValidateAdminRoleAssignments();
        return base.SaveChangesAsync(cancellationToken);
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<User>(builder =>
        {
            builder.HasKey(u => u.Id);
            builder.Property(u => u.Email).HasMaxLength(200).IsRequired();
            builder.Property(u => u.FullName).HasMaxLength(200).IsRequired();
            builder.Property(u => u.PasswordHash).HasMaxLength(300).IsRequired();
            builder.Property(u => u.PhoneNumber).HasMaxLength(40);
            builder.Property(u => u.Role).HasConversion<int>();
            builder.HasIndex(u => u.Email).IsUnique();
            builder.HasOne(u => u.Preference)
                .WithOne(p => p.User)
                .HasForeignKey<Preference>(p => p.UserId);
            builder.HasOne(u => u.TrainerProfile)
                .WithOne(t => t.User)
                .HasForeignKey<Trainer>(t => t.UserId);
            builder.HasOne(u => u.GymAdministratorProfile)
                .WithOne(a => a.User)
                .HasForeignKey<GymAdministrator>(a => a.UserId);
            builder.HasOne(u => u.CentralAdministratorProfile)
                .WithOne(a => a.User)
                .HasForeignKey<CentralAdministrator>(a => a.UserId);
        });

        modelBuilder.Entity<Gym>(builder =>
        {
            builder.HasKey(g => g.Id);
            builder.Property(g => g.Name).HasMaxLength(200).IsRequired();
            builder.Property(g => g.Address).HasMaxLength(200).IsRequired();
            builder.Property(g => g.City).HasMaxLength(100).IsRequired();
            builder.Property(g => g.Latitude);
            builder.Property(g => g.Longitude);
            builder.Property(g => g.PhoneNumber).HasMaxLength(40);
            builder.Property(g => g.Description).HasMaxLength(1000);
            builder.Property(g => g.PhotoUrl).HasMaxLength(500);
            builder.Property(g => g.WorkHours).HasMaxLength(200);
        });

        modelBuilder.Entity<GymPhoto>(builder =>
        {
            builder.HasKey(p => p.Id);
            builder.Property(p => p.Url).HasMaxLength(500).IsRequired();
            builder.HasIndex(p => new { p.GymId, p.SortOrder }).IsUnique();
            builder.HasOne(p => p.Gym)
                .WithMany(g => g.Photos)
                .HasForeignKey(p => p.GymId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Trainer>(builder =>
        {
            builder.HasKey(t => t.Id);
            builder.Property(t => t.Bio).HasMaxLength(1000);
            builder.Property(t => t.Certifications).HasMaxLength(500);
            builder.Property(t => t.PhotoUrl).HasMaxLength(500);
            builder.Property(t => t.HourlyRate).HasColumnType("decimal(18,2)");
            builder.Property(t => t.Specialties)
                .HasConversion(CreateEnumListConverter<TrainerSpecialty>())
                .HasMaxLength(500);
            builder.Property(t => t.Styles)
                .HasConversion(CreateEnumListConverter<TrainerStyle>())
                .HasMaxLength(300);
            builder.Property(t => t.SupportedFitnessLevels)
                .HasConversion(CreateEnumListConverter<FitnessLevel>())
                .HasMaxLength(120);
            builder.HasIndex(t => t.UserId).IsUnique();
        });

        modelBuilder.Entity<GymAdministrator>(builder =>
        {
            builder.HasKey(a => a.Id);
            builder.HasIndex(a => a.UserId).IsUnique();
            builder.HasIndex(a => new { a.GymId, a.UserId }).IsUnique();
            builder.HasOne(a => a.Gym)
                .WithMany(g => g.Administrators)
                .HasForeignKey(a => a.GymId);
        });

        modelBuilder.Entity<CentralAdministrator>(builder =>
        {
            builder.HasKey(a => a.Id);
            builder.HasIndex(a => a.UserId).IsUnique();
        });

        modelBuilder.Entity<GymPlan>(builder =>
        {
            builder.HasKey(p => p.Id);
            builder.Property(p => p.Name).HasMaxLength(150).IsRequired();
            builder.Property(p => p.Price).HasColumnType("decimal(18,2)");
            builder.Property(p => p.Description).HasMaxLength(1000);
            builder.HasOne(p => p.Gym)
                .WithMany(g => g.Plans)
                .HasForeignKey(p => p.GymId);
        });

        modelBuilder.Entity<MembershipRequest>(builder =>
        {
            builder.HasKey(m => m.Id);
            builder.Property(m => m.Status).HasConversion<int>();
            builder.Property(m => m.PaymentStatus).HasConversion<int>();
            builder.HasIndex(m => new { m.UserId, m.GymId });
            builder.HasOne(m => m.Gym)
                .WithMany(g => g.MembershipRequests)
                .HasForeignKey(m => m.GymId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(m => m.User)
                .WithMany(u => u.MembershipRequests)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(m => m.GymPlan)
                .WithMany(p => p.MembershipRequests)
                .HasForeignKey(m => m.GymPlanId)
                .OnDelete(DeleteBehavior.SetNull);
            builder.HasCheckConstraint("CK_MembershipRequest_Status", $"[{nameof(MembershipRequest.Status)}] IN (1,2,3,4)");
            builder.HasCheckConstraint("CK_MembershipRequest_PaymentStatus", $"[{nameof(MembershipRequest.PaymentStatus)}] IN (1,2)");
        });

        modelBuilder.Entity<Membership>(builder =>
        {
            builder.HasKey(m => m.Id);
            builder.Property(m => m.Status).HasConversion<int>();
            builder.HasIndex(m => new { m.UserId, m.GymId });
            builder.HasOne(m => m.Gym)
                .WithMany(g => g.Memberships)
                .HasForeignKey(m => m.GymId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(m => m.User)
                .WithMany(u => u.Memberships)
                .HasForeignKey(m => m.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(m => m.GymPlan)
                .WithMany(p => p.Memberships)
                .HasForeignKey(m => m.GymPlanId)
                .OnDelete(DeleteBehavior.SetNull);
            builder.HasOne(m => m.QRCode)
                .WithOne(q => q.Membership)
                .HasForeignKey<QRCode>(q => q.MembershipId);
            builder.HasCheckConstraint("CK_Membership_Status", $"[{nameof(Membership.Status)}] IN (1,2,3,4)");
        });

        modelBuilder.Entity<QRCode>(builder =>
        {
            builder.HasKey(q => q.Id);
            builder.Property(q => q.TokenHash).HasMaxLength(200).IsRequired();
            builder.HasIndex(q => q.MembershipId).IsUnique();
        });

        modelBuilder.Entity<CheckInLog>(builder =>
        {
            builder.HasKey(c => c.Id);
            builder.HasOne(c => c.Gym)
                .WithMany(g => g.CheckIns)
                .HasForeignKey(c => c.GymId);
            builder.HasOne(c => c.User)
                .WithMany(u => u.CheckIns)
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(c => c.ScannedByUser)
                .WithMany(u => u.ScannedCheckIns)
                .HasForeignKey(c => c.ScannedByUserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<TrainerSchedule>(builder =>
        {
            builder.HasKey(s => s.Id);
            builder.HasIndex(s => new { s.TrainerId, s.StartUtc, s.EndUtc });
            builder.HasOne(s => s.Gym)
                .WithMany(g => g.TrainerSchedules)
                .HasForeignKey(s => s.GymId)
                .OnDelete(DeleteBehavior.SetNull);
            builder.HasCheckConstraint("CK_TrainerSchedule_Time", $"[{nameof(TrainerSchedule.EndUtc)}] > [{nameof(TrainerSchedule.StartUtc)}]");
        });

        modelBuilder.Entity<TrainingSession>(builder =>
        {
            builder.HasKey(s => s.Id);
            builder.Property(s => s.Status).HasConversion<int>();
            builder.Property(s => s.PaymentMethod).HasConversion<int>();
            builder.Property(s => s.PaymentStatus).HasConversion<int>();
            builder.Property(s => s.Price).HasColumnType("decimal(18,2)");
            builder.HasIndex(s => new { s.TrainerId, s.StartUtc, s.EndUtc });
            builder.HasOne(s => s.Gym)
                .WithMany(g => g.TrainingSessions)
                .HasForeignKey(s => s.GymId)
                .OnDelete(DeleteBehavior.SetNull);
            builder.HasOne(s => s.User)
                .WithMany(u => u.TrainingSessions)
                .HasForeignKey(s => s.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasCheckConstraint("CK_TrainingSession_Status", $"[{nameof(TrainingSession.Status)}] IN (1,2,3,4)");
            builder.HasCheckConstraint("CK_TrainingSession_PaymentMethod", $"[{nameof(TrainingSession.PaymentMethod)}] IN (1,2,3,4)");
            builder.HasCheckConstraint("CK_TrainingSession_PaymentStatus", $"[{nameof(TrainingSession.PaymentStatus)}] IN (1,2)");
            builder.HasCheckConstraint("CK_TrainingSession_Time", $"[{nameof(TrainingSession.EndUtc)}] > [{nameof(TrainingSession.StartUtc)}]");
        });

        modelBuilder.Entity<Payment>(builder =>
        {
            builder.HasKey(p => p.Id);
            builder.Property(p => p.Method).HasConversion<int>();
            builder.Property(p => p.Amount).HasColumnType("decimal(18,2)");
            builder.HasCheckConstraint("CK_Payment_Method", $"[{nameof(Payment.Method)}] IN (1,2,3,4)");
            builder.HasCheckConstraint("CK_Payment_Target", "([MembershipId] IS NOT NULL AND [TrainingSessionId] IS NULL) OR ([MembershipId] IS NULL AND [TrainingSessionId] IS NOT NULL)");
        });

        modelBuilder.Entity<Review>(builder =>
        {
            builder.HasKey(r => r.Id);
            builder.Property(r => r.Comment).HasMaxLength(1000);
            builder.HasIndex(r => new { r.UserId, r.TrainerId, r.GymId }).IsUnique();
            builder.HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasCheckConstraint("CK_Review_Rating", $"[{nameof(Review.Rating)}] BETWEEN 1 AND 5");
        });

        modelBuilder.Entity<UserTrainerInteraction>(builder =>
        {
            builder.HasKey(i => i.Id);
            builder.Property(i => i.Type).HasConversion<int>();
            builder.HasIndex(i => new { i.UserId, i.TrainerId, i.Type });
            builder.HasOne(i => i.User)
                .WithMany()
                .HasForeignKey(i => i.UserId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(i => i.Trainer)
                .WithMany()
                .HasForeignKey(i => i.TrainerId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<Preference>(builder =>
        {
            builder.HasKey(p => p.Id);
            builder.Property(p => p.FitnessGoal).HasMaxLength(200);
            builder.Property(p => p.TrainingGoals)
                .HasConversion(CreateEnumListConverter<TrainingGoal>())
                .HasMaxLength(500);
            builder.Property(p => p.WorkoutTypes)
                .HasConversion(CreateEnumListConverter<WorkoutType>())
                .HasMaxLength(500);
            builder.Property(p => p.FitnessLevel).HasConversion<int?>();
            builder.Property(p => p.PreferredWorkoutTime).HasMaxLength(100);
            builder.Property(p => p.PreferredGymLocations).HasMaxLength(300);
            builder.Property(p => p.PreferredLatitude);
            builder.Property(p => p.PreferredLongitude);
            builder.HasIndex(p => p.UserId).IsUnique();
        });

        modelBuilder.Entity<Conversation>(builder =>
        {
            builder.HasKey(c => c.Id);
            builder.Property(c => c.Title).HasMaxLength(200);
            builder.HasIndex(c => new { c.MemberId, c.TrainerId }).IsUnique();
            builder.HasOne(c => c.Member)
                .WithMany()
                .HasForeignKey(c => c.MemberId)
                .OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(c => c.Trainer)
                .WithMany()
                .HasForeignKey(c => c.TrainerId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<ConversationParticipant>(builder =>
        {
            builder.HasKey(p => p.Id);
            builder.HasIndex(p => new { p.ConversationId, p.UserId }).IsUnique();
        });

        modelBuilder.Entity<Message>(builder =>
        {
            builder.HasKey(m => m.Id);
            builder.Property(m => m.Content).HasMaxLength(2000).IsRequired();
            builder.Property(m => m.SenderRole).HasMaxLength(50).IsRequired();
            builder.HasOne(m => m.SenderUser)
                .WithMany(u => u.Messages)
                .HasForeignKey(m => m.SenderUserId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<GymTrainer>(builder =>
        {
            builder.HasKey(gt => new { gt.GymId, gt.TrainerId });
            builder.HasOne(gt => gt.Gym)
                .WithMany(g => g.GymTrainers)
                .HasForeignKey(gt => gt.GymId);
            builder.HasOne(gt => gt.Trainer)
                .WithMany(t => t.GymTrainers)
                .HasForeignKey(gt => gt.TrainerId);
        });

        modelBuilder.Entity<Notification>(builder =>
        {
            builder.HasKey(n => n.Id);
            builder.Property(n => n.Title).HasMaxLength(200).IsRequired();
            builder.Property(n => n.Message).HasMaxLength(2000).IsRequired();
            builder.Property(n => n.Category).HasMaxLength(100);
            builder.HasIndex(n => new { n.UserId, n.CreatedAtUtc });
            builder.HasOne(n => n.User)
                .WithMany(u => u.Notifications)
                .HasForeignKey(n => n.UserId);
        });

        SeedData(modelBuilder);
    }

    private void ValidateAdminRoleAssignments()
    {
        var userEntries = ChangeTracker.Entries<User>()
            .Where(e => e.State is EntityState.Added or EntityState.Modified)
            .Select(e => e.Entity)
            .ToList();

        foreach (var user in userEntries)
        {
            if (user.Role == UserRole.GymAdministrator)
            {
                if (user.CentralAdministratorProfile != null || CentralAdministrators.Any(a => a.UserId == user.Id))
                {
                    throw new InvalidOperationException("A Gym Administrator account cannot also be a Central Administrator.");
                }
            }
            else if (user.Role == UserRole.CentralAdministrator)
            {
                if (user.GymAdministratorProfile != null || GymAdministrators.Any(a => a.UserId == user.Id))
                {
                    throw new InvalidOperationException("A Central Administrator account cannot also be a Gym Administrator.");
                }
            }
            else if (user.GymAdministratorProfile != null || user.CentralAdministratorProfile != null)
            {
                throw new InvalidOperationException("Non-admin accounts cannot be linked to admin profiles.");
            }
        }

        var gymAdminEntries = ChangeTracker.Entries<GymAdministrator>()
            .Where(e => e.State is EntityState.Added or EntityState.Modified)
            .Select(e => e.Entity)
            .ToList();

        var centralAdminEntries = ChangeTracker.Entries<CentralAdministrator>()
            .Where(e => e.State is EntityState.Added or EntityState.Modified)
            .Select(e => e.Entity)
            .ToList();

        foreach (var gymAdmin in gymAdminEntries)
        {
            var role = ResolveUserRole(gymAdmin.UserId);
            if (role != UserRole.GymAdministrator)
            {
                throw new InvalidOperationException("Gym Administrator profile requires a Gym Administrator user role.");
            }

            if (centralAdminEntries.Any(a => a.UserId == gymAdmin.UserId) || CentralAdministrators.Any(a => a.UserId == gymAdmin.UserId))
            {
                throw new InvalidOperationException("A user cannot be both Gym and Central Administrator.");
            }
        }

        foreach (var centralAdmin in centralAdminEntries)
        {
            var role = ResolveUserRole(centralAdmin.UserId);
            if (role != UserRole.CentralAdministrator)
            {
                throw new InvalidOperationException("Central Administrator profile requires a Central Administrator user role.");
            }

            if (gymAdminEntries.Any(a => a.UserId == centralAdmin.UserId) || GymAdministrators.Any(a => a.UserId == centralAdmin.UserId))
            {
                throw new InvalidOperationException("A user cannot be both Central and Gym Administrator.");
            }
        }
    }

    private UserRole ResolveUserRole(Guid userId)
    {
        var tracked = ChangeTracker.Entries<User>()
            .FirstOrDefault(e => e.Entity.Id == userId);
        if (tracked != null)
        {
            return tracked.Entity.Role;
        }

        return Users.AsNoTracking()
            .Where(u => u.Id == userId)
            .Select(u => u.Role)
            .FirstOrDefault();
    }

    private static ValueConverter<List<TEnum>, string> CreateEnumListConverter<TEnum>() where TEnum : struct, Enum
    {
        return new ValueConverter<List<TEnum>, string>(
            value => value.Count == 0 ? string.Empty : string.Join(',', value),
            value => ParseEnumList<TEnum>(value));
    }

    private static List<TEnum> ParseEnumList<TEnum>(string value) where TEnum : struct, Enum
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return new List<TEnum>();
        }

        var items = value.Split(',', StringSplitOptions.RemoveEmptyEntries);
        var result = new List<TEnum>(items.Length);
        foreach (var item in items)
        {
            if (Enum.TryParse(item, out TEnum parsed))
            {
                result.Add(parsed);
            }
        }

        return result;
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        var seedNow = new DateTime(2025, 1, 1, 8, 0, 0, DateTimeKind.Utc);
        var userCentral = Guid.Parse("11111111-1111-1111-1111-111111111111");
        var userGymAdmin1 = Guid.Parse("22222222-2222-2222-2222-222222222222");
        var userGymAdmin2 = Guid.Parse("22222222-2222-2222-2222-222222222223");
        var userGymAdmin3 = Guid.Parse("22222222-2222-2222-2222-222222222224");
        var userGymAdmin4 = Guid.Parse("22222222-2222-2222-2222-222222222225");
        var userTrainer1 = Guid.Parse("33333333-3333-3333-3333-333333333333");
        var userTrainer2 = Guid.Parse("33333333-3333-3333-3333-333333333334");
        var userTrainer3 = Guid.Parse("33333333-3333-3333-3333-333333333335");
        var userTrainer4 = Guid.Parse("33333333-3333-3333-3333-333333333336");
        var userTrainer5 = Guid.Parse("33333333-3333-3333-3333-333333333337");
        var userTrainer6 = Guid.Parse("33333333-3333-3333-3333-333333333338");
        var userMember1 = Guid.Parse("55555555-5555-5555-5555-555555555555");
        var userMember2 = Guid.Parse("66666666-6666-6666-6666-666666666666");
        var userMember3 = Guid.Parse("77777777-7777-7777-7777-777777777777");
        var userMember4 = Guid.Parse("88888888-8888-8888-8888-888888888888");
        var userMember5 = Guid.Parse("99999999-9999-9999-9999-999999999999");

        var preferenceMember1 = Guid.Parse("a0a0a0a0-0000-0000-0000-000000000001");
        var preferenceMember2 = Guid.Parse("a0a0a0a0-0000-0000-0000-000000000002");
        var preferenceMember3 = Guid.Parse("a0a0a0a0-0000-0000-0000-000000000003");
        var preferenceMember4 = Guid.Parse("a0a0a0a0-0000-0000-0000-000000000004");
        var preferenceMember5 = Guid.Parse("a0a0a0a0-0000-0000-0000-000000000005");

        var interaction1 = Guid.Parse("b0b0b0b0-0000-0000-0000-000000000001");
        var interaction2 = Guid.Parse("b0b0b0b0-0000-0000-0000-000000000002");
        var interaction3 = Guid.Parse("b0b0b0b0-0000-0000-0000-000000000003");
        var interaction4 = Guid.Parse("b0b0b0b0-0000-0000-0000-000000000004");
        var interaction5 = Guid.Parse("b0b0b0b0-0000-0000-0000-000000000005");
        var interaction6 = Guid.Parse("b0b0b0b0-0000-0000-0000-000000000006");

        var gym1 = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
        var gym2 = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");
        var gym3 = Guid.Parse("12121212-1212-1212-1212-121212121212");
        var gym4 = Guid.Parse("13131313-1313-1313-1313-131313131313");
        var gymNovoSarajevo = Guid.Parse("14141414-1414-1414-1414-141414141414");
        var gymGrbavica = Guid.Parse("15151515-1515-1515-1515-151515151515");
        var gymBosna = Guid.Parse("16161616-1616-1616-1616-161616161616");
        var gymGrada = Guid.Parse("17171717-1717-1717-1717-171717171717");

        var trainer1 = Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc");
        var trainer2 = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddddd");
        var trainer3 = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee");
        var trainer4 = Guid.Parse("ffffffff-ffff-ffff-ffff-ffffffffffff");
        var trainer5 = Guid.Parse("01010101-0101-0101-0101-010101010101");
        var trainer6 = Guid.Parse("02020202-0202-0202-0202-020202020202");

        var centralAdmin = Guid.Parse("9a9a9a9a-9a9a-9a9a-9a9a-9a9a9a9a9a9a");
        var gymAdmin1 = Guid.Parse("9b9b9b9b-9b9b-9b9b-9b9b-9b9b9b9b9b9b");
        var gymAdmin2 = Guid.Parse("9c9c9c9c-9c9c-9c9c-9c9c-9c9c9c9c9c9c");
        var gymAdmin3 = Guid.Parse("9d9d9d9d-9d9d-9d9d-9d9d-9d9d9d9d9d9d");
        var gymAdmin4 = Guid.Parse("9e9e9e9e-9e9e-9e9e-9e9e-9e9e9e9e9e9e");
        var gymAdminNovo = Guid.Parse("9f9f9f9f-9f9f-9f9f-9f9f-9f9f9f9f9f9f");
        var gymAdminGrb = Guid.Parse("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1");
        var gymAdminBosna = Guid.Parse("a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2");
        var gymAdminGrada = Guid.Parse("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3");

        var userGymAdminNovo = Guid.Parse("22222222-2222-2222-2222-222222222226");
        var userGymAdminGrb = Guid.Parse("22222222-2222-2222-2222-222222222227");
        var userGymAdminBosna = Guid.Parse("22222222-2222-2222-2222-222222222228");
        var userGymAdminGrada = Guid.Parse("22222222-2222-2222-2222-222222222229");

        var plan1 = Guid.Parse("10101010-1010-1010-1010-101010101010");
        var plan2 = Guid.Parse("20202020-2020-2020-2020-202020202020");
        var plan3 = Guid.Parse("30303030-3030-3030-3030-303030303030");
        var plan4 = Guid.Parse("40404040-4040-4040-4040-404040404040");

        var membershipRequest = Guid.Parse("50505050-5050-5050-5050-505050505050");
        var membership = Guid.Parse("60606060-6060-6060-6060-606060606060");
        var qrCode = Guid.Parse("70707070-7070-7070-7070-707070707070");

        var schedule1 = Guid.Parse("80808080-8080-8080-8080-808080808080");
        var schedule2 = Guid.Parse("81818181-8181-8181-8181-818181818181");
        var schedule3 = Guid.Parse("82828282-8282-8282-8282-828282828282");
        var schedule4 = Guid.Parse("83838383-8383-8383-8383-838383838383");
        var schedule5 = Guid.Parse("84848484-8484-8484-8484-848484848484");
        var schedule6 = Guid.Parse("85858585-8585-8585-8585-858585858585");

        var session1 = Guid.Parse("90909090-9090-9090-9090-909090909090");
        var session2 = Guid.Parse("91919191-9191-9191-9191-919191919191");
        var payment1 = Guid.Parse("92929292-9292-9292-9292-929292929292");

        var review1 = Guid.Parse("93939393-9393-9393-9393-939393939393");
        var review2 = Guid.Parse("94949494-9494-9494-9494-949494949494");

        var conversation1 = Guid.Parse("95959595-9595-9595-9595-959595959595");
        var participant1 = Guid.Parse("96969696-9696-9696-9696-969696969696");
        var participant2 = Guid.Parse("97979797-9797-9797-9797-979797979797");
        var message1 = Guid.Parse("98989898-9898-9898-9898-989898989898");
        var conversation2 = Guid.Parse("a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4");
        var conversation3 = Guid.Parse("a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5");
        var participant3 = Guid.Parse("a6a6a6a6-a6a6-a6a6-a6a6-a6a6a6a6a6a6");
        var participant4 = Guid.Parse("a7a7a7a7-a7a7-a7a7-a7a7-a7a7a7a7a7a7");
        var participant5 = Guid.Parse("a8a8a8a8-a8a8-a8a8-a8a8-a8a8a8a8a8a8");
        var participant6 = Guid.Parse("a9a9a9a9-a9a9-a9a9-a9a9-a9a9a9a9a9a9");
        var message2 = Guid.Parse("b0b0b0b0-b0b0-b0b0-b0b0-b0b0b0b0b0b0");
        var message3 = Guid.Parse("b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1");
        var message4 = Guid.Parse("b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2");

        modelBuilder.Entity<User>().HasData(
            new User { Id = userCentral, Email = "central@fitcity.local", PasswordHash = "HASHED:central", FullName = "Central Admin", Role = UserRole.CentralAdministrator },
            new User { Id = userGymAdmin1, Email = "admin.downtown@fitcity.local", PasswordHash = "HASHED:gymadmin1", FullName = "Downtown Admin", Role = UserRole.GymAdministrator },
            new User { Id = userGymAdmin2, Email = "admin.ilidza@fitcity.local", PasswordHash = "HASHED:gymadmin2", FullName = "Ilidza Admin", Role = UserRole.GymAdministrator },
            new User { Id = userGymAdmin3, Email = "admin.bascarsija@fitcity.local", PasswordHash = "HASHED:gymadmin3", FullName = "Bascarsija Admin", Role = UserRole.GymAdministrator },
            new User { Id = userGymAdmin4, Email = "admin.grbavica@fitcity.local", PasswordHash = "HASHED:gymadmin4", FullName = "Grbavica Admin", Role = UserRole.GymAdministrator },
            new User { Id = userTrainer1, Email = "trainer1@gym.local", PasswordHash = "HASHED:trainer1pass", FullName = "Trainer Mustafa", Role = UserRole.Trainer },
            new User { Id = userTrainer2, Email = "trainer2@gym.local", PasswordHash = "HASHED:trainer2pass", FullName = "Trainer Halid", Role = UserRole.Trainer },
            new User { Id = userTrainer3, Email = "trainer3@gym.local", PasswordHash = "HASHED:trainer3pass", FullName = "Trainer Velid", Role = UserRole.Trainer },
            new User { Id = userTrainer4, Email = "trainer4@gym.local", PasswordHash = "HASHED:trainer4pass", FullName = "Trainer Edis", Role = UserRole.Trainer },
            new User { Id = userTrainer5, Email = "trainer5@gym.local", PasswordHash = "HASHED:trainer5pass", FullName = "Trainer Mahmut", Role = UserRole.Trainer },
            new User { Id = userTrainer6, Email = "trainer6@gym.local", PasswordHash = "HASHED:trainer6pass", FullName = "Trainer Elvis", Role = UserRole.Trainer },
            new User { Id = userGymAdminNovo, Email = "admin.novosarajevo@fitcity.local", PasswordHash = "HASHED:gymnovo1", FullName = "Novo Sarajevo Admin", Role = UserRole.GymAdministrator },
            new User { Id = userGymAdminGrb, Email = "admin.grbavica@fitcity.local", PasswordHash = "HASHED:gymgrb1", FullName = "Grbavica Admin", Role = UserRole.GymAdministrator },
            new User { Id = userGymAdminBosna, Email = "admin.bosna@fitcity.local", PasswordHash = "HASHED:gymbosna1", FullName = "Bosna Admin", Role = UserRole.GymAdministrator },
            new User { Id = userGymAdminGrada, Email = "admin.grada@fitcity.local", PasswordHash = "HASHED:gymgrada1", FullName = "Grada Admin", Role = UserRole.GymAdministrator },
            new User { Id = userMember1, Email = "user1@gym.local", PasswordHash = "HASHED:user1pass", FullName = "User One", Role = UserRole.User },
            new User { Id = userMember2, Email = "user2@gym.local", PasswordHash = "HASHED:user2pass", FullName = "User Two", Role = UserRole.User },
            new User { Id = userMember3, Email = "user3@gym.local", PasswordHash = "HASHED:user3pass", FullName = "User Three", Role = UserRole.User },
            new User { Id = userMember4, Email = "user4@gym.local", PasswordHash = "HASHED:user4pass", FullName = "User Four", Role = UserRole.User },
            new User { Id = userMember5, Email = "user5@gym.local", PasswordHash = "HASHED:user5pass", FullName = "User Five", Role = UserRole.User }
        );

        modelBuilder.Entity<Gym>().HasData(
            new Gym
            {
                Id = gym1,
                Name = "FitCity Downtown",
                Address = "Zmaja od Bosne 12",
                City = "Sarajevo",
                PhoneNumber = "033-100-100",
                Description = "Central location near Marijin Dvor.",
                PhotoUrl = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80",
                WorkHours = "06:00-22:00"
            },
            new Gym
            {
                Id = gym2,
                Name = "FitCity Ilidza",
                Address = "Hrasnicka Cesta 10",
                City = "Sarajevo",
                PhoneNumber = "033-200-200",
                Description = "Spacious gym with wellness zone.",
                PhotoUrl = "https://images.unsplash.com/photo-1554344728-77cf90d9ed26?auto=format&fit=crop&w=800&q=80",
                WorkHours = "06:00-23:00"
            },
            new Gym
            {
                Id = gym3,
                Name = "FitCity Bascarsija",
                Address = "Saraci 45",
                City = "Sarajevo",
                PhoneNumber = "033-300-300",
                Description = "Boutique studio in the old town.",
                PhotoUrl = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=800&q=80",
                WorkHours = "07:00-21:00"
            },
            new Gym
            {
                Id = gym4,
                Name = "FitCity Grbavica",
                Address = "Zvornička 1",
                City = "Sarajevo",
                Latitude = 43.8501,
                Longitude = 18.3958,
                PhoneNumber = "033-400-400",
                Description = "Neighborhood gym with boxing zone.",
                PhotoUrl = "https://images.unsplash.com/photo-1571019613914-85f342c55f42?auto=format&fit=crop&w=800&q=80",
                WorkHours = "06:30-22:30"
            },
            new Gym
            {
                Id = gymNovoSarajevo,
                Name = "GYM NOVO SARAJEVO",
                Address = "Zmaja od Bosne 45",
                City = "Sarajevo",
                Latitude = 43.8529,
                Longitude = 18.4012,
                PhoneNumber = "033-510-510",
                Description = "Modern gym with strength and cardio zones.",
                PhotoUrl = "https://images.unsplash.com/photo-1534367610401-9f5ed68180aa?auto=format&fit=crop&w=800&q=80",
                WorkHours = "Mon–Fri 06:00–22:30, Sat 08:00–20:00, Sun 10:00–18:00"
            },
            new Gym
            {
                Id = gymGrbavica,
                Name = "GYM GRBAVICA",
                Address = "Grbavicka 12",
                City = "Sarajevo",
                Latitude = 43.8513,
                Longitude = 18.4028,
                PhoneNumber = "033-520-520",
                Description = "Neighborhood gym with group classes.",
                PhotoUrl = "https://images.unsplash.com/photo-1574680096145-d05b474e2155?auto=format&fit=crop&w=800&q=80",
                WorkHours = "Mon–Fri 06:30–22:00, Sat 08:00–19:00, Sun 10:00–16:00"
            },
            new Gym
            {
                Id = gymBosna,
                Name = "GYM BOSNA",
                Address = "Marijin Dvor 5",
                City = "Sarajevo",
                Latitude = 43.8577,
                Longitude = 18.4127,
                PhoneNumber = "033-530-530",
                Description = "Fitness center with spa and recovery.",
                PhotoUrl = "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?auto=format&fit=crop&w=800&q=80",
                WorkHours = "Mon–Fri 05:30–23:00, Sat 07:00–21:00, Sun 09:00–19:00"
            },
            new Gym
            {
                Id = gymGrada,
                Name = "TERETANA GRADA",
                Address = "Bascarsija 3",
                City = "Sarajevo",
                Latitude = 43.8594,
                Longitude = 18.4302,
                PhoneNumber = "033-540-540",
                Description = "Old town gym with functional training.",
                PhotoUrl = "https://images.unsplash.com/photo-1593079831268-3381b0db4a77?auto=format&fit=crop&w=800&q=80",
                WorkHours = "Mon–Fri 07:00–21:00, Sat 08:00–18:00, Sun 10:00–16:00"
            }
        );

        modelBuilder.Entity<GymPhoto>().HasData(
            new GymPhoto { Id = Guid.Parse("18181818-1818-1818-1818-181818181818"), GymId = gymNovoSarajevo, Url = "https://images.unsplash.com/photo-1534367610401-9f5ed68180aa?auto=format&fit=crop&w=1200&q=80", SortOrder = 1 },
            new GymPhoto { Id = Guid.Parse("19191919-1919-1919-1919-191919191919"), GymId = gymNovoSarajevo, Url = "https://images.unsplash.com/photo-1550345332-09e3ac987658?auto=format&fit=crop&w=1200&q=80", SortOrder = 2 },
            new GymPhoto { Id = Guid.Parse("1a1a1a1a-1a1a-1a1a-1a1a-1a1a1a1a1a1a"), GymId = gymNovoSarajevo, Url = "https://images.unsplash.com/photo-1554284126-aa88f22d0a1d?auto=format&fit=crop&w=1200&q=80", SortOrder = 3 },
            new GymPhoto { Id = Guid.Parse("1b1b1b1b-1b1b-1b1b-1b1b-1b1b1b1b1b1b"), GymId = gymGrbavica, Url = "https://images.unsplash.com/photo-1546483875-ad9014c88eba?auto=format&fit=crop&w=1200&q=80", SortOrder = 1 },
            new GymPhoto { Id = Guid.Parse("1c1c1c1c-1c1c-1c1c-1c1c-1c1c1c1c1c1c"), GymId = gymGrbavica, Url = "https://images.unsplash.com/photo-1549576490-b0b4831ef60a?auto=format&fit=crop&w=1200&q=80", SortOrder = 2 },
            new GymPhoto { Id = Guid.Parse("1d1d1d1d-1d1d-1d1d-1d1d-1d1d1d1d1d1d"), GymId = gymGrbavica, Url = "https://images.unsplash.com/photo-1558611848-73f7eb4001a1?auto=format&fit=crop&w=1200&q=80", SortOrder = 3 },
            new GymPhoto { Id = Guid.Parse("1e1e1e1e-1e1e-1e1e-1e1e-1e1e1e1e1e1e"), GymId = gymBosna, Url = "https://images.unsplash.com/photo-1546483875-ad9014c88eba?auto=format&fit=crop&w=1200&q=80", SortOrder = 1 },
            new GymPhoto { Id = Guid.Parse("1f1f1f1f-1f1f-1f1f-1f1f-1f1f1f1f1f1f"), GymId = gymBosna, Url = "https://images.unsplash.com/photo-1554344728-77cf90d9ed26?auto=format&fit=crop&w=1200&q=80", SortOrder = 2 },
            new GymPhoto { Id = Guid.Parse("20202020-2020-2020-2020-202020202020"), GymId = gymBosna, Url = "https://images.unsplash.com/photo-1556817411-31ae72fa3ea0?auto=format&fit=crop&w=1200&q=80", SortOrder = 3 },
            new GymPhoto { Id = Guid.Parse("21212121-2121-2121-2121-212121212121"), GymId = gymGrada, Url = "https://images.unsplash.com/photo-1526401485004-46910ecc8e51?auto=format&fit=crop&w=1200&q=80", SortOrder = 1 },
            new GymPhoto { Id = Guid.Parse("22222222-2222-2222-2222-222222222230"), GymId = gymGrada, Url = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=1200&q=80", SortOrder = 2 },
            new GymPhoto { Id = Guid.Parse("23232323-2323-2323-2323-232323232323"), GymId = gymGrada, Url = "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80", SortOrder = 3 }
        );

        modelBuilder.Entity<Trainer>().HasData(
            new Trainer
            {
                Id = trainer1,
                UserId = userTrainer1,
                Bio = "Strength and conditioning focus for busy professionals.",
                Certifications = "NSCA CPT",
                PhotoUrl = "https://images.unsplash.com/photo-1549576490-b0b4831ef60a?auto=format&fit=crop&w=600&q=80",
                HourlyRate = 45m,
                Specialties = new List<TrainerSpecialty> { TrainerSpecialty.Strength, TrainerSpecialty.Hypertrophy },
                Styles = new List<TrainerStyle> { TrainerStyle.Strict, TrainerStyle.TechniqueFocus },
                SupportedFitnessLevels = new List<FitnessLevel> { FitnessLevel.Intermediate, FitnessLevel.Advanced }
            },
            new Trainer
            {
                Id = trainer2,
                UserId = userTrainer2,
                Bio = "Mobility and posture coaching with recovery work.",
                Certifications = "RYT-200",
                PhotoUrl = "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&q=80",
                HourlyRate = 35m,
                Specialties = new List<TrainerSpecialty> { TrainerSpecialty.Mobility, TrainerSpecialty.Rehab },
                Styles = new List<TrainerStyle> { TrainerStyle.Supportive, TrainerStyle.TechniqueFocus },
                SupportedFitnessLevels = new List<FitnessLevel> { FitnessLevel.Beginner, FitnessLevel.Intermediate }
            },
            new Trainer
            {
                Id = trainer3,
                UserId = userTrainer3,
                Bio = "HIIT and bodyweight circuits, fast results.",
                Certifications = "ACE CPT",
                PhotoUrl = "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80",
                HourlyRate = 40m,
                Specialties = new List<TrainerSpecialty> { TrainerSpecialty.Cardio, TrainerSpecialty.WeightLoss, TrainerSpecialty.Functional },
                Styles = new List<TrainerStyle> { TrainerStyle.HighIntensity, TrainerStyle.Friendly },
                SupportedFitnessLevels = new List<FitnessLevel> { FitnessLevel.Beginner, FitnessLevel.Intermediate }
            },
            new Trainer
            {
                Id = trainer4,
                UserId = userTrainer4,
                Bio = "Strength cycles and barbell technique.",
                Certifications = "IPF Level 1",
                PhotoUrl = "https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?auto=format&fit=crop&w=600&q=80",
                HourlyRate = 55m,
                Specialties = new List<TrainerSpecialty> { TrainerSpecialty.Strength, TrainerSpecialty.Hypertrophy },
                Styles = new List<TrainerStyle> { TrainerStyle.TechniqueFocus, TrainerStyle.Strict },
                SupportedFitnessLevels = new List<FitnessLevel> { FitnessLevel.Intermediate, FitnessLevel.Advanced }
            },
            new Trainer
            {
                Id = trainer5,
                UserId = userTrainer5,
                Bio = "Functional training and mobility-based sessions.",
                Certifications = "Functional Trainer",
                PhotoUrl = "https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80",
                HourlyRate = 38m,
                Specialties = new List<TrainerSpecialty> { TrainerSpecialty.Functional, TrainerSpecialty.Mobility },
                Styles = new List<TrainerStyle> { TrainerStyle.Friendly, TrainerStyle.Supportive },
                SupportedFitnessLevels = new List<FitnessLevel> { FitnessLevel.Beginner, FitnessLevel.Intermediate }
            },
            new Trainer
            {
                Id = trainer6,
                UserId = userTrainer6,
                Bio = "Boxing fundamentals and conditioning.",
                Certifications = "Boxing Level 2",
                PhotoUrl = "https://images.unsplash.com/photo-1508341591423-4347099e1f19?auto=format&fit=crop&w=600&q=80",
                HourlyRate = 50m,
                Specialties = new List<TrainerSpecialty> { TrainerSpecialty.Boxing, TrainerSpecialty.Cardio },
                Styles = new List<TrainerStyle> { TrainerStyle.HighIntensity, TrainerStyle.Friendly },
                SupportedFitnessLevels = new List<FitnessLevel> { FitnessLevel.Beginner, FitnessLevel.Intermediate, FitnessLevel.Advanced }
            }
        );

        modelBuilder.Entity<GymTrainer>().HasData(
            new GymTrainer { GymId = gymNovoSarajevo, TrainerId = trainer1, AssignedAtUtc = seedNow },
            new GymTrainer { GymId = gymNovoSarajevo, TrainerId = trainer2, AssignedAtUtc = seedNow },
            new GymTrainer { GymId = gymGrbavica, TrainerId = trainer3, AssignedAtUtc = seedNow },
            new GymTrainer { GymId = gymBosna, TrainerId = trainer4, AssignedAtUtc = seedNow },
            new GymTrainer { GymId = gymBosna, TrainerId = trainer5, AssignedAtUtc = seedNow },
            new GymTrainer { GymId = gymGrada, TrainerId = trainer6, AssignedAtUtc = seedNow }
        );

        modelBuilder.Entity<CentralAdministrator>().HasData(
            new CentralAdministrator { Id = centralAdmin, UserId = userCentral }
        );

        modelBuilder.Entity<GymAdministrator>().HasData(
            new GymAdministrator { Id = gymAdmin1, UserId = userGymAdmin1, GymId = gym1 },
            new GymAdministrator { Id = gymAdmin2, UserId = userGymAdmin2, GymId = gym2 },
            new GymAdministrator { Id = gymAdmin3, UserId = userGymAdmin3, GymId = gym3 },
            new GymAdministrator { Id = gymAdmin4, UserId = userGymAdmin4, GymId = gym4 },
            new GymAdministrator { Id = gymAdminNovo, UserId = userGymAdminNovo, GymId = gymNovoSarajevo },
            new GymAdministrator { Id = gymAdminGrb, UserId = userGymAdminGrb, GymId = gymGrbavica },
            new GymAdministrator { Id = gymAdminBosna, UserId = userGymAdminBosna, GymId = gymBosna },
            new GymAdministrator { Id = gymAdminGrada, UserId = userGymAdminGrada, GymId = gymGrada }
        );

        modelBuilder.Entity<GymPlan>().HasData(
            new GymPlan { Id = plan1, GymId = gym1, Name = "Monthly", Price = 49.99m, DurationMonths = 1, Description = "One month access." },
            new GymPlan { Id = plan2, GymId = gym2, Name = "Quarterly", Price = 129.99m, DurationMonths = 3, Description = "Three months access." },
            new GymPlan { Id = plan3, GymId = gym3, Name = "Annual", Price = 399.99m, DurationMonths = 12, Description = "Annual membership." },
            new GymPlan { Id = plan4, GymId = gym4, Name = "Drop-in 10", Price = 89.99m, DurationMonths = 3, Description = "10 session pack." }
        );

        modelBuilder.Entity<MembershipRequest>().HasData(
            new MembershipRequest { Id = membershipRequest, UserId = userMember1, GymId = gym1, GymPlanId = plan1, Status = MembershipRequestStatus.Pending }
        );

        modelBuilder.Entity<Membership>().HasData(
            new Membership
            {
                Id = membership,
                UserId = userMember2,
                GymId = gym1,
                GymPlanId = plan1,
                StartDateUtc = seedNow.AddDays(-10),
                EndDateUtc = seedNow.AddMonths(3),
                Status = MembershipStatus.Active
            }
        );

        modelBuilder.Entity<QRCode>().HasData(
            new QRCode { Id = qrCode, MembershipId = membership, TokenHash = "token-hash-1", ExpiresAtUtc = seedNow.AddDays(30) }
        );

        modelBuilder.Entity<TrainerSchedule>().HasData(
            new TrainerSchedule { Id = schedule1, TrainerId = trainer1, GymId = gym1, StartUtc = seedNow.AddDays(1).Date.AddHours(9), EndUtc = seedNow.AddDays(1).Date.AddHours(10), IsAvailable = true },
            new TrainerSchedule { Id = schedule2, TrainerId = trainer2, GymId = gym2, StartUtc = seedNow.AddDays(1).Date.AddHours(12), EndUtc = seedNow.AddDays(1).Date.AddHours(13), IsAvailable = true },
            new TrainerSchedule { Id = schedule3, TrainerId = trainer3, GymId = gym3, StartUtc = seedNow.AddDays(2).Date.AddHours(17), EndUtc = seedNow.AddDays(2).Date.AddHours(18), IsAvailable = true },
            new TrainerSchedule { Id = schedule4, TrainerId = trainer4, GymId = gym4, StartUtc = seedNow.AddDays(2).Date.AddHours(8), EndUtc = seedNow.AddDays(2).Date.AddHours(9), IsAvailable = false },
            new TrainerSchedule { Id = schedule5, TrainerId = trainer5, GymId = gym1, StartUtc = seedNow.AddDays(3).Date.AddHours(15), EndUtc = seedNow.AddDays(3).Date.AddHours(16), IsAvailable = true },
            new TrainerSchedule { Id = schedule6, TrainerId = trainer6, GymId = gym2, StartUtc = seedNow.AddDays(3).Date.AddHours(18), EndUtc = seedNow.AddDays(3).Date.AddHours(19), IsAvailable = true }
        );

        modelBuilder.Entity<TrainingSession>().HasData(
            new TrainingSession { Id = session1, UserId = userMember3, TrainerId = trainer1, GymId = gym1, StartUtc = seedNow.AddDays(1).Date.AddHours(9), EndUtc = seedNow.AddDays(1).Date.AddHours(10), Status = TrainingSessionStatus.Confirmed },
            new TrainingSession { Id = session2, UserId = userMember4, TrainerId = trainer3, GymId = gym3, StartUtc = seedNow.AddDays(2).Date.AddHours(17), EndUtc = seedNow.AddDays(2).Date.AddHours(18), Status = TrainingSessionStatus.Confirmed }
        );

        modelBuilder.Entity<Payment>().HasData(
            new Payment { Id = payment1, Amount = 30m, Method = PaymentMethod.Card, PaidAtUtc = seedNow.AddDays(-1), TrainingSessionId = session1 }
        );

        modelBuilder.Entity<Review>().HasData(
            new Review { Id = review1, UserId = userMember3, TrainerId = trainer1, GymId = gym1, Rating = 5, Comment = "Great session." },
            new Review { Id = review2, UserId = userMember4, TrainerId = trainer3, GymId = gym3, Rating = 4, Comment = "Nice class." }
        );

        modelBuilder.Entity<Preference>().HasData(
            new Preference
            {
                Id = preferenceMember1,
                UserId = userMember1,
                FitnessGoal = "weight_loss",
                TrainingGoals = new List<TrainingGoal> { TrainingGoal.WeightLoss, TrainingGoal.GeneralFitness },
                WorkoutTypes = new List<WorkoutType> { WorkoutType.Cardio, WorkoutType.Functional },
                FitnessLevel = FitnessLevel.Beginner,
                PreferredWorkoutTime = "Evening",
                PreferredGymLocations = "Novo Sarajevo, Grbavica",
                PreferredLatitude = 43.8561,
                PreferredLongitude = 18.4039
            },
            new Preference
            {
                Id = preferenceMember2,
                UserId = userMember2,
                FitnessGoal = "muscle_gain",
                TrainingGoals = new List<TrainingGoal> { TrainingGoal.MuscleGain, TrainingGoal.Strength },
                WorkoutTypes = new List<WorkoutType> { WorkoutType.Gym, WorkoutType.Functional },
                FitnessLevel = FitnessLevel.Intermediate,
                PreferredWorkoutTime = "Morning",
                PreferredGymLocations = "Bosna",
                PreferredLatitude = 43.8577,
                PreferredLongitude = 18.4127
            },
            new Preference
            {
                Id = preferenceMember3,
                UserId = userMember3,
                FitnessGoal = "endurance",
                TrainingGoals = new List<TrainingGoal> { TrainingGoal.Endurance, TrainingGoal.WeightLoss },
                WorkoutTypes = new List<WorkoutType> { WorkoutType.Cardio, WorkoutType.Boxing },
                FitnessLevel = FitnessLevel.Intermediate,
                PreferredWorkoutTime = "Afternoon",
                PreferredGymLocations = "Bascarsija",
                PreferredLatitude = 43.8594,
                PreferredLongitude = 18.4302
            },
            new Preference
            {
                Id = preferenceMember4,
                UserId = userMember4,
                FitnessGoal = "rehab",
                TrainingGoals = new List<TrainingGoal> { TrainingGoal.Rehab, TrainingGoal.GeneralFitness },
                WorkoutTypes = new List<WorkoutType> { WorkoutType.Yoga, WorkoutType.Pilates },
                FitnessLevel = FitnessLevel.Beginner,
                PreferredWorkoutTime = "Morning",
                PreferredGymLocations = "Marijin Dvor",
                PreferredLatitude = 43.8570,
                PreferredLongitude = 18.4110
            },
            new Preference
            {
                Id = preferenceMember5,
                UserId = userMember5,
                FitnessGoal = "strength",
                TrainingGoals = new List<TrainingGoal> { TrainingGoal.Strength, TrainingGoal.MuscleGain },
                WorkoutTypes = new List<WorkoutType> { WorkoutType.Gym, WorkoutType.Crossfit },
                FitnessLevel = FitnessLevel.Advanced,
                PreferredWorkoutTime = "Evening",
                PreferredGymLocations = "Novo Sarajevo, Bosna",
                PreferredLatitude = 43.8529,
                PreferredLongitude = 18.4012
            }
        );

        modelBuilder.Entity<UserTrainerInteraction>().HasData(
            new UserTrainerInteraction
            {
                Id = interaction1,
                UserId = userMember1,
                TrainerId = trainer3,
                Type = UserTrainerInteractionType.ViewProfile,
                Weight = 1,
                CreatedAtUtc = seedNow.AddDays(-7)
            },
            new UserTrainerInteraction
            {
                Id = interaction2,
                UserId = userMember1,
                TrainerId = trainer1,
                Type = UserTrainerInteractionType.Message,
                Weight = 2,
                CreatedAtUtc = seedNow.AddDays(-6)
            },
            new UserTrainerInteraction
            {
                Id = interaction3,
                UserId = userMember2,
                TrainerId = trainer4,
                Type = UserTrainerInteractionType.Booking,
                Weight = 3,
                CreatedAtUtc = seedNow.AddDays(-4)
            },
            new UserTrainerInteraction
            {
                Id = interaction4,
                UserId = userMember3,
                TrainerId = trainer6,
                Type = UserTrainerInteractionType.ViewProfile,
                Weight = 1,
                CreatedAtUtc = seedNow.AddDays(-3)
            },
            new UserTrainerInteraction
            {
                Id = interaction5,
                UserId = userMember4,
                TrainerId = trainer2,
                Type = UserTrainerInteractionType.Favorite,
                Weight = 2,
                CreatedAtUtc = seedNow.AddDays(-2)
            },
            new UserTrainerInteraction
            {
                Id = interaction6,
                UserId = userMember5,
                TrainerId = trainer4,
                Type = UserTrainerInteractionType.Message,
                Weight = 2,
                CreatedAtUtc = seedNow.AddDays(-1)
            }
        );

        modelBuilder.Entity<Conversation>().HasData(
            new Conversation
            {
                Id = conversation1,
                Title = "Training chat",
                MemberId = userMember1,
                TrainerId = userTrainer1,
                CreatedAtUtc = seedNow.AddDays(-2),
                UpdatedAtUtc = seedNow.AddDays(-1),
                LastMessageAtUtc = seedNow.AddHours(-5)
            },
            new Conversation
            {
                Id = conversation2,
                Title = "Session follow-up",
                MemberId = userMember2,
                TrainerId = userTrainer2,
                CreatedAtUtc = seedNow.AddDays(-3),
                UpdatedAtUtc = seedNow.AddDays(-2),
                LastMessageAtUtc = seedNow.AddDays(-2).AddHours(2)
            },
            new Conversation
            {
                Id = conversation3,
                Title = "Nutrition tips",
                MemberId = userMember3,
                TrainerId = userTrainer3,
                CreatedAtUtc = seedNow.AddDays(-1),
                UpdatedAtUtc = seedNow.AddHours(-6),
                LastMessageAtUtc = seedNow.AddHours(-6)
            }
        );

        modelBuilder.Entity<ConversationParticipant>().HasData(
            new ConversationParticipant
            {
                Id = participant1,
                ConversationId = conversation1,
                UserId = userMember1,
                JoinedAtUtc = seedNow.AddDays(-2),
                LastReadAtUtc = seedNow.AddHours(-6)
            },
            new ConversationParticipant
            {
                Id = participant2,
                ConversationId = conversation1,
                UserId = userTrainer1,
                JoinedAtUtc = seedNow.AddDays(-2),
                LastReadAtUtc = seedNow.AddHours(-5)
            },
            new ConversationParticipant
            {
                Id = participant3,
                ConversationId = conversation2,
                UserId = userMember2,
                JoinedAtUtc = seedNow.AddDays(-3),
                LastReadAtUtc = seedNow.AddDays(-2)
            },
            new ConversationParticipant
            {
                Id = participant4,
                ConversationId = conversation2,
                UserId = userTrainer2,
                JoinedAtUtc = seedNow.AddDays(-3),
                LastReadAtUtc = seedNow.AddDays(-2).AddHours(1)
            },
            new ConversationParticipant
            {
                Id = participant5,
                ConversationId = conversation3,
                UserId = userMember3,
                JoinedAtUtc = seedNow.AddDays(-1),
                LastReadAtUtc = seedNow.AddHours(-7)
            },
            new ConversationParticipant
            {
                Id = participant6,
                ConversationId = conversation3,
                UserId = userTrainer3,
                JoinedAtUtc = seedNow.AddDays(-1),
                LastReadAtUtc = seedNow.AddHours(-6)
            }
        );

        modelBuilder.Entity<Message>().HasData(
            new Message
            {
                Id = message1,
                ConversationId = conversation1,
                SenderUserId = userTrainer1,
                SenderRole = UserRole.Trainer.ToString(),
                Content = "Welcome to FitCity!",
                SentAtUtc = seedNow.AddHours(-5)
            },
            new Message
            {
                Id = message2,
                ConversationId = conversation2,
                SenderUserId = userMember2,
                SenderRole = UserRole.User.ToString(),
                Content = "Thanks for the session today!",
                SentAtUtc = seedNow.AddDays(-2).AddHours(2)
            },
            new Message
            {
                Id = message3,
                ConversationId = conversation3,
                SenderUserId = userTrainer3,
                SenderRole = UserRole.Trainer.ToString(),
                Content = "Keep protein high and stay hydrated.",
                SentAtUtc = seedNow.AddHours(-6)
            },
            new Message
            {
                Id = message4,
                ConversationId = conversation3,
                SenderUserId = userMember3,
                SenderRole = UserRole.User.ToString(),
                Content = "Got it, thank you!",
                SentAtUtc = seedNow.AddHours(-5)
            }
        );
    }
}
