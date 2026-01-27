namespace FitCity.Domain.Entities;

public class GymPhoto
{
    public Guid Id { get; set; }
    public Guid GymId { get; set; }
    public string Url { get; set; } = string.Empty;
    public int SortOrder { get; set; }

    public Gym Gym { get; set; } = null!;
}
