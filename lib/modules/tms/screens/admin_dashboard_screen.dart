import 'package:flutter/material.dart';
import 'package:cargoind/modules/tms/screens/transport_management_screen.dart';
import 'package:cargoind/modules/tms/screens/admin_vehicles_screen.dart';
import 'package:cargoind/modules/tms/screens/ocr_demo_screen.dart';
import 'package:cargoind/modules/tms/screens/admin_document_verification_screen.dart';
import 'package:cargoind/modules/tms/screens/vehicle_verification_screen.dart';
import 'package:cargoind/modules/tms/screens/vehicle_monitoring_screen.dart';
import 'package:cargoind/modules/tms/screens/order_management_screen.dart';
import 'package:cargoind/modules/tms/services/auth_service.dart';
import 'package:cargoind/modules/tms/services/notification_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  final Map<String, bool> _expandedCards =
      {}; // Track expanded state for each shipment

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth < 600;

    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFFF0000),
              width: screenWidth < 360 ? 2 : 3,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/Logo-SILOG.png',
                  height: screenWidth < 360 ? 32 : 40,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              ValueListenableBuilder<int>(
                valueListenable: NotificationService().unreadCount,
                builder: (context, count, child) {
                  return count > 0
                      ? Badge(
                          label: Text('$count'),
                          child: IconButton(
                            icon: const Icon(Icons.notifications),
                            iconSize: screenWidth < 360 ? 20 : 24,
                            onPressed: () => _showNotifications(context),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          iconSize: screenWidth < 360 ? 20 : 24,
                          onPressed: () => _showNotifications(context),
                        );
                },
              ),
            ],
          ),
        ),
      ),
      body: _getBodyForIndex(_currentIndex, isMobile, isTablet),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFFF0000),
        unselectedItemColor: Colors.grey,
        selectedFontSize: screenWidth < 360 ? 11 : 14,
        unselectedFontSize: screenWidth < 360 ? 10 : 12,
        iconSize: screenWidth < 360 ? 22 : 24,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }

  Widget _getBodyForIndex(int index, bool isMobile, bool isTablet) {
    switch (index) {
      case 0:
        return _buildDashboardBody(isMobile, isTablet);
      case 1:
        return _buildProfileBody();
      case 2:
        return _buildNotificationsBody();
      default:
        return _buildDashboardBody(isMobile, isTablet);
    }
  }

  Widget _buildDashboardBody(bool isMobile, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            _buildSearchBar(context, isMobile),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(context, isMobile),
            const SizedBox(height: 24),

            // Orders Section
            _buildSectionTitle('Daftar Orderan', isMobile),
            const SizedBox(height: 16),
            _buildOrdersGrid(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Coming Soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotificationsBody() {
    final notifications = NotificationService().getNotifications();

    return Container(
      color: Colors.grey[100],
      child: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: notification['isRead']
                            ? Colors.grey[200]
                            : Color(0xFFFF0000).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        notification['type'] == 'vehicle_registration'
                            ? Icons.directions_car
                            : Icons.info,
                        color: notification['isRead']
                            ? Colors.grey
                            : Color(0xFFFF0000),
                      ),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: notification['isRead']
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notification['message']),
                    onTap: () {
                      NotificationService().markAsRead(notification['id']);
                      setState(() {});
                      if (notification['type'] == 'vehicle_registration') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const VehicleVerificationScreen(),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari kendaraan, shipment, dokumen, atau lainnya...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: isMobile ? 14 : 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFFFF0000),
            size: isMobile ? 22 : 24,
          ),
          suffixIcon: Icon(
            Icons.filter_list,
            color: Colors.grey[400],
            size: isMobile ? 22 : 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF0000), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 14 : 16,
          ),
        ),
        onChanged: (value) {
          // Add search functionality here
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 18 : 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Warehouse',
            Icons.warehouse,
            () => _showComingSoon(context, 'Warehouse Management'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            'Transport',
            Icons.local_shipping,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransportManagementScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            'Orders',
            Icons.shopping_cart,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const OrderManagementScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing berdasarkan lebar container
        final width = constraints.maxWidth;
        final iconSize = width < 80 ? 18.0 : 20.0;
        final fontSize = width < 80 ? 10.0 : 11.0;
        final padding = width < 80 ? 10.0 : 12.0;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: padding, horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: iconSize),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersGrid(BuildContext context, bool isMobile) {
    // Sample shipment data - akan diganti dengan data dari API
    final shipments = [
      {
        'shipmentId': 'SHP-20260220-001',
        'tenantCode': 'SIG',
        'tenantName': 'PT Semen Indonesia',
        'timeRemaining': '0 hari 0 jam tersisa',
        'muatanType': 'Semen Kemasan',
        'pickupType': 'Pick Up',
        'vehicleType': 'Tronton',
        'isTrustedTenant': true,
        'routeType': 'Rute Pendek',
        'routeStreet': 'Jl. Merak',
        'originName': 'Jl. Merak',
        'originWarehouse': 'Gudang Asal',
        'destinationName': 'Jl A Yani',
        'destinationWarehouse': 'Gudang Tujuan',
        'estimatedCost': 69000,
        'startDate': '1 Februari 2026',
        'endDate': '3 Desember 2026',
        'cargoType': 'Semen Curah',
        'armadaType': 'Pick Up, Tronton',
        'totalWeight': '3000 KG',
        'tripCount': '4x',
        'armadaStatus': 'Belum Tersedia',
        'driverStatus': 'Belum Tersedia',
      },
      {
        'shipmentId': 'SHP-20260220-002',
        'tenantCode': 'BSD',
        'tenantName': 'PT Bina Sarana Data',
        'timeRemaining': '2 hari 5 jam tersisa',
        'muatanType': 'Pasir',
        'pickupType': 'On Site',
        'vehicleType': 'Dump Truck',
        'isTrustedTenant': true,
        'routeType': 'Rute Sedang',
        'routeStreet': 'Jl. Tanah Abang',
        'originName': 'Jl. Tanah Abang',
        'originWarehouse': 'Gudang Jakarta',
        'destinationName': 'Jl. Sudirman',
        'destinationWarehouse': 'Gudang Bandung',
        'estimatedCost': 150000,
        'startDate': '18 Februari 2026',
        'endDate': '20 Februari 2026',
        'cargoType': 'Pasir',
        'armadaType': 'Dump Truck',
        'totalWeight': '5000 KG',
        'tripCount': '2x',
        'armadaStatus': 'Siap',
        'driverStatus': 'Belum Tersedia',
      },
      {
        'shipmentId': 'SHP-20260220-003',
        'tenantCode': 'JKT',
        'tenantName': 'PT Jakarta Trading',
        'timeRemaining': '1 hari 12 jam tersisa',
        'muatanType': 'Batu Bata',
        'pickupType': 'Pick Up',
        'vehicleType': 'Colt Diesel',
        'isTrustedTenant': false,
        'routeType': 'Rute Panjang',
        'routeStreet': 'Jl. Gatot Subroto',
        'originName': 'Jl. Gatot Subroto',
        'originWarehouse': 'Gudang Utara',
        'destinationName': 'Jl. Thamrin',
        'destinationWarehouse': 'Gudang Selatan',
        'estimatedCost': 250000,
        'startDate': '19 Februari 2026',
        'endDate': '21 Februari 2026',
        'cargoType': 'Batu Bata',
        'armadaType': 'Colt Diesel',
        'totalWeight': '2500 KG',
        'tripCount': '3x',
        'armadaStatus': 'Siap',
        'driverStatus': 'Siap',
      },
      {
        'shipmentId': 'SHP-20260220-004',
        'tenantCode': 'SBY',
        'tenantName': 'PT Surabaya Logistics',
        'timeRemaining': '5 hari 8 jam tersisa',
        'muatanType': 'Besi',
        'pickupType': 'Delivery',
        'vehicleType': 'Fuso',
        'isTrustedTenant': true,
        'routeType': 'Rute Pendek',
        'routeStreet': 'Jl. Basuki Rahmat',
        'originName': 'Jl. Basuki Rahmat',
        'originWarehouse': 'Gudang Surabaya',
        'destinationName': 'Jl. Pahlawan',
        'destinationWarehouse': 'Gudang Gresik',
        'estimatedCost': 180000,
        'startDate': '20 Februari 2026',
        'endDate': '25 Februari 2026',
        'cargoType': 'Besi',
        'armadaType': 'Fuso',
        'totalWeight': '4000 KG',
        'tripCount': '5x',
        'armadaStatus': 'Belum Tersedia',
        'driverStatus': 'Siap',
      },
    ];

    // Responsive grid configuration
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;
    double crossAxisSpacing;
    double mainAxisSpacing;

    if (screenWidth < 360) {
      // HP sangat kecil: 1 kolom
      crossAxisCount = 1;
      childAspectRatio = 0.72;
      crossAxisSpacing = 0;
      mainAxisSpacing = 12;
    } else if (screenWidth < 600) {
      // HP normal: 2 kolom
      crossAxisCount = 2;
      childAspectRatio = 0.65;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else if (screenWidth < 900) {
      // Tablet kecil: 3 kolom
      crossAxisCount = 3;
      childAspectRatio = 0.75;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
    } else {
      // Tablet besar / Desktop: 4 kolom
      crossAxisCount = 4;
      childAspectRatio = 0.80;
      crossAxisSpacing = 20;
      mainAxisSpacing = 20;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: shipments.length,
      itemBuilder: (context, index) {
        final shipment = shipments[index];
        return _buildShipmentCard(shipment);
      },
    );
  }

  Widget _buildShipmentCard(Map<String, dynamic> shipment) {
    final shipmentId = shipment['shipmentId'] as String;
    final isExpanded = _expandedCards[shipmentId] ?? false;

    // Format harga
    String formattedPrice =
        'Rp ${(shipment['estimatedCost'] as num).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFF0000), width: 2),
      ),
      child: SingleChildScrollView(
        physics: isExpanded
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Shipment ID, Time Remaining, Tenant Code
              Row(
                children: [
                  // Shipment ID
                  Expanded(
                    child: Text(
                      shipment['shipmentId'],
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tenant Code & Name (Prominent)
              Row(
                children: [
                  // Tenant code badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      shipment['tenantCode'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipment['tenantName'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (shipment['isTrustedTenant'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified,
                              size: 10, color: Colors.blue[600]),
                          const SizedBox(width: 2),
                          Text(
                            'Terpercaya',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Time remaining badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFFF0000).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFFFF0000),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      shipment['timeRemaining'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFF0000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Muatan, Pickup Type, Vehicle Type
              Text(
                '${shipment['muatanType']} • ${shipment['pickupType']} • ${shipment['vehicleType']}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              // Route Type & Street
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.route, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${shipment['routeType']} - ${shipment['routeStreet']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Origin → Destination
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dari:',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shipment['originName'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          shipment['originWarehouse'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFFF0000),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Ke:',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shipment['destinationName'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          shipment['destinationWarehouse'],
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Estimated Cost
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFF0000).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimasi Biaya:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF0000),
                      ),
                    ),
                  ],
                ),
              ),

              // Expandable Details Section
              if (isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Date Range
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Mulai:',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shipment['startDate'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Tanggal Selesai:',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            shipment['endDate'],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Cargo Type and Armada Type
                _buildDetailItem('Jenis Muatan:', shipment['cargoType']),
                const SizedBox(height: 8),
                _buildDetailItem('Jenis Armada:', shipment['armadaType']),
                const SizedBox(height: 8),

                // Weight and Trip Count
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                          'Berat Total:', shipment['totalWeight']),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailItem(
                          'Jumlah Rit:', shipment['tripCount']),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status Indicators
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusBadge(
                        'Armada',
                        shipment['armadaStatus'],
                        shipment['armadaStatus'] == 'Siap'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusBadge(
                        'Driver',
                        shipment['driverStatus'],
                        shipment['driverStatus'] == 'Siap'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Toggle Detail Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _expandedCards[shipmentId] = !isExpanded;
                    });
                  },
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: const Color(0xFFFF0000),
                  ),
                  label: Text(
                    isExpanded ? 'Sembunyikan Detail' : 'Lihat Detail',
                    style: const TextStyle(
                      color: Color(0xFFFF0000),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFFF0000), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                status == 'Siap' ? Icons.check_circle : Icons.cancel,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon')),
    );
  }

  void _showNotifications(BuildContext context) {
    final notifications = NotificationService().getNotifications();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifikasi'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: notifications.isEmpty
              ? const Center(child: Text('Tidak ada notifikasi'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      leading: Icon(
                        notification['type'] == 'vehicle_registration'
                            ? Icons.directions_car
                            : Icons.info,
                        color:
                            notification['isRead'] ? Colors.grey : Colors.blue,
                      ),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: notification['isRead']
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(notification['message']),
                      onTap: () {
                        NotificationService().markAsRead(notification['id']);
                        Navigator.pop(context);
                        if (notification['type'] == 'vehicle_registration') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VehicleVerificationScreen(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                NotificationService().markAllAsRead();
                Navigator.pop(context);
              },
              child: const Text('Tandai Semua Dibaca'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[50],
      child: Column(
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/Logo-SILOG.png',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey[700],
                      tooltip: 'Tutup',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transport Management',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionHeader('KENDARAAN'),
                _buildDrawerItem(
                  context,
                  icon: Icons.verified_outlined,
                  title: 'Verifikasi Kendaraan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VehicleVerificationScreen(),
                        ));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.monitor_outlined,
                  title: 'Monitoring Kendaraan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VehicleMonitoringScreen(),
                        ));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.directions_car_outlined,
                  title: 'Kelola Kendaraan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminVehiclesScreen(filter: 'all'),
                        ));
                  },
                ),
                const SizedBox(height: 8),
                _buildSectionHeader('DOKUMEN & SHIPMENT'),
                _buildDrawerItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Verifikasi Dokumen',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AdminDocumentVerificationScreen(),
                        ));
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_shipping_outlined,
                  title: 'Shipment Management',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/shipment-management');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.document_scanner_outlined,
                  title: 'OCR Demo',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OCRDemoScreen(),
                        ));
                  },
                ),
                const SizedBox(height: 8),
                _buildSectionHeader('ANALYTICS & SYSTEM'),
                _buildDrawerItem(
                  context,
                  icon: Icons.trending_up_outlined,
                  title: 'Revenue Analytics',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/revenue-analytics');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_outline,
                  title: 'User Management',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'User Management');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'System Settings',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'System Settings');
                  },
                ),
              ],
            ),
          ),

          // Logout at Bottom
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withValues(alpha: 0.05),
              border: const Border(
                top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: _buildDrawerItem(
              context,
              icon: Icons.logout_outlined,
              title: 'Logout',
              onTap: () => _logout(context),
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: const Color(0xFFFF0000).withValues(alpha: 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isLogout ? const Color(0xFFFF0000) : Colors.grey[700],
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isLogout ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isLogout ? const Color(0xFFFF0000) : Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
