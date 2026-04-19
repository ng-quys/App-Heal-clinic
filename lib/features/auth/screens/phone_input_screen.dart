import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_verification_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _authService = AuthService();
  final _phoneController = TextEditingController(text: '+84');
  final _fullNameController = TextEditingController();

  bool _isLogin = true; // true = Đăng nhập, false = Đăng ký
  bool _isLoading = false;

  // ====================== SỬA Ở ĐÂY ======================
  void _sendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.length < 10 || !phone.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại hợp lệ (bắt đầu bằng +84)')),
      );
      return;
    }

    if (!_isLogin && _fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập họ và tên')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _authService.sendOtp(
      phoneNumber: phone,
      onCodeSent: (String verificationId) {           // ← Đảm bảo có kiểu String
        setState(() => _isLoading = false);

        if (verificationId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không nhận được Verification ID. Vui lòng thử lại!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Navigate sang màn hình OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phone: phone,
              verificationId: verificationId,   // ← verificationId chắc chắn không null
              isLogin: _isLogin,
              fullName: _isLogin ? '' : _fullNameController.text.trim(),
            ),
          ),
        );
      },
      onError: (String error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      },
    );
  }
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Image.asset('assets/images/heal_logo.png', height: 60),
            const SizedBox(height: 20),
            const Text(
              'HEAL CLINIC',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 40),

            Text(
              _isLogin ? 'Đăng nhập' : 'Đăng ký',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            if (!_isLogin) ...[
              const Text('Họ và tên', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Nhập họ và tên...',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text('Số điện thoại', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+84 123 456 789',
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  _isLogin ? 'Gửi mã OTP' : 'Tiếp tục đăng ký',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? 'Chưa có tài khoản? Đăng ký' : 'Đã có tài khoản? Đăng nhập',
                style: const TextStyle(color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}