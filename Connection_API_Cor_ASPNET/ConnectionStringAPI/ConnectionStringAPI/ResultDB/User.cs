using System;
using System.Collections.Generic;

namespace ConnectionStringAPI.ResultDB;

public partial class User
{
    public string UserId { get; set; } = null!;

    public string? Email { get; set; }

    public string? PassWord { get; set; }

    public string? Phone { get; set; }

    public string? Role { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? UpdateAt { get; set; }

    public virtual ICollection<Doctor> Doctors { get; set; } = new List<Doctor>();

    public virtual ICollection<Patient> Patients { get; set; } = new List<Patient>();
}
