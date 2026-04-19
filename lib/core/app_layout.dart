import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import 'theme.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;

  // Danh sách các màn hình sẽ dùng Bottom Navigation
  final List<Widget> _screens = [
    const Placeholder(child: Center(child: Text('Trang chủ', style: TextStyle(fontSize: 30)))),
    const Placeholder(child: Center(child: Text('Đặt khám', style: TextStyle(fontSize: 30)))),
    const Placeholder(child: Center(child: Text('Thanh toán', style: TextStyle(fontSize: 30)))),
    const Placeholder(child: Center(child: Text('Hóa đơn', style: TextStyle(fontSize: 30)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Đặt khám',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_rounded),
            label: 'Thanh toán',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Hóa đơn',
          ),
        ],
      ),
    );
  }
}