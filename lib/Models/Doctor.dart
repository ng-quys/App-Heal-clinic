import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  String doctorId;
  String fullName;
  String address;
  String avatarUrl;
  String bio;
  String createAt;
  int experienceYears;
  String specialty;
  DateTime updateAt;
  DateTime workEndTime;
  DateTime workStartTime;


  Doctor({
    required this.doctorId,
    required this.fullName,
    required this.address,
    required this.avatarUrl,
    required this.bio,
    required this.createAt,
    required this.experienceYears,
    required this.specialty,
    required this.updateAt,
    required this.workEndTime,
    required this.workStartTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'address': address,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'createAt': createAt,
      'experienceYears': experienceYears,
      'specialty': specialty,
      'updateAt': Timestamp.fromDate(updateAt),
      'workEndTime': Timestamp.fromDate(workEndTime),
      'workStartTime': Timestamp.fromDate(workStartTime),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map, String id) {
    return Doctor(
      doctorId: id,
      fullName: map['fullName'] ?? '',
      address: map['address'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      bio: map['bio'] ?? '',
      createAt: map['createAt'] ?? '',
      experienceYears: map['experienceYears'] ?? 0,
      specialty: map['specialty'] ?? '',
      updateAt: (map['updateAt'] as Timestamp).toDate(),
      workEndTime: (map['workEndTime'] as Timestamp).toDate(),
      workStartTime: (map['workStartTime'] as Timestamp).toDate(),
    );
  }

}