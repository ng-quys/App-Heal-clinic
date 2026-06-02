

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
    List<String> parseStringToList(dynamic value) {
      if (value == null || value.toString().isEmpty) return [];
      return value.toString().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return PatientModel(
      patientId: map['patientId']?.toString().trim() ?? id,
      fullName: map['fullName']?.toString() ?? '',
      dateOfBirth: DateTime.tryParse(map['dateOfBirth']?.toString() ?? ''),
      gender: map['gender']?.toString() ?? '',
      bloodType: map['bloodType']?.toString().trim() ?? '',
      height: (map['height'] as num?)?.toDouble(),
      weight: (map['weight'] as num?)?.toDouble(),
      allergies: parseStringToList(map['allergies']),
      chronicDiseases: parseStringToList(map['chronicDiseases']),
      address: map['address']?.toString() ?? '',
      emergencyContactName: '',
      emergencyContactPhone: map['phone']?.toString().trim() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updateAt']?.toString() ?? '') ?? DateTime.now(),
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




