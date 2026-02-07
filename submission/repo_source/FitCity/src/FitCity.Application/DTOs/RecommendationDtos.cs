namespace FitCity.Application.DTOs;

public class RecommendedTrainerDto
{
    public Guid TrainerId { get; set; }
    public string TrainerName { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
    public decimal? HourlyRate { get; set; }
    public double? RatingAverage { get; set; }
    public int RatingCount { get; set; }
    public double Score { get; set; }
    public double ContentScore { get; set; }
    public double CollaborativeScore { get; set; }
    public double QualityScore { get; set; }
    public bool ExplorationBoosted { get; set; }
    public List<string> Reasons { get; set; } = new();
}

public class RecommendedGymDto
{
    public Guid GymId { get; set; }
    public string GymName { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string? PhotoUrl { get; set; }
    public string? WorkHours { get; set; }
    public double? RatingAverage { get; set; }
    public int RatingCount { get; set; }
    public double Score { get; set; }
    public double ContentScore { get; set; }
    public double CollaborativeScore { get; set; }
    public double QualityScore { get; set; }
    public double AvailabilityScore { get; set; }
    public double DistanceScore { get; set; }
    public List<string> Reasons { get; set; } = new();
}
