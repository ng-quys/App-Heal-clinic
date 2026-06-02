import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  State<RegisterPhoneScreen> createState() =>
      _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState
    extends State<RegisterPhoneScreen> {

  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _agree = false;
  bool _isLoading = false;

  bool get _canSubmit {
    return _emailController.text.trim().isNotEmpty &&
        _fullNameController.text.trim().isNotEmpty &&
        _agree &&
        !_isLoading;
  }

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: "Vui lòng nhập email",
      );
      return;
    }

    // Validate Email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email)) {
      Fluttertoast.showToast(
        msg: "Email không hợp lệ",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success =
      await _authService.sendOtp(email);

      if (!mounted) return;

      if (success) {
        Fluttertoast.showToast(
          msg: "Mã OTP giả lập đã được gửi!",
        );

        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {
            'phone': email, // Giữ key phone để các màn sau khỏi lỗi
            'fullName': _fullNameController.text.trim(),
          },
        );
      } else {
        Fluttertoast.showToast(
          msg: "Gửi OTP thất bại",
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Lỗi kết nối server",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng ký"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const Text(
              "Chào mừng đến với\nHEAL CLINIC",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Tạo tài khoản mới",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 40),

            //FullName
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _fullNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF00AEEF),
                  ),
                  hintText: "Nhập họ và tên",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),

            // EMAIL
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Color(0xFF00AEEF),
                  ),
                  hintText: "Nhập email",
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // TERMS
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _agree,
                  activeColor:
                  const Color(0xFF00AEEF),
                  onChanged: (value) {
                    setState(() {
                      _agree = value ?? false;
                    });
                  },
                ),

                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      "Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                _canSubmit ? _sendOtp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF00AEEF),
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  "Tiếp tục",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/login',
                  );
                },
                child: const Text(
                  "Đã có tài khoản? Đăng nhập",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}