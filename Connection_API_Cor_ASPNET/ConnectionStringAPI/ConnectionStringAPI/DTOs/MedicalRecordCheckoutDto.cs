using System.Collections.Generic;

namespace ConnectionStringAPI.DTOs
{
    public class ServiceItemDto
    {
        public string ServiceId { get; set; } = null!;
        public int Quantity { get; set; }
    }

    public class MedicationItemDto
    {
        public string MedicationId { get; set; } = null!;
        public int Duration { get; set; }
        public int Quantity { get; set; }
        public string? Note { get; set; }
        public decimal Price { get; set; }
    }

    public class MedicalRecordCheckoutDto
    {
        public int AppointmentId { get; set; }
        public string PatientId { get; set; } = null!;
        public string? Diagnosis { get; set; }
        public string? Symptoms { get; set; }
        public string? Treatment { get; set; }
        public bool IsCover { get; set; }
        public int PercentCover { get; set; }
        public string? PrescriptionNote { get; set; }
        public List<MedicationItemDto> Medications { get; set; } = new List<MedicationItemDto>();
        public List<ServiceItemDto> Services { get; set; } = new List<ServiceItemDto>();
    }
}
