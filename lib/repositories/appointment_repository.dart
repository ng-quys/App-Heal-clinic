import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _appointments => _db.collection('appointments');

  Stream<List<AppointmentModel>> watchTodayAppointments(String doctorId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _appointments
        .where('doctorId', isEqualTo: doctorId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppointmentModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<AppointmentModel>> watchAppointmentsByDate(
      String doctorId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _appointments
        .where('doctorId', isEqualTo: doctorId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppointmentModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<AppointmentModel>> watchQueueAppointments(String doctorId) {
    return _appointments
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: ['confirmed', 'inProgress'])
        .orderBy('queueNumber')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AppointmentModel.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<List<AppointmentModel>> getPatientAppointments(
      String doctorId, String patientId) async {
    final snap = await _appointments
        .where('doctorId', isEqualTo: doctorId)
        .where('patientId', isEqualTo: patientId)
        .orderBy('scheduledAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => AppointmentModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> updateStatus(String appointmentId, AppointmentStatus status) async {
    await _appointments.doc(appointmentId).update({
      'status': status.value,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateNotes(String appointmentId, String notes) async {
    await _appointments.doc(appointmentId).update({
      'notes': notes,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<List<DateTime>> getAppointmentDates(String doctorId, int year, int month) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 1);
    final snap = await _appointments
        .where('doctorId', isEqualTo: doctorId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['scheduledAt'] as Timestamp).toDate();
    }).toList();
  }
}
