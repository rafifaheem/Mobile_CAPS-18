import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return '$envUrl/api';
    }
    
    // Fallback to environment-based logic
    final protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
    final host = dotenv.env['API_HOST'] ?? 'devom.silog.co.id';
    final port = dotenv.env['API_PORT'] ?? '8000';
    
    return '$protocol://$host:$port/api';
  }
  
  static String get realDeviceUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return '$envUrl/api';
    }
    
    // Fallback to environment-based logic
    final protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
    final host = dotenv.env['API_HOST'] ?? 'devom.silog.co.id';
    final port = dotenv.env['API_PORT'] ?? '8000';
    
    return '$protocol://$host:$port/api';
  }
  
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static String get appName => dotenv.env['APP_NAME'] ?? 'CargoInd';
  
  // Additional environment-based configurations
  static String get apiProtocol => dotenv.env['API_PROTOCOL'] ?? 'http';
  static String get apiHost => dotenv.env['API_HOST'] ?? 'devom.silog.co.id';
  static String get apiPort => dotenv.env['API_PORT'] ?? '8000';
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;
}