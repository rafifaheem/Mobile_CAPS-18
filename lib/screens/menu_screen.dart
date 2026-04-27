import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/screens/dashboard_screen.dart' as wms;
import 'package:cargoind/modules/dms/screens/main_screen.dart' as dms;
import 'package:cargoind/modules/tms/screens/dashboard_screen.dart' as tms;

class MenuRoute extends StatelessWidget {
  final String username;
  const MenuRoute({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // Warna khusus hanya untuk halaman ini
    final Color primaryColor = Colors.red; 
    final Color backgroundColor = Colors.white;
    final Color buttonColor = Colors.redAccent;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Menu Route')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: const Text('Warehouse Route'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const wms.DashboardScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Drive Route'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => dms.MainScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
               ElevatedButton(
                child: const Text('Transportation Route'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const tms.DashboardScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
