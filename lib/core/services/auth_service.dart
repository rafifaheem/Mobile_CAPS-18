import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cargoind/core/config/api_config.dart';

class AuthService {

  Future<bool> login(String emailOrUsername, String password) async {
    try {
      final baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
      print('🔧 Login to: $baseUrl/api/auth/login');
      
      var requestData = {
        'email': emailOrUsername,
        'password': password,
      };
      
      print('🔧 Login request data: $requestData');
      
      var response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      
      print('🔧 Response status: ${response.statusCode}');
      print('🔧 Response body: "${response.body}"');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔧 Login successful! Data: $data');
        
        // Extract token from nested structure
        String? token;
        if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'];
        } else {
          token = data['token'] ?? data['access_token'] ?? data['jwt'];
        }
        
        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString('auth_token', token);
          print('🔧 Token saved: ${token.substring(0, 20)}...');
        }
        await prefs.setString('username', emailOrUsername);
        
        // Save user data
        if (data['data'] != null && data['data']['user'] != null) {
          await prefs.setString('user_data', jsonEncode(data['data']['user']));
        } else if (data['user'] != null) {
          await prefs.setString('user_data', jsonEncode(data['user']));
        }
        return true;
      } else {
        print('🔧 Login failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('🔧 Login error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Registration successful'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    return username.toLowerCase() == 'admin';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> checkServerEndpoints() async {
    try {
      final baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
      print('🔧 Checking server endpoints at: $baseUrl');
      
      // Try to get server info or API documentation
      final infoEndpoints = [
        '/health',
        '/api',
        '/api/health', 
        '/status',
        '/info',
        '/docs',
        '/swagger'
      ];
      
      for (String endpoint in infoEndpoints) {
        try {
          final response = await http.get(Uri.parse('$baseUrl$endpoint'));
          print('🔧 $endpoint: ${response.statusCode} - ${response.body.substring(0, 100)}...');
        } catch (e) {
          print('🔧 $endpoint: ERROR - $e');
        }
      }
    } catch (e) {
      print('🔧 Server check error: $e');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');  // Use same key as main AuthService
  }
    Future<Map<String, dynamic>> loginWithGoogle(String firebaseIdToken) async {
  try {
    final baseUrl = await ApiConfig.getAutoDetectedBaseUrl();
    print('🔧 Login Google to: $baseUrl/api/auth/login-google');

    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login-google'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firebase_token': firebaseIdToken,
      }),
    );

    print('🔧 Google login status: ${response.statusCode}');
    print('🔧 Google login body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      String? token;
      if (data['data']?['token'] != null) {
        token = data['data']['token'];
      } else if (data['token'] != null) {
        token = data['token'];
      }

      if (token == null) {
        throw Exception('Token not found in login-google response');
      }

      await saveToken(token);

      if (data['data']?['user'] != null) {
        await saveUserData(data['data']['user']);
      }

      return data;
    } else {
      throw Exception('Google login failed: ${response.body}');
    }
  } catch (e) {
    throw Exception('Google login error: $e');
  }
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<void> saveUserData(Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_data', jsonEncode(user));
}

}