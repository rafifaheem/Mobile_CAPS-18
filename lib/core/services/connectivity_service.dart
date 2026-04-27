import 'dart:async';
import 'dart:io';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _timer;

  void startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => checkConnection());
    checkConnection(); // Initial check
  }

  void stopMonitoring() {
    _timer?.cancel();
  }

  Future<void> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        _connectionController.add(_isConnected);
      }
    } catch (_) {
      if (_isConnected) {
        _isConnected = false;
        _connectionController.add(_isConnected);
      }
    }
  }

  void dispose() {
    _connectionController.close();
    _timer?.cancel();
  }
}