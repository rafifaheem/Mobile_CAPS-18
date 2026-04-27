import 'package:cargoind/modules/dms/models/driver.dart';
import 'package:cargoind/core/services/api_service.dart';

class DriverService extends BaseApiService {

  Future<List<Driver>> getDrivers() async {
    return await getList<Driver>('/api/drivers', Driver.fromJson);
  }

  Future<Driver> createDriver(Driver driver) async {
    return await create<Driver>('/api/drivers', driver.toJson(), Driver.fromJson);
  }

  Future<void> updateDriverStatus(int driverId, String action) async {
    await makeRequest('POST', '/api/drivers/$driverId/status');
  }

  Future<Map<String, dynamic>> submitDriverRegistration(Map<String, dynamic> data) async {
    // First register user
    await makeRequest('POST', '/api/register', {
      'username': data['email'],
      'email': data['email'],
      'password': data['password'],
    });

    // Create driver profile
    return await makeRequest('POST', '/api/drivers', {
      'nama_lengkap': data['nama_lengkap'],
      'no_telepon': data['no_telepon'],
      'alamat': data['alamat'],
      'no_ktp': data['no_ktp'],
      'kota': data['kota'],
      'status': 'PENDING',
    });
  }

  Future<Map<String, dynamic>> checkDriverStatus() async {
    try {
      final data = await makeRequest('GET', '/api/profile');
      return {'status': 'active', 'user': data};
    } catch (e) {
      return {'status': 'pending', 'rejected_documents': []};
    }
  }

  Future<Map<String, dynamic>> getDriverStatistics() async {
    return await makeRequest('GET', '/api/driver/statistics');
  }

  Future<Map<String, dynamic>> getDriverProfile() async {
    return await makeRequest('GET', '/api/my-profile');
  }

  Future<Map<String, dynamic>> updateDriverProfile(Map<String, dynamic> data) async {
    final profile = await getDriverProfile();
    final driverId = profile['id_driver'] ?? profile['id'];
    return await makeRequest('PUT', '/api/drivers/$driverId', data);
  }

  Future<Map<String, dynamic>> updateRejectedDocuments(Map<String, dynamic> data) async {
    return await makeRequest('POST', '/api/drivers/update-documents', data);
  }

  Future<Map<String, dynamic>> completeRejectedDocuments() async {
    return await makeRequest('POST', '/api/drivers/complete-documents');
  }

  Future<List<dynamic>> getDriverTrips() async {
    return await makeRequest('GET', '/api/my-orders');
  }

  Future<bool> sendVerificationCode(String method, String contact) async {
    try {
      await makeRequest('POST', '/verification/send-code/', {
        'method': method,
        'contact': contact
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyCode(String code, String method, String contact) async {
    try {
      await makeRequest('POST', '/verification/verify-code/', {
        'code': code,
        'method': method,
        'contact': contact
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}