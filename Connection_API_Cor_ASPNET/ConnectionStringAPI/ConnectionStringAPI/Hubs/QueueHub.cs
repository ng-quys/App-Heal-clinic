using Microsoft.AspNetCore.SignalR;
using System.Threading.Tasks;

namespace ConnectionStringAPI.Hubs
{
    public class QueueHub : Hub
    {
        public async Task JoinDoctorRoom(string doctorId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, doctorId);
        }

        public async Task LeaveDoctorRoom(string doctorId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, doctorId);
        }

        public async Task NotifyQueueUpdate(string doctorId)
        {
            await Clients.Group(doctorId).SendAsync("QueueUpdated");
        }
    }
}
