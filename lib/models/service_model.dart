class ServiceModel {
  final String serviceId;
  final String serviceName;
  final double price;
  final String department;
  final bool isCover;

  ServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.department,
    required this.isCover,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      serviceId: map['serviceId']?.toString() ?? '',
      serviceName: map['serviceName']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      department: map['department']?.toString() ?? '',
      isCover: map['isCover'] == true || map['isCover'] == 1,
    );
  }
}
