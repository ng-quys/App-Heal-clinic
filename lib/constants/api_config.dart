class ApiConfig {
  static const String domain = 'h2rcgtcl-37214.asse.devtunnels.ms';
  static const String baseUrl = 'https://$domain/api';

  static const String appointmentUrl = '$baseUrl/Appointment';
  static const String medicalRecordUrl = '$baseUrl/MedicalRecord';
  static const String doctorUrl = '$baseUrl/Doctor';
  static const String medicationUrl = '$baseUrl/Medication';
  static const String serviceUrl = '$baseUrl/Service';

  // SignalR Hub URL
  static const String queueHubUrl = 'https://$domain/queueHub';
}
