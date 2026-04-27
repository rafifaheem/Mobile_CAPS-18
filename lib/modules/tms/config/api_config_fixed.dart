import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class ApiConfig {
  static String? _cachedBaseUrl;
  static const String _defaultBaseUrl = 'http://devom.silog.co.id:8000';
  static Map<String,String>? _headers;

  static Future<String> get baseUrl async {
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }
    
    final detectedUrl = await getAutoDetectedBaseUrl();
    _cachedBaseUrl = detectedUrl;
    return detectedUrl;
  }
  
  static Future<String> get healthUrl async {
    final currentBaseUrl = await baseUrl;
    return "$currentBaseUrl/health";
  }

  static Future<String> getAutoDetectedBaseUrl() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      
      if (wifiIP != null) {
        final baseIP = wifiIP.substring(0, wifiIP.lastIndexOf('.'));
        final testUrls = [
          'http://$baseIP.1:8000',
          'http://$baseIP.100:8000',
          'http://$wifiIP:8000',
          _defaultBaseUrl,
        ];
        
        for (String url in testUrls) {
          if (await _testConnection(url)) {
            return url;
          }
        }
      }
    } catch (e) {
      // Fallback to default
    }
    
    return _defaultBaseUrl;
  }
  
  // FIXED: Logic error in hasEmptyBaseUrl
  static Future<bool> get hasEmptyBaseUrl async {
    final currentBaseUrl = await baseUrl;
    return currentBaseUrl.trim().isEmpty;
  }
  
  static Map<String,String> authHeaders(String token) {
    _headers = {"Authorization":"Bearer $token"}; 
    return _headers ?? {};
  }

  static Future<Map<String,String>> getHeaders() async {
    return _headers ?? {};
  }

  static Future<bool> _testConnection(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$url/'));
      request.headers.set('Connection', 'close');
      final response = await request.close().timeout(const Duration(seconds: 2));
      client.close();
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> resetCache() async {
    _cachedBaseUrl = null;
  }
}