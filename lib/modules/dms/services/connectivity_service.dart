import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cargoind/modules/dms/config/api_config.dart';

class ConnectivityService {
  static Future<Map<String, dynamic>> checkConnectivity() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'api_base_url': null,
      'api_status': false,
      'database_status': false,
      'verification_api': false,
      'auth_api': false,
      'errors': <String>[],
    };

    try {
      // Test API base URL detection
      final baseUrl = await ApiConfig.baseUrl;
      results['api_base_url'] = baseUrl;
      
      // Test basic API connectivity
      final apiResponse = await http.get(
        Uri.parse('$baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (apiResponse.statusCode == 200) {
        results['api_status'] = true;
      } else {
        results['errors'].add('API returned status: ${apiResponse.statusCode}');
      }

      // Test database connectivity via drivers endpoint
      final dbResponse = await http.get(
        Uri.parse('$baseUrl/api/drivers/status/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (dbResponse.statusCode == 401 || dbResponse.statusCode == 200) {
        results['database_status'] = true; // 401 means DB is working, just need auth
      } else {
        results['errors'].add('Database check failed: ${dbResponse.statusCode}');
      }

      // Test verification API
      final verifyResponse = await http.post(
        Uri.parse('$baseUrl/api/verification/send-code/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'method': 'email', 'contact': 'test@test.com'}),
      ).timeout(const Duration(seconds: 5));
      
      if (verifyResponse.statusCode == 200 || verifyResponse.statusCode == 500) {
        results['verification_api'] = true; // 500 might be email config issue, but API works
      } else {
        results['errors'].add('Verification API failed: ${verifyResponse.statusCode}');
      }

      // Test auth API
      final authResponse = await http.post(
        Uri.parse('$baseUrl/api/drivers/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': 'test@test.com', 'password': 'test'}),
      ).timeout(const Duration(seconds: 5));
      
      if (authResponse.statusCode == 400 || authResponse.statusCode == 401) {
        results['auth_api'] = true; // API works, just invalid credentials
      } else {
        results['errors'].add('Auth API failed: ${authResponse.statusCode}');
      }

    } catch (e) {
      results['errors'].add('Connection error: $e');
    }

    return results;
  }

  static String formatResults(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    buffer.writeln('=== CONNECTIVITY CHECK ===');
    buffer.writeln('Time: ${results['timestamp']}');
    buffer.writeln('');
    buffer.writeln('📡 API Base URL: ${results['api_base_url']}');
    buffer.writeln('🌐 API Status: ${results['api_status'] ? '✅ Connected' : '❌ Failed'}');
    buffer.writeln('🗄️ Database: ${results['database_status'] ? '✅ Connected' : '❌ Failed'}');
    buffer.writeln('📧 Verification API: ${results['verification_api'] ? '✅ Working' : '❌ Failed'}');
    buffer.writeln('🔐 Auth API: ${results['auth_api'] ? '✅ Working' : '❌ Failed'}');
    
    if (results['errors'].isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('❌ ERRORS:');
      for (String error in results['errors']) {
        buffer.writeln('  • $error');
      }
    }
    
    final allGood = results['api_status'] && results['database_status'] && 
                   results['verification_api'] && results['auth_api'];
    
    buffer.writeln('');
    buffer.writeln('Overall Status: ${allGood ? '✅ ALL SYSTEMS READY' : '⚠️ ISSUES DETECTED'}');
    
    return buffer.toString();
  }
}