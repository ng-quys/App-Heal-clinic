import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/medical_record_model.dart';
import '../constants/api_config.dart';

class MedicalRecordService {
  static const String baseUrl = '${ApiConfig.baseUrl}/MedicalRecord';

  Future<bool> checkout(Map<String, dynamic> checkoutData) async {
    try {
      final url = Uri.parse('$baseUrl/checkout');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
        body: jsonEncode(checkoutData),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Checkout failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error during checkout: $e');
      return false;
    }
  }

  Future<MedicalRecordModel?> getMedicalRecordByAppointmentId(String appointmentId) async {
    try {
      final url = Uri.parse('$baseUrl/appointment/$appointmentId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MedicalRecordModel.fromMap(data);
      } else {
        debugPrint('Medical record not found for this appointment: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching medical record: $e');
      return null;
    }
  }
}
