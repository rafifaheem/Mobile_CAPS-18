import 'package:cargoind/core/services/api_service.dart';

class TmsApiService extends BaseApiService {
  // TMS specific endpoints
  static const String vehicleEndpoint = '/api/tms/vehicles';
  static const String driverEndpoint = '/api/tms/drivers';
  static const String tripEndpoint = '/api/tms/trips';
  static const String routeEndpoint = '/api/tms/routes';
  static const String trackingEndpoint = '/api/tms/tracking';
  static const String maintenanceEndpoint = '/api/tms/maintenance';
  static const String gpsEndpoint = '/api/tms/gps';
  static const String orderEndpoint = '/api/tms/orders';
  static const String shipmentEndpoint = '/api/tms/shipments';

  // Common TMS operations
  Future<Map<String, dynamic>> getTmsDashboardData() async {
    return await makeRequest('GET', '/api/tms/dashboard');
  }
}