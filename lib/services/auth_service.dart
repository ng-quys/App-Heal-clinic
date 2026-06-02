import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_config.dart';

class AuthService {
  // Đã cập nhật IP của máy tính (192.168.1.66) để bạn test trên điện thoại thật
  static const String baseUrl = '${ApiConfig.baseUrl}/User';

  Future<bool> sendOtp(String email) async {
    // Không khả dụng trong Backend mới, return true giả lập
    return true;
  }

  Future<bool> verifyOtp(String email, String otp) async {
    // Không khả dụng trong Backend mới, return true giả lập
    return true;
  }

  Future<bool> register(
      String email,
      String password,
      String fullName,
      ) async {
    try {
      final url = Uri.parse('$baseUrl?fullName=$fullName');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'passWord': password,
          'role': 'P', // Mặc định là Patient
        }),
      );

      print("URL: $url");
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Register failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }


  Future<bool> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login?email=$email&password=$password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Tunnel-Skip-AntiPhishing-Page': 'true',
          'ngrok-skip-browser-warning': 'true'
        },
      ).timeout(const Duration(seconds: 10));

      print("URL: $url");
      print("Email: $email");
      print("Password: $password");
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          // Không có Token JWT, dùng tạm userId làm token xác thực lưu local
          await prefs.setString('token', user['userId'].toString().trim());
          await prefs.setString('role', user['role']?.toString().trim() ?? 'P');

          return true;
        }
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }
}
