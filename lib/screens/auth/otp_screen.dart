import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String fullName;
  const OtpScreen({
    required this.phone,
    required this.fullName,
    super.key,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = "";
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quay lại"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Xác thực OTP",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Chúng tôi đã gửi mã OTP đến\n${widget.phone}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),

            // ================== PINPUT (OTP) ==================
            Pinput(
              length: 6,
              onCompleted: (pin) => _otp = pin,
              defaultPinTheme: PinTheme(
                width: 56,
                height: 60,
                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 56,
                height: 60,
                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              showCursor: true,
              keyboardType: TextInputType.number,
            ),
            // ==================================================

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                  if (_otp.length != 6) {
                    Fluttertoast.showToast(msg: "Vui lòng nhập đủ 6 số OTP");
                    return;
                  }

                  setState(() => _isLoading = true);

                  final success = await _authService.verifyOtp(widget.phone, _otp);

                  setState(() => _isLoading = false);

                  if (success) {
                    Fluttertoast.showToast(msg: "Xác thực OTP thành công!");
                    Navigator.pushNamed(
                      context,
                      '/set-password',
                      arguments: {
                        'phone': widget.phone,
                        'fullName': widget.fullName,
                      },
                    );
                  } else {
                    Fluttertoast.showToast(msg: "OTP không đúng hoặc đã hết hạn");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Xác nhận OTP", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}