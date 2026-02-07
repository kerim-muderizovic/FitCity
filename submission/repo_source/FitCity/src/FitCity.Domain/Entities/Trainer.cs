using FitCity.Domain.Enums;

namespace FitCity.Domain.Entities;

public class Trainer
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string? Bio { get; set; }
    public string? Certifications { get; set; }
    public string? PhotoUrl { get; set; }
    public decimal? HourlyRate { get; set; }
    public List<TrainerSpecialty> Specialties { get; set; } = new();
    public List<TrainerStyle> Styles { get; set; } = new();
    public List<FitnessLevel> SupportedFitnessLevels { get; set; } = new();
    public bool IsActive { get; set; } = true;

    public User User { get; set; } = null!;
    public ICollection<GymTrainer> GymTrainers { get; set; } = new List<GymTrainer>();
    public ICollection<TrainerSchedule> Schedules { get; set; } = new List<TrainerSchedule>();
    public ICollection<TrainingSession> Sessions { get; set; } = new List<TrainingSession>();
    public ICollection<Review> Reviews { get; set; } = new List<Review>();
}
