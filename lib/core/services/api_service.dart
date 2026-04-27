import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cargoind/core/services/auth_service.dart';
import 'package:cargoind/core/config/api_config.dart';
import 'package:cargoind/core/exceptions/api_exception.dart';
import 'package:uuid/uuid.dart';

abstract class BaseApiService {
  final AuthService _authService = AuthService();
  
  Future<String> get baseUrl async {
    final url = await ApiConfig.getAutoDetectedBaseUrl();
    return url;
  }

  Future<Map<String, String>> getHeaders([bool requireAuth = true]) async {
    final headers = {'Content-Type': 'application/json'};
    
    if (requireAuth) {
      final token = await _authService.getToken();
      print('🔧 Retrieved token: ${token?.substring(0, 20)}...');
      if (token == null) {
        throw ApiException('Authentication required. Please login again.', 401);
      }
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  void _handleError(int statusCode, String body) {
    String errorMessage;
    try {
      final errorData = json.decode(body);
      errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
    } catch (e) {
      errorMessage = body.isNotEmpty ? body : 'Unknown error';
    }
    
    switch (statusCode) {
      case 401:
        throw ApiException('Authentication failed. Please login again.', statusCode);
      case 403:
        throw ApiException('Access denied.', statusCode);
      case 404:
        throw ApiException('Resource not found (status 404): $errorMessage', statusCode);
      case 422:
        throw ApiException('Validation error: $errorMessage', statusCode);
      case 500:
        throw ApiException('Server error: $errorMessage', statusCode);
      default:
        throw ApiException('Request failed (status $statusCode): $errorMessage', statusCode);
    }
  }

  String generateUuid(){
    final uuid = Uuid();
    return uuid.v7();
  }

  Future<dynamic> makeRequest(String method, String endpoint, [Map<String, dynamic>? body, bool requireAuth = true]) async {
    final headers = await getHeaders(requireAuth);
    final currentBaseUrl = await baseUrl;
    final uri = Uri.parse('$currentBaseUrl$endpoint');
    
    print('🔧 $method $uri');
    print('🔧 Headers: $headers');
    if (body != null) print('🔧 Body: $body');
    
    try {
      http.Response response;
      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      
      print('🔧 Response status: ${response.statusCode}');
      print('🔧 Response body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? json.decode(response.body) : {};
      } else {
        _handleError(response.statusCode, response.body);
      }
    } catch (e) {
      print('🔧 Request error: $e');
      throw Exception('Request failed: $e');
    }
  }

  Future<List<T>> getList<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final response = await makeRequest('GET', endpoint);
    
    // Handle different response structures
    dynamic data;
    if (response is List) {
      // Direct array response
      data = response;
    } else if (response is Map<String, dynamic>) {
      // Check for nested data structure (data.data)
      if (response['data'] is Map<String, dynamic> && response['data']['data'] is List) {
        data = response['data']['data'];
      } else if (response['data'] is List) {
        // Object with data field as array
        data = response['data'];
      } else if (response['data'] != null) {
        // Single object in data field
        data = [response['data']];
      } else {
        // If no 'data' field, check if the response itself is the data
        if (response.containsKey('id_gudang') || response.containsKey('id_produk') || response.containsKey('id_order')) {
          // Single object response, wrap in array
          data = [response];
        } else {
          data = [];
        }
      }
    } else {
      data = [];
    }
    
    // Ensure data is a List
    if (data is! List) {
      if (data is Map<String, dynamic>) {
        data = [data];
      } else {
        data = [];
      }
    }
    
    return (data as List<dynamic>).map((json) => fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<T> getById<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    final response = await makeRequest('GET', endpoint);
    return fromJson(response['data']);
  }

  Future<T> create<T>(String endpoint, Map<String, dynamic> data, T Function(Map<String, dynamic>) fromJson) async {
    final response = await makeRequest('POST', endpoint, data);
    return fromJson(response['data']);
  }

  Future<T> update<T>(String endpoint, Map<String, dynamic> data, T Function(Map<String, dynamic>) fromJson) async {
    final response = await makeRequest('PUT', endpoint, data);
    return fromJson(response['data']);
  }

  Future<void> delete(String endpoint) async {
    await makeRequest('DELETE', endpoint);
  }
}

class ApiService extends BaseApiService {

  


}