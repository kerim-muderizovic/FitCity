using FitCity.Notifications.Api.Entities;
using Microsoft.EntityFrameworkCore;

namespace FitCity.Notifications.Api.Persistence;

public class NotificationsDbContext : DbContext
{
    public NotificationsDbContext(DbContextOptions<NotificationsDbContext> options) : base(options)
    {
    }

    public DbSet<NotificationLog> NotificationLogs => Set<NotificationLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<NotificationLog>(builder =>
        {
            builder.HasKey(n => n.Id);
            builder.Property(n => n.EventName).HasMaxLength(200).IsRequired();
            builder.Property(n => n.Payload).HasMaxLength(4000).IsRequired();
            builder.HasIndex(n => n.ReceivedAtUtc);
        });
    }
}
