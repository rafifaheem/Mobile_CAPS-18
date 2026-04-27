import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cargoind/modules/dms/models/user.dart';
import 'dart:async';

class AuthService extends ChangeNotifier {
  static String? _cachedBaseUrl;
  
  // Clear cache method for fresh start
  static void clearCache() {
    _cachedBaseUrl = null;
  }
  
  static Future<String> get baseUrl async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://devom.silog.co.id:8000';
    final fallbackHosts = [
      dotenv.env['API_HOST'] ?? 'devom.silog.co.id',
      dotenv.env['API_FALLBACK_HOST_1'] ?? 'devom1.silog.co.id',
      dotenv.env['API_FALLBACK_HOST_2'] ?? 'devom2.silog.co.id',
    ];
    final port = dotenv.env['API_PORT'] ?? '8000';
    
    // Try base URL first
    try {
      print('Testing API connection to: $baseUrl/health');
      final response = await http.get(
        Uri.parse('$baseUrl/health')
      ).timeout(Duration(seconds: 2));
      
      if (response.statusCode == 200) {
        _cachedBaseUrl = '$baseUrl/api';
        return _cachedBaseUrl!;
      }
    } catch (e) {
      print('Failed to connect to $baseUrl: $e');
    }
    
    // Try fallback hosts
    for (String host in fallbackHosts) {
      try {
        final testUrl = 'http://$host:$port';
        print('Testing API connection to: $testUrl/health');
        final response = await http.get(
          Uri.parse('$testUrl/health')
        ).timeout(Duration(seconds: 2));
        
        if (response.statusCode == 200) {
          _cachedBaseUrl = '$testUrl/api';
          return _cachedBaseUrl!;
        }
      } catch (e) {
        print('Failed to connect to $host: $e');
        continue;
      }
    }
    
    // Fallback
    _cachedBaseUrl = '$baseUrl/api';
    print('Using fallback API: $_cachedBaseUrl');
    return _cachedBaseUrl!;
  }
  
  User? _currentUser;

  User? get currentUser => _currentUser;
  
  // Static method for compatibility
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final data = json.decode(userData);
      return User.fromJson(data);
    }
    return null;
  }

  Future<User?> login(String username, String password) async {
    try {
      final apiUrl = await baseUrl;
      print('Attempting login to: $apiUrl/login');
      print('Username: $username');
      
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login success data: $data');
        
        _currentUser = User.fromJson(data);
        
        // Save token and full data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _currentUser!.token);
        await prefs.setString('auth_token', _currentUser!.token);
        await prefs.setString('user_data', json.encode(data));
        print('AuthService: Token saved: ${_currentUser!.token}');
        
        notifyListeners();
        return _currentUser;
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    notifyListeners();
  }

  Future<User?> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      final token = prefs.getString('token');
      
      if (userData != null && token != null) {
        // Validate token before loading user
        final isValid = await _validateToken(token);
        if (isValid) {
          final data = json.decode(userData);
          _currentUser = User.fromJson(data);
          print('Loaded saved user: ${_currentUser?.username}');
          notifyListeners();
          return _currentUser;
        } else {
          // Token invalid, clear saved data
          await logout();
          print('Token invalid, cleared saved data');
        }
      }
    } catch (e) {
      print('Error loading saved user: $e');
      // Clear data on error
      await logout();
    }
    return null;
  }

  String? getToken() {
    final token = _currentUser?.token;
    print('AuthService: getToken() returning: $token');
    return token;
  }

  Future<void> saveToken(String token) async {
    print('AuthService: saveToken() called with: $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('auth_token', token); // Also save with the key that ApiService expects
    print('AuthService: Token saved to SharedPreferences');
  }
  
  Future<Map<String, dynamic>?> _getDriverProfile(String apiUrl, String token, int driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/drivers/$driverId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      
      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        print('Driver profile data: $profileData');
        return profileData;
      } else {
        print('Failed to get driver profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting driver profile: $e');
    }
    return null;
  }

  Future<bool> _validateToken(String token) async {
    try {
      final apiUrl = await baseUrl;
      print('Validating token at: $apiUrl/profile');
      final response = await http.get(
        Uri.parse('$apiUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 3));
      
      print('Token validation response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }
}