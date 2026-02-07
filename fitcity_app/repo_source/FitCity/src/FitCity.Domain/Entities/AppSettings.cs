namespace FitCity.Domain.Entities;

public class AppSettings
{
    public static readonly Guid DefaultId = new("f0f0f0f0-0000-0000-0000-000000000001");

    public Guid Id { get; set; }
    public bool AllowGymRegistrations { get; set; }
    public bool AllowUserRegistration { get; set; }
    public bool AllowTrainerCreation { get; set; }
}
