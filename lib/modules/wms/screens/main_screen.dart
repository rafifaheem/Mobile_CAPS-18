import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import 'dashboard_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';

class WMSMainScreen extends StatefulWidget {
  final String? username;
  
  const WMSMainScreen({super.key, this.username});

  @override
  State<WMSMainScreen> createState() => _WMSMainScreenState();
}

class _WMSMainScreenState extends State<WMSMainScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(username: widget.username),
      const NotificationScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.grey500,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}