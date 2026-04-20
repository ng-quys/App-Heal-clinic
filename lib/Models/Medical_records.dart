class MedicalRecords {
  String appointmentId;
  DateTime createAt;
  String diagnosis;
  String doctorId;
  String medical_records;
  String patientId;
  String prescription;
  String symptoms;
  String treatment;

  MedicalRecords({
    required this.appointmentId,
    required this.createAt,
    required this.diagnosis,
    required this.doctorId,
    required this.medical_records,
    required this.patientId,
    required this.prescription,
    required this.symptoms,
    required this.treatment,
});

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'createAt': createAt,
      'diagnosis': diagnosis,
      'doctorId': doctorId,
      'medical_records': medical_records,
      'patientId': patientId,
      'prescription': prescription,
      'symptoms': symptoms,
      'treatment': treatment,
    };
  }

  factory MedicalRecords.fromMap(Map<String, dynamic> map) {
    return MedicalRecords(
      appointmentId: map['appointmentId'],
      createAt: map['createAt'] as DateTime,
      diagnosis: map['diagnosis'],
      doctorId: map['doctorId'],
      medical_records: map['medical_records'],
      patientId: map['patientId'],
      prescription: map['prescription'],
      symptoms: map['symptoms'],
      treatment: map['treatment'],
    );
  }

}