import 'package:cargoind/core/services/api_service.dart';

class DmsApiService extends BaseApiService {
  // DMS specific endpoints
  static const String driverEndpoint = '/api/dms/drivers';
  static const String profileEndpoint = '/api/dms/profile';
  static const String documentsEndpoint = '/api/dms/documents';
  static const String verificationsEndpoint = '/api/dms/verifications';
  static const String trainingEndpoint = '/api/dms/training';
  static const String shiftsEndpoint = '/api/dms/shifts';
  static const String tripsEndpoint = '/api/dms/trips';
  static const String vehicleMatchingEndpoint = '/api/dms/vehicle-matching';

  // Common DMS operations
  Future<Map<String, dynamic>> getDmsDashboardData() async {
    return await makeRequest('GET', '/api/dms/dashboard');
  }
}