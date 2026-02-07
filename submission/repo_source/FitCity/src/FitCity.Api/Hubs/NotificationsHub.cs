using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace FitCity.Api.Hubs;

[Authorize]
public class NotificationsHub : Hub
{
}
