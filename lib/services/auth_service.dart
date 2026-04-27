import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:cargoind/core/config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  // Static fallback storage
  static String? _staticToken;
  static Map<String, dynamic>? _staticUserData;
  
  Future<String?> getToken() async {
    try {
      // Try static storage first
      if (_staticToken != null) {
        print('🔧 getToken from static: ${_staticToken!.substring(0, 20)}...');
        return _staticToken;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('🔧 getToken from prefs: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('🔧 ERROR getting token: $e');
      return _staticToken;
    }
  }
  
  Future<void> saveToken(String token) async {
    try {
      // Save to static storage first
      _staticToken = token;
      print('🔧 Token saved to static storage: ${token.substring(0, 20)}...');
      
      // Try to save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_tokenKey, token);
      print('🔧 SharedPreferences setString result: $success');
      
      // Immediate verification
      final saved = prefs.getString(_tokenKey);
      print('🔧 Immediate verification: ${saved?.substring(0, 20)}...');
    } catch (e) {
      print('🔧 ERROR saving token to prefs: $e');
      // Static storage should still work
    }
  }
  
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }
  
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
  
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    // For custom tokens that don't follow JWT format, just check if exists
    if (token.startsWith('wms_token_')) {
      return true;
    }
    
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      // If not a valid JWT, assume it's valid if it exists
      return true;
    }
  }
  
  Future<void> debugToken() async {
    final token = await getToken();
    final isValid = await isTokenValid();
    print('🔧 Debug - Token: ${token?.substring(0, 20)}...');
    print('🔧 Debug - Valid: $isValid');
  }
  
  Future<void> testSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const testKey = 'test_key';
      const testValue = 'test_value_123';
      
      // Test write
      final writeResult = await prefs.setString(testKey, testValue);
      print('🔧 Test write result: $writeResult');
      
      // Test read
      final readResult = prefs.getString(testKey);
      print('🔧 Test read result: $readResult');
      
      // Clean up
      await prefs.remove(testKey);
      
      if (readResult == testValue) {
        print('🔧 SharedPreferences test PASSED');
      } else {
        print('🔧 SharedPreferences test FAILED');
      }
    } catch (e) {
      print('🔧 SharedPreferences test ERROR: $e');
    }
  }
  
  Future<void> logout() async {
    // Clear static storage
    _staticToken = null;
    _staticUserData = null;
    
    // Clear SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      print('🔧 Error clearing prefs: $e');
    }
    print('🔧 Logout completed, token and user data removed');
  }
  
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🔧 All SharedPreferences data cleared');
  }
  
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    try {
      final baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
      print('🔧 Login to: $baseUrl/auth/login');
      
      // Try with email field first
      var requestData = {
        'email': emailOrUsername,
        'password': password,
      };
      
      print('🔧 Login request data: $requestData');
      
      var response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      
      print('🔧 Login response status: ${response.statusCode}');
      print('🔧 Login response body: "${response.body}"');
      
      // If failed and input doesn't contain @, try with username field
      if (response.statusCode != 200 && !emailOrUsername.contains('@')) {
        print('🔧 Trying with username field...');
        requestData = {
          'username': emailOrUsername,
          'password': password,
        };
        
        response = await http.post(
          Uri.parse('$baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );
        
        print('🔧 Username login response status: ${response.statusCode}');
        print('🔧 Username login response body: "${response.body}"');
      }
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔧 Parsed response data: $data');
        print('🔧 data["data"]: ${data['data']}');
        print('🔧 data["data"]["token"]: ${data['data']?['token']}');
        
        // Handle nested token structure
        String? token;
        if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'];
          print('🔧 Token found in data.token: $token');
        } else if (data['token'] != null) {
          token = data['token'];
          print('🔧 Token found in token: $token');
        }
        
        if (token != null) {
          print('🔧 About to save token: ${token.substring(0, 20)}...');
          await saveToken(token);
          
          // Verify token was saved
          final savedToken = await getToken();
          print('🔧 Token verification after save: ${savedToken?.substring(0, 20)}...');
          
          // Save user data
          if (data['data'] != null && data['data']['user'] != null) {
            await saveUserData(data['data']['user']);
          } else if (data['user'] != null) {
            await saveUserData(data['user']);
          }
        } else {
          print('🔧 ERROR: No token found in response!');
          print('🔧 Available keys: ${data.keys.toList()}');
          
          // Manual extraction as fallback
          final responseBody = response.body;
          if (responseBody.contains('wms_token_')) {
            final tokenStart = responseBody.indexOf('wms_token_');
            final tokenEnd = responseBody.indexOf('"', tokenStart);
            if (tokenStart != -1 && tokenEnd != -1) {
              token = responseBody.substring(tokenStart, tokenEnd);
              print('🔧 Manual token extraction: $token');
              await saveToken(token);
              final savedToken = await getToken();
              print('🔧 Manual token verification: ${savedToken?.substring(0, 20)}...');
            }
          }
        }
        return data;
      } else {
        String errorMessage = 'Login failed';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  
  Future<Map<String, dynamic>> register(String username, String email, String password, {String? nama, String? noHP}) async {
    try {
      final baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
      print('🔧 Registering to: $baseUrl/auth/register/');
      
      final requestData = {
        'nama': nama?.isNotEmpty == true ? nama! : username,
        'email': email,
        'no_hp': noHP?.isNotEmpty == true ? noHP! : '08123456789',
        'password': password,
      };
      
      print('🔧 Request data: $requestData');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      
      print('🔧 Response status: ${response.statusCode}');
      print('🔧 Response body: "${response.body}"');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'success': true, 'message': 'Registration successful'};
        }
        try {
          final data = json.decode(response.body);
          return {'success': true, 'message': 'Registration successful', 'data': data};
        } catch (e) {
          return {'success': true, 'message': 'Registration successful'};
        }
      } else {
        String errorMessage = 'Registration failed (${response.statusCode})';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          } catch (e) {
            errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
          }
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('🔧 Registration error: $e');
      return {'success': false, 'message': 'Registration error: $e'};
    }
  }
}