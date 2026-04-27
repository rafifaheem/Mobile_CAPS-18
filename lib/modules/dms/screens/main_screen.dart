import 'package:flutter/material.dart';
import 'package:cargoind/modules/dms/screens/new_dashboard_screen.dart';
import 'package:cargoind/modules/dms/screens/trips_screen.dart';
import 'package:cargoind/modules/dms/screens/vehicle_screen.dart';
import 'package:cargoind/modules/dms/screens/find_order_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      NewDashboardScreen(),
      TripsScreen(),
      VehicleScreen(),
      FindOrderScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Perjalanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Kendaraan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: 'Cari Order',
          ),
        ],
      ),
    );
  }
}