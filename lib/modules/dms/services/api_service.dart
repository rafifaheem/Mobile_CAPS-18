import 'package:cargoind/core/services/api_service.dart';

class ApiService extends BaseApiService {
  ApiService();
  
  // DMS specific methods
  Future<Map<String, dynamic>> getDriverStatistics() async {
    return await makeRequest('GET', '/api/dms/driver/statistics');
  }
  
  Future<List<dynamic>> getDriverTrips() async {
    final response = await makeRequest('GET', '/api/dms/driver/trips');
    return response['data'] ?? [];
  }
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    return await makeRequest('GET', endpoint);
  }
  
  Future<bool> sendVerificationCode(String method, String contact) async {
    final response = await makeRequest('POST', '/api/dms/verification/send', {
      'method': method,
      'contact': contact
    }, false); // No auth required
    return response['success'] ?? false;
  }
  
  Future<bool> verifyCode(String code, String method, String contact) async {
    final response = await makeRequest('POST', '/api/dms/verification/verify', {
      'code': code,
      'method': method,
      'contact': contact
    }, false); // No auth required
    return response['success'] ?? false;
  }
  
  Future<Map<String, dynamic>> submitDriverRegistration(Map<String, dynamic> data) async {
    // This method is called after verification, so we don't need to register again
    // Just return success since the driver was already registered during initial registration
    return {'success': true, 'message': 'Driver registration completed'};
  }
  
  Future<bool> loginDriver(String email, String password) async {
    try {
      final response = await makeRequest('POST', '/api/auth/login', {
        'email': email,
        'password': password
      }, false); // No auth required for login
      return response['success'] ?? false;
    } catch (e) {
      print('Login driver error: $e');
      return false;
    }
  }
  
  Future<void> updateDriverProfile(Map<String, dynamic> data) async {
    await makeRequest('PUT', '/api/dms/driver/profile', data);
  }
  
  Future<void> updateRejectedDocuments(Map<String, dynamic> data) async {
    await makeRequest('PUT', '/api/dms/driver/documents/rejected', data);
  }
  
  Future<Map<String, dynamic>> checkDriverStatus() async {
    return await makeRequest('GET', '/api/dms/driver/status');
  }
  
  Future<List<dynamic>> getDrivers() async {
    final response = await makeRequest('GET', '/api/dms/drivers');
    return response['data'] ?? [];
  }
  
  Future<void> updateDriverStatus(String driverId, String status) async {
    await makeRequest('PUT', '/api/dms/driver/$driverId/status', {'status': status});
  }
  
  Future<Map<String, dynamic>> getDriverProfile() async {
    return await makeRequest('GET', '/api/dms/driver/profile');
  }
  
  Future<void> completeRejectedDocuments(Map<String, dynamic> data) async {
    await makeRequest('POST', '/api/dms/driver/documents/complete', data);
  }
  
  Future<List<dynamic>> searchOrdersByLocation(double latitude, double longitude, {double radiusKm = 5.0}) async {
    final endpoint = '/api/dms/orders/search?latitude=$latitude&longitude=$longitude&radius=$radiusKm';
    final response = await makeRequest('GET', endpoint);
    return response['data']['orders'] ?? [];
  }
}