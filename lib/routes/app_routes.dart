class AppRoutes {
  // Core Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String networkTest = '/network-test';
  
  // WMS Routes
  static const String wmsDashboard = '/wms/dashboard';
  static const String wmsInbound = '/wms/inbound';
  static const String wmsPurchaseOrder = '/wms/purchase-order';
  static const String wmsGoodsReceipt = '/wms/goods-receipt';
  static const String wmsQualityControl = '/wms/quality-control';
  static const String wmsPutAway = '/wms/put-away';
  
  // TMS Routes
  static const String tmsDashboard = '/tms/dashboard';
  static const String tmsVehicles = '/tms/vehicles';
  static const String tmsDrivers = '/tms/drivers';
  static const String tmsTrips = '/tms/trips';
  
  // DMS Routes
  static const String dmsDashboard = '/dms/dashboard';
  static const String dmsDocuments = '/dms/documents';
  static const String dmsUpload = '/dms/upload';
  static const String dmsVerification = '/dms/verification';
  
  // Module Entry Points
  static const String wmsModule = '/wms';
  static const String tmsModule = '/tms';
  static const String dmsModule = '/dms';
}