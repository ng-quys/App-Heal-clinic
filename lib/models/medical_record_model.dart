class MedicalRecordModel {
  final int recordId;
  final int appointmentId;
  final String diagnosis;
  final String symptoms;
  final String treatment;
  final bool isCover;
  final int percentCover;
  final DateTime createdAt;
  final List<PrescriptionDetailModel> prescriptions;

  MedicalRecordModel({
    required this.recordId,
    required this.appointmentId,
    required this.diagnosis,
    required this.symptoms,
    required this.treatment,
    required this.isCover,
    required this.percentCover,
    required this.createdAt,
    required this.prescriptions,
  });

  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    List<PrescriptionDetailModel> meds = [];
    if (map['prescriptions'] != null && (map['prescriptions'] as List).isNotEmpty) {
      final firstPresc = map['prescriptions'][0];
      if (firstPresc['prescriptiondetails'] != null) {
        for (var detail in firstPresc['prescriptiondetails']) {
          meds.add(PrescriptionDetailModel.fromMap(detail));
        }
      }
    }

    return MedicalRecordModel(
      recordId: map['recordId'] ?? 0,
      appointmentId: map['appointmentId'] ?? 0,
      diagnosis: map['diagnosis']?.toString() ?? '',
      symptoms: map['symptoms']?.toString() ?? '',
      treatment: map['treatment']?.toString() ?? '',
      isCover: map['isCover'] == true || map['isCover'] == 1,
      percentCover: map['percentCover'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      prescriptions: meds,
    );
  }
}

class PrescriptionDetailModel {
  final int detailId;
  final String medicationId;
  final String medicineName;
  final int quantity;
  final int duration;
  final String note;

  PrescriptionDetailModel({
    required this.detailId,
    required this.medicationId,
    required this.medicineName,
    required this.quantity,
    required this.duration,
    required this.note,
  });

  factory PrescriptionDetailModel.fromMap(Map<String, dynamic> map) {
    return PrescriptionDetailModel(
      detailId: map['detailId'] ?? 0,
      medicationId: map['medicationId']?.toString() ?? '',
      medicineName: map['medication'] != null ? map['medication']['medicineName']?.toString() ?? '' : '',
      quantity: map['quantity'] ?? 0,
      duration: map['duration'] ?? 0,
      note: map['note']?.toString() ?? '',
    );
  }
}
