import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cargoind/modules/tms/models/tms_models.dart';
import 'package:cargoind/modules/tms/services/api_service.dart';

class VehicleMonitoringScreen extends StatefulWidget {
  const VehicleMonitoringScreen({super.key});

  @override
  State<VehicleMonitoringScreen> createState() => _VehicleMonitoringScreenState();
}

class _VehicleMonitoringScreenState extends State<VehicleMonitoringScreen> {
  List<Vehicle> vehicles = [];
  bool isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      vehicles = await ApiService.getVehicles();
    } catch (e) {
      print('Error loading data: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Kendaraan'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVehicleStatusGrid(),
                  const SizedBox(height: 20),
                  _buildVehicleList(),
                ],
              ),
            ),
    );
  }

  Widget _buildVehicleStatusGrid() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getVehicleStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};
        final activeVehicles = stats['active_vehicles'] ?? 0;
        final inServiceVehicles = stats['maintenance_vehicles'] ?? 0;
        final availableVehicles = stats['available_vehicles'] ?? 0;
        final totalTrips = stats['total_trips_today'] ?? 0;
        final ongoingTrips = stats['ongoing_trips'] ?? 0;
        final fuelConsumption = stats['fuel_consumption_today'] ?? 0.0;

        return _buildStatusGridContent(
          activeVehicles,
          inServiceVehicles,
          availableVehicles,
          totalTrips,
          ongoingTrips,
          fuelConsumption,
        );
      },
    );
  }

  Widget _buildStatusGridContent(int activeVehicles, int inServiceVehicles, int availableVehicles,
      int totalTrips, int ongoingTrips, double fuelConsumption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Kendaraan & Aktivitas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'Aktif',
                activeVehicles.toString(),
                Icons.directions_car,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Service',
                inServiceVehicles.toString(),
                Icons.build,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Tersedia',
                availableVehicles.toString(),
                Icons.check_circle,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'Trip Hari Ini',
                totalTrips.toString(),
                Icons.route,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Sedang Jalan',
                ongoingTrips.toString(),
                Icons.navigation,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'BBM (L)',
                fuelConsumption.toStringAsFixed(1),
                Icons.local_gas_station,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.list),
                SizedBox(width: 8),
                Text(
                  'Daftar Kendaraan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vehicles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(vehicle.operationalStatus).withValues(alpha:0.2),
                  child: Icon(
                    Icons.directions_car,
                    color: _getStatusColor(vehicle.operationalStatus),
                  ),
                ),
                title: Text(vehicle.registrationNumber),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${vehicle.brand} ${vehicle.model}'),
                    Text(
                      _getStatusText(vehicle.operationalStatus),
                      style: TextStyle(
                        color: _getStatusColor(vehicle.operationalStatus),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'detail',
                      child: Row(
                        children: [
                          Icon(Icons.info),
                          SizedBox(width: 8),
                          Text('Detail'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'service',
                      child: Row(
                        children: [
                          Icon(Icons.build),
                          SizedBox(width: 8),
                          Text('Jadwal Service'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text('Riwayat'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleVehicleAction(vehicle, value.toString()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'available':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Sedang Beroperasi';
      case 'maintenance':
        return 'Dalam Service';
      case 'available':
        return 'Tersedia';
      default:
        return 'Tidak Diketahui';
    }
  }

  void _handleVehicleAction(Vehicle vehicle, String action) {
    switch (action) {
      case 'detail':
        break;
      case 'service':
        _scheduleVehicleService(vehicle);
        break;
      case 'history':
        break;
    }
  }

  void _scheduleVehicleService(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Jadwal Service - ${vehicle.registrationNumber}'),
        content: const Text('Fitur penjadwalan service akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
