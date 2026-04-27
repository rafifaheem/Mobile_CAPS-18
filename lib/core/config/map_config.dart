class MapConfig {
  // Map services hardcode ke server production (tidak terdampak perubahan .env)
  static const String _mapTileUrl = 'http://devom.silog.co.id:8082/styles/bright/{z}/{x}/{y}.png';
  //static const String _mapTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _routingBaseUrl = 'http://devom.silog.co.id:8989';
  static const String _mapAttribution = 'Map data from OpenStreetMap';
  static const String _mapAttributionUrl = 'https://www.openstreetmap.org/copyright';
  
  static String get tileUrl => _mapTileUrl;
  static String get routingUrl => _routingBaseUrl;
  static String get mapAttribution => _mapAttribution;
  static String get mapAttributionUrl => _mapAttributionUrl;
}