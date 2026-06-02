import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/doctor_model.dart';
import '../constants/api_config.dart';

class DoctorService {
  static const String baseUrl = '${ApiConfig.baseUrl}/Doctor';

  Future<DoctorModel?> getDoctorProfile(String uid) async {
    try {
      final url = Uri.parse('$baseUrl/user/$uid');
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
        final doctor = DoctorModel.fromMap(data, uid);
        return doctor;
      } else {
        debugPrint('Failed to load doctor profile: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching doctor profile: $e');
      return null;
    }
  }

  Stream<DoctorModel?> watchDoctorProfile(String uid) async* {
    final profile = await getDoctorProfile(uid);
    yield profile;
  }

  Future<void> updateProfile(String uid, {
    String? fullName,
    String? specialty,
    String? clinicName,
    String? workStartTime,
    String? workEndTime,
    String? address,
    String? bio,
    String? avatarUrl,
  }) async {
    // Tạm thời chưa triển khai gọi hàm Update API
    debugPrint("Call update API for $uid");
  }
}
