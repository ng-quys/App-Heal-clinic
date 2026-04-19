import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, confirmed, inProgress, done, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Chờ xác nhận';
      case AppointmentStatus.confirmed:
        return 'Đã xác nhận';
      case AppointmentStatus.inProgress:
        return 'Đang khám';
      case AppointmentStatus.done:
        return 'Đã khám';
      case AppointmentStatus.cancelled:
        return 'Đã hủy';
    }
  }

  static AppointmentStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'inProgress':
        return AppointmentStatus.inProgress;
      case 'done':
        return AppointmentStatus.done;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.inProgress:
        return 'inProgress';
      case AppointmentStatus.done:
        return 'done';
      case AppointmentStatus.cancelled:
        return 'cancelled';
    }
  }
}

class AppointmentModel {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String patientName;
  final DateTime scheduledAt;
  final String reason;
  final AppointmentStatus status;
  final int? queueNumber;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.scheduledAt,
    required this.reason,
    required this.status,
    this.queueNumber,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      appointmentId: id,
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: map['reason'] ?? '',
      status: AppointmentStatusX.fromString(map['status'] ?? 'pending'),
      queueNumber: map['queueNumber'] as int?,
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'reason': reason,
      'status': status.value,
      'queueNumber': queueNumber,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppointmentModel copyWith({AppointmentStatus? status, String? notes, int? queueNumber}) {
    return AppointmentModel(
      appointmentId: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
      patientName: patientName,
      scheduledAt: scheduledAt,
      reason: reason,
      status: status ?? this.status,
      queueNumber: queueNumber ?? this.queueNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
