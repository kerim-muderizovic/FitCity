using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class Preference
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string? FitnessGoal { get; set; }
    public List<TrainingGoal> TrainingGoals { get; set; } = new();
    public List<WorkoutType> WorkoutTypes { get; set; } = new();
    public FitnessLevel? FitnessLevel { get; set; }
    public string? PreferredWorkoutTime { get; set; }
    public string? PreferredGymLocations { get; set; }
    public double? PreferredLatitude { get; set; }
    public double? PreferredLongitude { get; set; }
    public bool NotificationsEnabled { get; set; } = true;

    public User User { get; set; } = null!;
}
