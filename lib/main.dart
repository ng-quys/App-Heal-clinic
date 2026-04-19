import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/auth/screens/phone_input_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,   // ← Quan trọng
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heal Clinic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',           // hoặc font bạn đang dùng
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const AuthWrapper(),        // ← Quan trọng nhất
      routes: {
        '/home': (context) => const MainHomeScreen(),   // Thay bằng màn hình chính của bạn
        // '/login': (context) => const PhoneInputScreen(), // không cần vì dùng wrapper
      },
    );
  }
}

// ====================== AUTH WRAPPER ======================
// Đây là phần quyết định người dùng đã đăng nhập chưa hay chưa

// Thay thế phần AuthWrapper hiện tại bằng cái này:

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Nếu đã đăng nhập → vào Home
        if (snapshot.hasData) {
          return const MainHomeScreen();
        }

        // Chưa đăng nhập → vào màn hình nhập phone
        return const PhoneInputScreen();
      },
    );
  }
}

// ====================== MÀN HÌNH CHÍNH (placeholder) ======================
class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heal Clinic - Home')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng bạn đến với Heal Clinic!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text('Bạn đã đăng nhập thành công bằng số điện thoại'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AuthService().signOut();
          // Sau khi signOut, StreamBuilder sẽ tự động chuyển về PhoneInputScreen
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}