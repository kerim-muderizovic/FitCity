namespace FitCity.Application.Messaging;

public class EmailMessage
{
    public string EmailTo { get; set; } = string.Empty;
    public string ReceiverName { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}
