import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  completed,
  cancelled,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get status {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}

AppointmentStatus fromString(String status) {
  switch (status) {
    case 'Pending':
      return AppointmentStatus.pending;
    case 'Completed':
      return AppointmentStatus.completed;
    case 'Cancelled':
      return AppointmentStatus.cancelled;
    default:
      throw ArgumentError('Invalid appointment status: $status');
  }
}

String getAppointmentStatus(AppointmentStatus status) {
  switch (status) {
    case AppointmentStatus.pending:
      return 'Pending';
    case AppointmentStatus.completed:
      return 'Completed';
    case AppointmentStatus.cancelled:
      return 'Cancelled';
  }
}

class Appointment {
  DateTime appointmentDate;
  String appointmentId;
  DateTime createAt;
  String doctorId;
  String patientId;
  DateTime updateAt;
  String note;
  String doctorName;
  String patientName;
  int queueNumber;
  String status;
  String symptoms;

  Appointment({
    required this.appointmentDate,
    required this.appointmentId,
    required this.createAt,
    required this.doctorId,
    required this.patientId,
    required this.updateAt,
    required this.note,
    required this.doctorName,
    required this.patientName,
    required this.queueNumber,
    required this.status,
    required this.symptoms,
});

  Map<String, dynamic> toMap() {
    return {
      'appointmentDate': appointmentDate,
      'appointmentId': appointmentId,
      'createAt': createAt,
      'doctorId': doctorId,
      'patientId': patientId,
      'updateAt': updateAt,
      'note': note,
      'doctorName': doctorName,
      'patientName': patientName,
      'queueNumber': queueNumber,
      'status': status,
      'symptoms': symptoms,
    };
  }


  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentDate: map['appointmentDate'] as DateTime,
      appointmentId: map['appointmentId'],
      createAt: map['createAt'] as DateTime,
      doctorId: map['doctorId'],
      patientId: map['patientId'],
      updateAt: map['updateAt'] as DateTime,
      note: map['note'],
      doctorName: map['doctorName'],
      patientName: map['patientName'],
      queueNumber: map['queueNumber'],
      status: map['status'],
      symptoms: map['symptoms'],
    );
  }

  Appointment copyWith({
    DateTime? appointmentDate,
    String? appointmentId,
    DateTime? createAt,
    String? doctorId,
    String? patientId,
    DateTime? updateAt,
    String? note,
    String? doctorName,
    String? patientName,
    int? queueNumber,
    String? status,
    String? symptoms,
  }){
    return Appointment(
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentId: appointmentId ?? this.appointmentId,
      createAt: createAt ?? this.createAt,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      updateAt: updateAt ?? this.updateAt,
      note: note ?? this.note,
      doctorName: doctorName ?? this.doctorName,
      patientName: patientName ?? this.patientName,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      symptoms: symptoms ?? this.symptoms,
    );
  }

}