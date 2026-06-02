using System;
using System.Collections.Generic;

namespace ConnectionStringAPI.ResultDB;

public partial class Chatwithdoctor
{
    public int ChatId { get; set; }

    public string PatientId { get; set; }

    public string DoctorId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Doctor Doctor { get; set; } = null!;

    public virtual ICollection<Messagedetail> Messagedetails { get; set; } = new List<Messagedetail>();

    public virtual Patient Patient { get; set; } = null!;
}
