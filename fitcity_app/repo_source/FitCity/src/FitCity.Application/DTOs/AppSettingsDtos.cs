namespace FitCity.Application.DTOs;

public class AppSettingsDto
{
    public bool AllowGymRegistrations { get; set; }
    public bool AllowUserRegistration { get; set; }
    public bool AllowTrainerCreation { get; set; }
}

public class UpdateAppSettingsRequest
{
    public bool? AllowGymRegistrations { get; set; }
    public bool? AllowUserRegistration { get; set; }
    public bool? AllowTrainerCreation { get; set; }
}
