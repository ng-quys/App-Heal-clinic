import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../constants/api_config.dart';

class ServiceApiService {
  static const String baseUrl = '${ApiConfig.baseUrl}/Service';

  Future<List<ServiceModel>> getServices() async {
    try {
      final url = Uri.parse(baseUrl);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ServiceModel.fromMap(item)).toList();
      } else {
        debugPrint('Failed to load services: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error getting services: $e');
      return [];
    }
  }
}
