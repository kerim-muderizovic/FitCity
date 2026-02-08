namespace FitCity.Application.DTOs;

public class GymQrDto
{
    public Guid GymId { get; set; }
    public string GymName { get; set; } = string.Empty;
    public string Payload { get; set; } = string.Empty;
}

public class EntryValidateRequest
{
    public string Payload { get; set; } = string.Empty;
    public Guid? MemberId { get; set; }
}
