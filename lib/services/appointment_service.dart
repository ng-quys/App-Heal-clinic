import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';

class AppointmentService {
  final AppointmentRepository _appointmentRepository;

  AppointmentService({AppointmentRepository? appointmentRepository})
      : _appointmentRepository = appointmentRepository ?? AppointmentRepository();

  Stream<List<AppointmentModel>> watchTodayAppointments(String doctorId) {
    return _appointmentRepository.watchTodayAppointments(doctorId);
  }

  Stream<List<AppointmentModel>> watchAppointmentsByDate(
      String doctorId, DateTime date) {
    return _appointmentRepository.watchAppointmentsByDate(doctorId, date);
  }

  Stream<List<AppointmentModel>> watchQueue(String doctorId) {
    return _appointmentRepository.watchQueueAppointments(doctorId);
  }

  Future<List<AppointmentModel>> getPatientHistory(
      String doctorId, String patientId) async {
    return await _appointmentRepository.getPatientAppointments(doctorId, patientId);
  }

  Future<void> markAsDone(String appointmentId) async {
    await _appointmentRepository.updateStatus(
        appointmentId, AppointmentStatus.done);
  }

  Future<void> markInProgress(String appointmentId) async {
    await _appointmentRepository.updateStatus(
        appointmentId, AppointmentStatus.inProgress);
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _appointmentRepository.updateStatus(
        appointmentId, AppointmentStatus.cancelled);
  }

  Future<void> saveNotes(String appointmentId, String notes) async {
    await _appointmentRepository.updateNotes(appointmentId, notes);
  }

  Future<List<DateTime>> getMonthAppointmentDates(
      String doctorId, int year, int month) async {
    return await _appointmentRepository.getAppointmentDates(doctorId, year, month);
  }

  Map<String, int> getTodaySummary(List<AppointmentModel> appointments) {
    return {
      'total': appointments.length,
      'done': appointments.where((a) => a.status == AppointmentStatus.done).length,
      'waiting': appointments
          .where((a) =>
              a.status == AppointmentStatus.confirmed ||
              a.status == AppointmentStatus.pending)
          .length,
      'inProgress':
          appointments.where((a) => a.status == AppointmentStatus.inProgress).length,
    };
  }
}
