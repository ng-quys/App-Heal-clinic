

class Patient {
  String patientId;
  String fullName;
  String address;
  String allergies;
  String bloodType;
  String chronicDiseases;
  DateTime createAt;
  DateTime dateOfBrith;
  String emergencyContactName;
  String emergencyContactPhone;
  String gender;
  double height;
  DateTime updateAt;

  Patient({
    required this.patientId,
    required this.fullName,
    required this.address,
    required this.allergies,
    required this.bloodType,
    required this.chronicDiseases,
    required this.createAt,
    required this.dateOfBrith,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.gender,
    required this.height,
    required this.updateAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'fullName': fullName,
      'address': address,
      'allergies': allergies,
      'bloodType': bloodType,
      'chronicDiseases': chronicDiseases,
      'createAt': createAt,
      'dateOfBrith': dateOfBrith,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'gender': gender,
      'height': height,
      'updateAt': updateAt,
    };

  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patientId'],
      fullName: map['fullName'],
      address: map['address'],
      allergies: map['allergies'],
      bloodType: map['bloodType'],
      chronicDiseases: map['chronicDiseases'],
      createAt: map['createAt'] as DateTime,
      dateOfBrith: map['dateOfBrith'] as DateTime,
      emergencyContactName: map['emergencyContactName'],
      emergencyContactPhone: map['emergencyContactPhone'],
      gender: map['gender'],
      height: map['height'],
      updateAt: map['updateAt'] as DateTime,
    );
  }

}