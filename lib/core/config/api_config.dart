import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  
  // Get timeout from .env or default to 2 seconds
  static int get _timeout => int.parse(dotenv.env['API_TIMEOUT'] ?? '');
  
  // Get protocol from .env or default to http
  static String get _urlProtocol => dotenv.env['API_PROTOCOL'] ?? "";
  
  // Get main API host and port from .env
  static String get _apiHost => dotenv.env['API_HOST'] ?? "";
  static int get _apiPort => int.parse(dotenv.env['API_PORT'] ?? '');

  static String get _cachedBaseUrl => "${_urlProtocol}://${_apiHost}:${_apiPort}";
  
  // Get fallback hosts from .env
  static String get _fallbackHost1 => dotenv.env['API_FALLBACK_HOST_1'] ?? "";
  static String get _fallbackHost2 => dotenv.env['API_FALLBACK_HOST_2'] ?? "";
  
  // Build base URLs list from .env values
  static List<Map<String, dynamic>> get _baseUrls => [
    {"host": _apiHost, "port": _apiPort},
    {"host": _fallbackHost1, "port": _apiPort},
    {"host": _fallbackHost2, "port": _apiPort},
  ];
  
  ApiConfig(){
    //resetCache();
  }

  static Future<String> getAutoDetectedBaseUrl() async {
    // Force reset cache and always use devom.silog.co.id
    print("Selected API URL: $_cachedBaseUrl");
    return _cachedBaseUrl;
  }

  static Future<bool> _testConnection(dynamic a, [int? b]) async {
    try {
      if (a is String && b == null) {
        final url = Uri.parse(a);
        final response = await http.get(url).timeout(Duration(seconds: _timeout));
        print("HTTP OK: ${response.statusCode}");
        return true;
      } else if (a is String && b != null) {
        final socket = await Socket.connect(a, b, timeout: Duration(seconds: _timeout));
        socket.destroy();
        print("Socket OK");
        return true;
      } else {
        throw ArgumentError("Invalid arguments for _testConnection");
      }
    } catch (e) {
      print("Error on _testConnection: $e");
      return false;
    }
  }

  //static Future<void> resetCache() async {
    //_cachedBaseUrl = null;
    //print('ApiConfig: Cache reset');
 // }
}