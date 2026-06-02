import 'package:flutter/material.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/register_phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/set_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/doctor_view/dashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HEAL CLINIC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',           // Bắt đầu từ màn hình Welcome
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterPhoneScreen(),
        '/otp': (context) {
          final args =
          ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return OtpScreen(
            phone: args['phone'],
            fullName: args['fullName'],
          );
        },
        '/set-password': (context) {
          final args =
          ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return SetPasswordScreen(
            phone: args['phone'],
            fullName: args['fullName'],
          );
        },
        '/login': (context) => const LoginScreen(),
        '/home_D': (context) => const DoctorHomeScreen(),
      },
    );
  }
}
