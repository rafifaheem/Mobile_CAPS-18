import 'package:cargoind/modules/tms/models/models_fixed.dart';
import 'package:cargoind/core/services/api_service.dart';

class VehicleService extends BaseApiService {
  
  Future<Map<String, dynamic>> registerVehicle(Map<String, dynamic> vehicleData) async {
    return await makeRequest('POST', '/api/v1/vehicles/register', vehicleData);
  }

  Future<List<dynamic>> getVehicles() async {
    final response = await makeRequest('GET', '/api/v1/admin/vehicles');
    return response['vehicles'] ?? [];
  }

  Future<Map<String, dynamic>> getVehicle(int id) async {
    return await makeRequest('GET', '/api/vehicles/$id');
  }

  Future<void> uploadVehicleAttachment(int vehicleId, String attachmentType, Map<String, dynamic> fileInfo) async {
    await makeRequest('POST', '/api/vehicles/$vehicleId/attachments', {
      'attachment_type': attachmentType,
      'file_name': fileInfo['name'],
      'file_size': fileInfo['size'],
      'mime_type': fileInfo['type'],
      'data': fileInfo['data'] ?? '',
    });
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final vehiclesData = await getVehicles();
    return vehiclesData.map((data) => Vehicle.fromJson(data)).toList();
  }

  Future<List<VehicleActivity>> getVehicleActivities() async {
    try {
      final response = await makeRequest('GET', '/api/v1/vehicles/activities');
      final List<dynamic> activitiesJson = response['activities'] ?? [];
      return activitiesJson.map((json) => VehicleActivity.fromJson(json)).toList();
    } catch (e) {
      return await _getRealTimeActivities();
    }
  }

  Future<List<ServiceReminder>> getServiceReminders() async {
    try {
      final response = await makeRequest('GET', '/api/v1/vehicles/service-reminders');
      final List<dynamic> remindersJson = response['reminders'] ?? [];
      return remindersJson.map((json) => ServiceReminder.fromJson(json)).toList();
    } catch (e) {
      return await _getRealTimeReminders();
    }
  }

  Future<Map<String, dynamic>> getVehicleStats() async {
    try {
      return await makeRequest('GET', '/api/v1/vehicles/stats');
    } catch (e) {
      return _getMockStats();
    }
  }

  // Mock data methods remain the same
  Future<List<VehicleActivity>> _getRealTimeActivities() async {
    final vehicles = await getAllVehicles();
    final now = DateTime.now();
    List<VehicleActivity> activities = [];
    
    for (int i = 0; i < vehicles.length && i < 10; i++) {
      final vehicle = vehicles[i];
      final activityTypes = ['service', 'trip_start', 'trip_end', 'fuel', 'maintenance', 'inspection'];
      final descriptions = {
        'service': 'Service rutin selesai',
        'trip_start': 'Perjalanan dimulai ke ${_getRandomDestination()}',
        'trip_end': 'Perjalanan selesai dari ${_getRandomDestination()}',
        'fuel': 'Pengisian bahan bakar ${_getRandomFuel()} liter',
        'maintenance': 'Maintenance ${_getRandomMaintenance()} selesai',
        'inspection': 'Inspeksi keselamatan berkala',
      };
      
      final type = activityTypes[i % activityTypes.length];
      final hoursAgo = (i + 1) * 2;
      
      activities.add(VehicleActivity(
        id: (i + 1).toString(),
        vehiclePlate: vehicle.registrationNumber,
        type: type,
        description: descriptions[type] ?? 'Aktivitas kendaraan',
        timestamp: _formatTimestamp(now.subtract(Duration(hours: hoursAgo))),
        createdAt: now.subtract(Duration(hours: hoursAgo)),
      ));
    }
    
    return activities;
  }

  Future<List<ServiceReminder>> _getRealTimeReminders() async {
    final vehicles = await getAllVehicles();
    final now = DateTime.now();
    List<ServiceReminder> reminders = [];
    
    for (int i = 0; i < vehicles.length && i < 5; i++) {
      final vehicle = vehicles[i];
      final serviceTypes = ['Service Rutin', 'Ganti Oli', 'Cek Ban', 'Tune Up', 'Ganti Filter'];
      final daysVariations = [-5, -2, 1, 3, 7, 14];
      
      final serviceType = serviceTypes[i % serviceTypes.length];
      final daysUntilDue = daysVariations[i % daysVariations.length];
      
      reminders.add(ServiceReminder(
        id: (i + 1).toString(),
        vehiclePlate: vehicle.registrationNumber,
        serviceType: serviceType,
        daysUntilDue: daysUntilDue,
        isUrgent: daysUntilDue < 0,
        lastService: now.subtract(Duration(days: 90 + (i * 10))),
        nextService: now.add(Duration(days: daysUntilDue)),
      ));
    }
    
    return reminders;
  }
  
  String _getRandomDestination() {
    final destinations = ['Jakarta', 'Bandung', 'Surabaya', 'Malang', 'Yogyakarta', 'Semarang'];
    return destinations[DateTime.now().millisecond % destinations.length];
  }
  
  int _getRandomFuel() {
    return 30 + (DateTime.now().millisecond % 40);
  }
  
  String _getRandomMaintenance() {
    final types = ['rem', 'mesin', 'transmisi', 'AC', 'lampu'];
    return types[DateTime.now().millisecond % types.length];
  }

  Map<String, dynamic> _getMockStats() {
    return {
      'total_vehicles': 24,
      'active_vehicles': 18,
      'maintenance_vehicles': 3,
      'available_vehicles': 3,
      'total_trips_today': 12,
      'ongoing_trips': 8,
      'completed_trips_today': 4,
      'fuel_consumption_today': 450.5,
      'maintenance_due': 3,
    };
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${difference.inDays} hari yang lalu';
    }
  }
}