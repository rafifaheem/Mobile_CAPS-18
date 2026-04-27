import 'package:flutter/material.dart';
import 'app_routes.dart';

// Core Screens
import 'package:cargoind/screens/splash_screen.dart';
import 'package:cargoind/screens/login_screen.dart';
import 'package:cargoind/screens/register_screen.dart';

// DMS Screens
import 'package:cargoind/modules/dms/screens/new_dashboard_screen.dart';
import 'package:cargoind/modules/dms/screens/profile_edit_screen.dart';
import 'package:cargoind/modules/dms/screens/trips_screen.dart';

// WMS Screens
import 'package:cargoind/modules/wms/screens/dashboard_screen.dart';
import 'package:cargoind/modules/wms/screens/inbound_dashboard_screen.dart';
import 'package:cargoind/modules/wms/screens/purchase_order_screen.dart';
import 'package:cargoind/modules/wms/screens/goods_receipt_screen.dart';
import 'package:cargoind/modules/wms/screens/quality_control_screen.dart';
import 'package:cargoind/modules/wms/screens/put_away_screen.dart';

// TMS Screens
import 'package:cargoind/modules/tms/screens/driver_dashboard_screen.dart';
import 'package:cargoind/modules/tms/screens/transport_management_screen.dart';
import 'package:cargoind/modules/tms/screens/vehicle_management_screen.dart';
import 'package:cargoind/modules/tms/screens/vehicle_registration_screen.dart';
import 'package:cargoind/modules/tms/screens/gps_registration_screen.dart';
import 'package:cargoind/modules/tms/screens/analytics_screen.dart';
import 'package:cargoind/modules/tms/screens/notifications_screen.dart';
import 'package:cargoind/modules/tms/screens/trip_tracking_screen.dart';
import 'package:cargoind/modules/tms/screens/trip_management_screen.dart';
import 'package:cargoind/modules/tms/screens/admin_dashboard_screen.dart';
import 'package:cargoind/modules/tms/screens/shipment_management_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Core Routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      // Admin Route
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      // WMS Routes
      case AppRoutes.wmsDashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case AppRoutes.wmsInbound:
        return MaterialPageRoute(
          builder: (_) => const InboundDashboardScreen(),
        );

      case AppRoutes.wmsPurchaseOrder:
        return MaterialPageRoute(
          builder: (_) => const PurchaseOrderScreen(),
        );

      case AppRoutes.wmsGoodsReceipt:
        return MaterialPageRoute(
          builder: (_) => const GoodsReceiptScreen(),
        );

      case AppRoutes.wmsQualityControl:
        return MaterialPageRoute(
          builder: (_) => const QualityControlScreen(),
        );

      case AppRoutes.wmsPutAway:
        return MaterialPageRoute(
          builder: (_) => const PutAwayScreen(),
        );

      // TMS Routes
      case AppRoutes.tmsDashboard:
        return MaterialPageRoute(
          builder: (_) => DriverDashboardScreen(),
        );

      case '/transport-management':
        return MaterialPageRoute(builder: (_) => TransportManagementScreen());

      case '/vehicle-management':
        return MaterialPageRoute(builder: (_) => VehicleManagementScreen());

      case '/vehicle-registration':
        return MaterialPageRoute(builder: (_) => VehicleRegistrationScreen());

      case '/gps-registration':
        return MaterialPageRoute(builder: (_) => GPSRegistrationScreen());

      case '/analytics':
        return MaterialPageRoute(builder: (_) => AnalyticsScreen());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => NotificationsScreen());

      case '/trip-management':
        return MaterialPageRoute(builder: (_) => TripManagementScreen());

      case '/shipment-management':
        return MaterialPageRoute(builder: (_) => ShipmentManagementScreen());

      // DMS Routes
      case AppRoutes.dmsDashboard:
        return MaterialPageRoute(
          builder: (_) => NewDashboardScreen(),
        );

      case '/profile_edit':
        return MaterialPageRoute(
          builder: (_) => ProfileEditScreen(),
        );

      case '/trips':
        return MaterialPageRoute(
          builder: (_) => TripsScreen(),
        );

      // Default Route
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}
