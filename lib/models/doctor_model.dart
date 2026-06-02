

class DoctorModel {
  final String doctorId;
  final String fullName;
  final String specialty;
  final String clinicName;
  final String workStartTime;
  final String workEndTime;
  final String address;
  final String bio;
  final String avatarUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  DoctorModel({
    required this.doctorId,
    required this.fullName,
    required this.specialty,
    required this.clinicName,
    required this.workStartTime,
    required this.workEndTime,
    required this.address,
    required this.bio,
    required this.avatarUrl,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      doctorId: map['doctorId']?.toString().trim() ?? id,
      fullName: map['fullName']?.toString().trim() ?? '',
      specialty: map['specialty'] != null ? map['specialty']['specialtyName']?.toString().trim() ?? '' : '',
      clinicName: map['clinicName'] ?? 'Phòng khám Đa khoa HealClinic',
      workStartTime: map['workStartTime']?.toString().trim() ?? '08:00:00',
      workEndTime: map['workEndTime']?.toString().trim() ?? '17:00:00',
      address: map['address'] ?? 'Trung tâm Y tế HealClinic',
      bio: map['bio']?.toString().trim() ?? '',
      avatarUrl: map['avatarUrl']?.toString().trim() ?? '',
      isAvailable: map['isAvailable'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updateAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'fullName': fullName,
      'specialty': specialty,
      'clinicName': clinicName,
      'workStartTime': workStartTime,
      'workEndTime': workEndTime,
      'address': address,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DoctorModel copyWith({
    String? fullName,
    String? specialty,
    String? clinicName,
    String? workStartTime,
    String? workEndTime,
    String? address,
    String? bio,
    String? avatarUrl,
    bool? isAvailable,
  }) {
    return DoctorModel(
      doctorId: doctorId,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      clinicName: clinicName ?? this.clinicName,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}


