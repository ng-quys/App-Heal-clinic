using ConnectionStringAPI.ResultDB;
using ConnectionStringAPI.DTOs;
using Microsoft.AspNetCore.SignalR;
using ConnectionStringAPI.Hubs;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Reflection.Metadata.Ecma335;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace ConnectionStringAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MedicalRecordController : ControllerBase
    {
        private readonly QlBenhvienContext _con;
        private readonly IHubContext<QueueHub> _hubContext;

        public MedicalRecordController(QlBenhvienContext con, IHubContext<QueueHub> hubContext)
        {
            _con = con;
            _hubContext = hubContext;
        }

        [HttpPost("checkout")]
        public async Task<IActionResult> Checkout([FromBody] MedicalRecordCheckoutDto dto)
        {
            if (dto == null) return BadRequest("Invalid payload");

            using var transaction = await _con.Database.BeginTransactionAsync();
            try
            {
                // 1. Update Appointment Status to "Đã khám"
                var appointment = await _con.Appointments.FindAsync(dto.AppointmentId);
                if (appointment != null)
                {
                    appointment.Status = "Đã khám";
                    _con.Appointments.Update(appointment);
                }

                // 2. Create MedicalRecord
                var record = new MedicalRecord
                {
                    AppointmentId = dto.AppointmentId,
                    Diagnosis = dto.Diagnosis,
                    Symptoms = dto.Symptoms,
                    Treatment = dto.Treatment,
                    IsCover = dto.IsCover,
                    PercentCover = dto.PercentCover,
                    CreatedAt = DateTime.Now
                };
                await _con.MedicalRecords.AddAsync(record);
                await _con.SaveChangesAsync(); // To get RecordId

                // 3. Create Prescription if there are medications
                if (dto.Medications != null && dto.Medications.Any())
                {
                    var prescription = new Prescription
                    {
                        RecordId = record.RecordId,
                        Note = dto.PrescriptionNote,
                        CreatedAt = DateTime.Now
                    };
                    await _con.Prescriptions.AddAsync(prescription);
                    await _con.SaveChangesAsync(); // To get PrescriptionId

                    // 4. Create PrescriptionDetails
                    decimal totalAmount = 0;
                    foreach (var med in dto.Medications)
                    {
                        var detail = new Prescriptiondetail
                        {
                            PrescriptionId = prescription.PrescriptionId,
                            MedicationId = med.MedicationId,
                            Duration = med.Duration,
                            Quantity = med.Quantity,
                            Note = med.Note
                        };
                        await _con.Prescriptiondetails.AddAsync(detail);
                        
                        // Calculate price for payment
                        totalAmount += med.Price * med.Quantity;
                    }
                    await _con.SaveChangesAsync();

                    // 5. Create Payment for Prescription
                    // Discount logic if covered
                    if (dto.IsCover && dto.PercentCover > 0)
                    {
                        totalAmount = totalAmount * (100 - dto.PercentCover) / 100;
                    }

                    var payment = new Payment
                    {
                        PatientId = dto.PatientId,
                        PaymentType = "Đơn thuốc",
                        TotalAmount = totalAmount,
                        CreatedAt = DateTime.Now,
                        UpdateAt = DateTime.Now
                    };
                    await _con.Payments.AddAsync(payment);
                    await _con.SaveChangesAsync(); // To get PaymentId

                    // Create Paymentprescription link
                    var payPresc = new Paymentprescription
                    {
                        PaymentId = payment.PaymentId,
                        PrescriptionId = prescription.PrescriptionId
                    };
                    await _con.Paymentprescriptions.AddAsync(payPresc);
                    await _con.SaveChangesAsync();
                }

                // 6. Create Payment for Services
                if (dto.Services != null && dto.Services.Any())
                {
                    var paymentService = new Payment
                    {
                        PatientId = dto.PatientId,
                        PaymentType = "Dịch vụ",
                        TotalAmount = 0, // Trigger TG_TOTALAMOUNT_SERVICE will calculate this
                        CreatedAt = DateTime.Now,
                        UpdateAt = DateTime.Now
                    };
                    await _con.Payments.AddAsync(paymentService);
                    await _con.SaveChangesAsync(); // To get PaymentId

                    foreach (var svc in dto.Services)
                    {
                        var detail = new Paymentservice
                        {
                            PaymentId = paymentService.PaymentId,
                            ServiceId = svc.ServiceId,
                            Quantity = svc.Quantity
                        };
                        await _con.Paymentservices.AddAsync(detail);
                    }
                    await _con.SaveChangesAsync();
                }

                await transaction.CommitAsync();

                if (appointment != null && !string.IsNullOrEmpty(appointment.DoctorId))
                {
                    await _hubContext.Clients.Group(appointment.DoctorId).SendAsync("QueueUpdated");
                }

                return Ok(new { message = "Checkout completed successfully!", recordId = record.RecordId });
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return StatusCode(500, new { message = "Checkout failed", error = ex.Message, inner = ex.InnerException?.Message });
            }
        }



        [HttpGet]
        public async Task<IActionResult> GetAllMedicalRecords()
        {
            var records = await _con.MedicalRecords
                .Include(r => r.Appointment)
                .Include(r => r.Prescriptions)
                .ToListAsync();
            return Ok(records);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetMedicalRecordById(int id)
        {
            var record = await _con.MedicalRecords
                .Include(r => r.Appointment)
                .Include(r => r.Prescriptions)
                    .ThenInclude(p => p.Prescriptiondetails)
                        .ThenInclude(pd => pd.Medication)
                .FirstOrDefaultAsync(r => r.RecordId == id);

            if (record == null)
                return NotFound(new { message = "Medical record not found!" });

            return Ok(record);
        }

        [HttpGet("appointment/{appointmentId}")]
        public async Task<IActionResult> GetMedicalRecordByAppointmentId(int appointmentId)
        {
            var record = await _con.MedicalRecords
                .Include(r => r.Prescriptions)
                    .ThenInclude(p => p.Prescriptiondetails)
                        .ThenInclude(pd => pd.Medication)
                .FirstOrDefaultAsync(r => r.AppointmentId == appointmentId);

            if (record == null)
                return NotFound(new { message = "Medical record not found for this appointment!" });

            return Ok(record);
        }

        [HttpPost]
        public async Task<IActionResult> CreateMedicalRecord([FromBody] MedicalRecord record)
        {
            if (record == null)
                return BadRequest();

            // Ensure CreatedAt is set if not provided
            record.CreatedAt ??= DateTime.Now;

            await _con.MedicalRecords.AddAsync(record);
            await _con.SaveChangesAsync();

            return Ok(new { message = "Medical record created successfully!" });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateMedicalRecord(int id, [FromBody] MedicalRecord record)
        {
            if (record == null || id != record.RecordId)
                return BadRequest(new { message = "Record id not found or payload is invalid!" });

            var existing = await _con.MedicalRecords.FindAsync(id);
            if (existing == null)
                return NotFound(new { message = "Not found medical record!" });

            existing.AppointmentId = record.AppointmentId;
            existing.Diagnosis = record.Diagnosis;
            existing.Symptoms = record.Symptoms;
            existing.Treatment = record.Treatment;
            existing.IsCover = record.IsCover;
            existing.PercentCover = record.PercentCover;
            existing.CreatedAt = record.CreatedAt ?? existing.CreatedAt;

            _con.MedicalRecords.Update(existing);
            await _con.SaveChangesAsync();

            return Ok(new { message = "Medical record updated successfully!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteMedicalRecord(int id)
        {
            var existing = await _con.MedicalRecords.FindAsync(id);
            if (existing == null)
                return NotFound(new { message = "Not found medical record!" });

            _con.MedicalRecords.Remove(existing);
            await _con.SaveChangesAsync();
            return Ok(new { message = "Medical record deleted!" });
        }


    }
}
