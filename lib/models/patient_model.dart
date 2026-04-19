import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String patientId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String gender;
  final String bloodType;
  final double? height;
  final double? weight;
  final List<String> allergies;
  final List<String> chronicDiseases;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientModel({
    required this.patientId,
    required this.fullName,
    this.dateOfBirth,
    required this.gender,
    required this.bloodType,
    this.height,
    this.weight,
    required this.allergies,
    required this.chronicDiseases,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map, String id) {
    return PatientModel(
      patientId: id,
      fullName: map['fullName'] ?? '',
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: map['gender'] ?? '',
      bloodType: map['bloodType'] ?? '',
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      allergies: List<String>.from(map['allergies'] ?? []),
      chronicDiseases: List<String>.from(map['chronicDiseases'] ?? []),
      address: map['address'] ?? '',
      emergencyContactName: map['emergencyContactName'] ?? '',
      emergencyContactPhone: map['emergencyContactPhone'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}
