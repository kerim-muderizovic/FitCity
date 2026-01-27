namespace FitCity.Application.DTOs;

public class MonthlyCountDto
{
    public int Year { get; set; }
    public int Month { get; set; }
    public int Count { get; set; }
}

public class MonthlyRevenueDto
{
    public int Year { get; set; }
    public int Month { get; set; }
    public decimal Revenue { get; set; }
}

public class TopTrainerDto
{
    public Guid TrainerId { get; set; }
    public string TrainerName { get; set; } = string.Empty;
    public int BookingCount { get; set; }
}
