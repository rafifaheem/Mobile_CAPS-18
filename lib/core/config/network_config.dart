import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NetworkConfig {
  static Future<String> discoverBackend() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      
      // Get configuration from .env
      final serverDomain = dotenv.env['API_HOST'] ?? 'devom.silog.co.id';
      final serverPort = int.tryParse(dotenv.env['API_PORT'] ?? '8000') ?? 8000;
      final timeoutSeconds = int.tryParse(dotenv.env['NETWORK_TIMEOUT'] ?? '2') ?? 2;
      
      // Get fallback IPs from .env
      final fallbackIPs = _getFallbackIPs();
      
      if (wifiIP != null) {
        // Extract network prefix (e.g., 192.168.1.x -> 192.168.1)
        final parts = wifiIP.split('.');
        if (parts.length >= 3) {
          final networkPrefix = '${parts[0]}.${parts[1]}.${parts[2]}';
          
          // Common backend IPs to try
          final commonIPs = [
            serverDomain, // Server domain from .env
            ...fallbackIPs, // Fallback IPs from .env
            '$networkPrefix.1', // Common gateway
            '$networkPrefix.100', // Common server IP
            '$networkPrefix.101', // Common server IP
            '$networkPrefix.10', // Common server IP
          ];
          
          // Remove duplicates
          final uniqueIPs = commonIPs.toSet().toList();
          
          for (final ip in uniqueIPs) {
            if (await _testConnection(ip, serverPort, timeoutSeconds)) {
              final protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
              return '$protocol://$ip:$serverPort';
            }
          }
        }
      }
      
      // Fallback to server domain from .env
      final protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
      return '$protocol://$serverDomain:$serverPort';
    } catch (e) {
      // Fallback to server domain from .env
      final protocol = dotenv.env['API_PROTOCOL'] ?? 'http';
      final serverDomain = dotenv.env['API_HOST'] ?? 'devom.silog.co.id';
      final serverPort = int.tryParse(dotenv.env['API_PORT'] ?? '8000') ?? 8000;
      return '$protocol://$serverDomain:$serverPort';
    }
  }
  
  static Future<bool> _testConnection(String host, int port, int timeoutSeconds) async {
    try {
      final socket = await Socket.connect(
        host, 
        port, 
        timeout: Duration(seconds: timeoutSeconds)
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static List<String> _getFallbackIPs() {
    final fallbackIPs = <String>[];
    
    // Get static IPs from .env
    final staticIP1 = dotenv.env['NETWORK_FALLBACK_IP_1'];
    final staticIP2 = dotenv.env['NETWORK_FALLBACK_IP_2'];

    // Add non-empty IPs to the list
    if (staticIP1 != null && staticIP1.isNotEmpty) fallbackIPs.add(staticIP1);
    if (staticIP2 != null && staticIP2.isNotEmpty) fallbackIPs.add(staticIP2);
    
    // Add default fallbacks if no custom IPs are provided
    if (fallbackIPs.isEmpty) {
      fallbackIPs.addAll([
        '10.10.10.213', // Laptop IP (default)
        '10.0.2.2', // Android emulator (default)
      ]);
    }
    
    return fallbackIPs;
  }
}