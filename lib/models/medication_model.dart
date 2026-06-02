class MedicationModel {
  final String medicationId;
  final String medicineName;
  final double dosage;
  final String unit;
  final double price;
  final bool isCover;

  MedicationModel({
    required this.medicationId,
    required this.medicineName,
    required this.dosage,
    required this.unit,
    required this.price,
    required this.isCover,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      medicationId: map['medicationId']?.toString() ?? '',
      medicineName: map['medicineName']?.toString() ?? '',
      dosage: (map['dosage'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      isCover: map['isCover'] == true || map['isCover'] == 1,
    );
  }
}
