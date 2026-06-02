import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/patient_model.dart';
import '../constants/api_config.dart';

class PatientRepository {
  static const String baseUrl = '${ApiConfig.baseUrl}/Patient';

  Future<PatientModel?> getPatientById(String id) async {
    try {
      final url = Uri.parse('$baseUrl/$id');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PatientModel.fromMap(data, id);
      } else {
        debugPrint('Failed to load patient: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching patient: $e');
      return null;
    }
  }
}
