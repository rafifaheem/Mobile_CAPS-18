import 'package:cargoind/core/services/api_service.dart';
import 'package:cargoind/modules/tms/models/tms_models.dart';

class ApiService extends BaseApiService {
  static Future<DashboardStats> getDashboardStats() async {
    try {
      final service = ApiService();
      final response =
          await service.makeRequest('GET', '/api/tms/dashboard/stats');
      return DashboardStats.fromJson(response['data'] ?? {});
    } catch (e) {
      // Return mock data if API fails
      return DashboardStats(
        totalVehicles: 24,
        activeVehicles: 18,
        totalDrivers: 15,
        activeDrivers: 12,
        totalTrips: 45,
        ongoingTrips: 8,
        completedTrips: 37,
        totalDistance: 1250.5,
        maintenanceDue: 3,
      );
    }
  }

  static Future<List<Vehicle>> getVehicles() async {
    try {
      final service = ApiService();
      final response = await service.makeRequest('GET', '/api/tms/vehicles');
      final List<dynamic> vehiclesJson = response['data'] ?? [];
      return vehiclesJson.map((json) => Vehicle.fromJson(json)).toList();
    } catch (e) {
      // Return mock data if API fails
      return [
        Vehicle(
          id: 1,
          registrationNumber: 'B 1234 ABC',
          vehicleType: 'Truck',
          brand: 'Mitsubishi',
          model: 'Canter',
          year: 2020,
          operationalStatus: 'active',
        ),
        Vehicle(
          id: 2,
          registrationNumber: 'B 5678 DEF',
          vehicleType: 'Van',
          brand: 'Toyota',
          model: 'Hiace',
          year: 2019,
          operationalStatus: 'maintenance',
        ),
        Vehicle(
          id: 3,
          registrationNumber: 'B 9012 GHI',
          vehicleType: 'Truck',
          brand: 'Isuzu',
          model: 'Elf',
          year: 2021,
          operationalStatus: 'active',
        ),
      ];
    }
  }

  static Future<List<Trip>> getTrips() async {
    try {
      final service = ApiService();
      final response = await service.makeRequest('GET', '/api/tms/trips');
      final List<dynamic> tripsJson = response['data'] ?? [];
      return tripsJson.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      // Return mock data if API fails
      return [
        Trip(
          id: 1,
          driverId: 1,
          vehicleId: 1,
          origin: 'Jakarta',
          destination: 'Bandung',
          status: 'ongoing',
          distance: 150.0,
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        Trip(
          id: 2,
          driverId: 2,
          vehicleId: 2,
          origin: 'Surabaya',
          destination: 'Malang',
          status: 'completed',
          distance: 90.0,
          createdAt: DateTime.now().subtract(Duration(hours: 5)),
        ),
      ];
    }
  }

  static Future<List<VehicleActivity>> getVehicleActivities() async {
    try {
      final service = ApiService();
      final response =
          await service.makeRequest('GET', '/api/tms/vehicle-activities');
      final List<dynamic> activitiesJson = response['activities'] ?? [];
      return activitiesJson
          .map((json) => VehicleActivity.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock data if API fails
      final now = DateTime.now();
      return [
        VehicleActivity(
          id: '1',
          vehiclePlate: 'B 1234 ABC',
          type: 'trip_start',
          description: 'Perjalanan dimulai ke Bandung',
          timestamp: '2 jam yang lalu',
          createdAt: now.subtract(Duration(hours: 2)),
        ),
        VehicleActivity(
          id: '2',
          vehiclePlate: 'B 5678 DEF',
          type: 'maintenance',
          description: 'Service rutin selesai',
          timestamp: '4 jam yang lalu',
          createdAt: now.subtract(Duration(hours: 4)),
        ),
      ];
    }
  }

  static Future<List<ServiceReminder>> getServiceReminders() async {
    try {
      final service = ApiService();
      final response =
          await service.makeRequest('GET', '/api/tms/service-reminders');
      final List<dynamic> remindersJson = response['reminders'] ?? [];
      return remindersJson
          .map((json) => ServiceReminder.fromJson(json))
          .toList();
    } catch (e) {
      // Return mock data if API fails
      final now = DateTime.now();
      return [
        ServiceReminder(
          id: '1',
          vehiclePlate: 'B 1234 ABC',
          serviceType: 'Ganti Oli',
          daysUntilDue: 3,
          isUrgent: false,
          lastService: now.subtract(Duration(days: 87)),
          nextService: now.add(Duration(days: 3)),
        ),
        ServiceReminder(
          id: '2',
          vehiclePlate: 'B 5678 DEF',
          serviceType: 'Service Rutin',
          daysUntilDue: -2,
          isUrgent: true,
          lastService: now.subtract(Duration(days: 92)),
          nextService: now.subtract(Duration(days: 2)),
        ),
      ];
    }
  }

  static Future<Map<String, dynamic>> getVehicleStats() async {
    try {
      final service = ApiService();
      final response =
          await service.makeRequest('GET', '/api/tms/vehicle-stats');
      return response['data'] ?? {};
    } catch (e) {
      // Return mock data if API fails
      return {
        'active_vehicles': 18,
        'maintenance_vehicles': 3,
        'available_vehicles': 15,
        'total_trips_today': 12,
        'ongoing_trips': 5,
        'fuel_consumption_today': 245.8,
      };
    }
  }
}
