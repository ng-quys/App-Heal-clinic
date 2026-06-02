import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/auth_service.dart';

class SetPasswordScreen extends StatefulWidget {
  final String phone;
  final String fullName;
  const SetPasswordScreen({
    required this.phone,
    required this.fullName,
    super.key,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Checklist yêu cầu mật khẩu (có thể làm động sau)
  final List<String> _requirements = [
    "Mật khẩu từ 8 ký tự trở lên",
    "Mật khẩu chứa ít nhất 1 chữ thường",
    "Mật khẩu chứa ít nhất 1 chữ hoa",
    "Mật khẩu chứa ít nhất 1 số",
    "Xác nhận mật khẩu trùng khớp"
  ];

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chào mừng đến với\nHEAL CLINIC",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Đặt mật khẩu mới",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),

              // Số điện thoại (readonly)
              const Text("Số điện thoại", style: TextStyle(fontWeight: FontWeight.w500)),
              TextField(
                controller: TextEditingController(text: widget.phone),
                enabled: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Mật khẩu
              const Text("Mật khẩu", style: TextStyle(fontWeight: FontWeight.w500)),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  hintText: "Nhập mật khẩu...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Nhập lại mật khẩu
              const Text("Nhập lại mật khẩu", style: TextStyle(fontWeight: FontWeight.w500)),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  hintText: "Nhập lại mật khẩu...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Checklist yêu cầu
              ..._requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(req, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              )),

              const SizedBox(height: 30),

              // Nút Xác nhận
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                    setState(() => _isLoading = true);

                    if (_passwordController.text != _confirmPasswordController.text) {
                      Fluttertoast.showToast(msg: "Mật khẩu xác nhận không khớp");
                      setState(() => _isLoading = false);
                      return;
                    }

                    if (_passwordController.text.length < 8) {
                      Fluttertoast.showToast(msg: "Mật khẩu phải từ 8 ký tự trở lên");
                      setState(() => _isLoading = false);
                      return;
                    }

                    final success = await _authService.register(
                      widget.phone.trim(),
                      _passwordController.text.trim(),
                      widget.fullName, // bạn có thể thêm fullName sau
                    );

                    setState(() => _isLoading = false);

                    if (success) {
                      Fluttertoast.showToast(msg: "Đăng ký thành công!");
                      Navigator.pushReplacementNamed(context, '/login');// hoặc '/login'
                    } else {
                      Fluttertoast.showToast(msg: "Đăng ký thất bại, thử lại sau");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Xác nhận", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}