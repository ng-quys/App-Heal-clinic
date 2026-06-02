enum AppointmentStatus { pending, confirmed, waiting, inProgress, done, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Chờ xác nhận';
      case AppointmentStatus.confirmed:
        return 'Đã xác nhận';
      case AppointmentStatus.waiting:
        return 'Chờ khám';
      case AppointmentStatus.inProgress:
        return 'Đang khám';
      case AppointmentStatus.done:
        return 'Đã khám';
      case AppointmentStatus.cancelled:
        return 'Đã hủy';
    }
  }

  static AppointmentStatus fromString(String value) {
    final v = value.toLowerCase();
    if (v.contains('xác nhận') || v.contains('xac nhan') || v.contains('a x')) return AppointmentStatus.confirmed;
    if (v.contains('chờ khám') || v.contains('cho kh') || v.contains('h kh')) return AppointmentStatus.waiting;
    if (v.contains('đang khám') || v.contains('ang kh') || v.contains('ng kh')) return AppointmentStatus.inProgress;
    if (v.contains('đã khám') || v.contains('da kh') || (v.contains('a kh') && !v.contains('ang'))) return AppointmentStatus.done;
    if (v.contains('đã hủy') || v.contains('da huy') || v.contains('a h')) return AppointmentStatus.cancelled;
    return AppointmentStatus.pending;
  }

  String get value {
    return label;
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
      appointmentId: map['appointmentId']?.toString() ?? id,
      doctorId: map['doctorId']?.toString().trim() ?? '',
      patientId: map['patientId']?.toString().trim() ?? '',
      patientName: map['patient'] != null ? map['patient']['fullName']?.toString().trim() ?? 'Unknown' : 'Unknown Patient',
      scheduledAt: DateTime.tryParse(map['appointmentDate']?.toString() ?? '') ?? DateTime.now(),
      reason: map['note']?.toString() ?? '',
      status: AppointmentStatusX.fromString(map['status']?.toString() ?? 'pending'),
      queueNumber: map['queueNumber'] as int?,
      notes: map['note']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updateAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'reason': reason,
      'status': status.value,
      'queueNumber': queueNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
