import 'package:flutter/material.dart';
import 'package:cargoind/modules/dms/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cargoind/modules/dms/models/driver.dart';
import 'package:cargoind/modules/dms/services/api_service.dart';


class DriverListScreen extends StatefulWidget {
  @override
  _DriverListScreenState createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  List<Driver> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDrivers();
  }

  Future<void> loadDrivers() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final loadedDrivers = await apiService.getDrivers();
      setState(() {
        drivers = loadedDrivers.map((data) => Driver.fromJson(data)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading drivers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Management - ${user?.role.toUpperCase()}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(driver.name),
                    subtitle: Text('${driver.licenseNumber} - ${driver.status}'),
                    trailing: user?.isAdmin == true ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (driver.status != 'active')
                          IconButton(
                            icon: Icon(Icons.play_arrow, color: Colors.green),
                            onPressed: () => updateStatus(driver.id, 'activate'),
                          ),
                        if (driver.status == 'active')
                          IconButton(
                            icon: Icon(Icons.pause, color: Colors.orange),
                            onPressed: () => updateStatus(driver.id, 'suspend'),
                          ),
                      ],
                    ) : null,
                  ),
                );
              },
            ),
      floatingActionButton: user?.isAdmin == true ? FloatingActionButton(
        onPressed: () {
          // Navigate to add driver screen
        },
        child: Icon(Icons.add),
      ) : null,
    );
  }

  Future<void> updateStatus(int driverId, String action) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.updateDriverStatus(driverId.toString(), action);
      loadDrivers(); // Reload the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating driver: $e')),
      );
    }
  }
}