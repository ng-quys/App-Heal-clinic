import 'package:cloud_firestore/cloud_firestore.dart';

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
      doctorId: id,
      fullName: map['fullName'] ?? '',
      specialty: map['specialty'] ?? '',
      clinicName: map['clinicName'] ?? '',
      workStartTime: map['workStartTime'] ?? '',
      workEndTime: map['workEndTime'] ?? '',
      address: map['address'] ?? '',
      bio: map['bio'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
