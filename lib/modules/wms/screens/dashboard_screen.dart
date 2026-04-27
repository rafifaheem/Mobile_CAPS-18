import 'package:cargoind/modules/wms/screens/quality_control_screen.dart';
import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/services/selected_gudang_service.dart';
import 'package:cargoind/modules/wms/models/gudang_model.dart';
import 'package:cargoind/modules/wms/screens/inbound_dashboard_screen.dart';
import 'package:cargoind/modules/wms/screens/notification_screen.dart';
import 'package:cargoind/modules/wms/screens/profile_screen.dart';
import 'package:cargoind/modules/wms/screens/inventory_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? username;
  const DashboardScreen({super.key, this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _DashboardContent(username: widget.username),
      const NotificationScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          final previousIndex = _currentIndex;
          setState(() {
            _currentIndex = index;
            // Refresh dashboard when returning from profile
            if (index == 0 && previousIndex == 2) {
              _screens[0] = _DashboardContent(username: widget.username);
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final String? username;
  const _DashboardContent({this.username});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  Gudang? _selectedGudang;
  
  @override
  void initState() {
    super.initState();
    _loadSelectedGudang();
  }
  
  Future<void> _loadSelectedGudang() async {
    final gudang = await SelectedGudangService.getSelectedGudang();
    if (mounted) {
      setState(() {
        _selectedGudang = gudang;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Header with warehouse image
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/dashboard.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha:0.3),
                    Colors.black.withValues(alpha:0.7),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Warehouse status card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedGudang?.namaGudang ?? 'Pilih Gudang',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _selectedGudang?.namaStatus ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Menu grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuItem(Icons.inventory_2_outlined, 'Inventory', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryStokScreen(),
                          ),
                        );
                      }),
                      _buildMenuItem(Icons.edit_outlined, 'Stock\nOpname', () {}),
                      _buildMenuItem(Icons.security_outlined, 'Quality\nControl', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QualityControlScreen(),
                          ),
                        );
                      }),
                      _buildMenuItem(Icons.email_outlined, 'Pindah Rak', () {}),
                      _buildMenuItem(Icons.arrow_downward, 'Inbound\nStock', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InboundDashboardScreen(),
                          ),
                        );
                      }),
                      _buildMenuItem(Icons.arrow_upward, 'Outbound\nStock', () {}),
                      _buildMenuItem(Icons.refresh, 'Retur', () {}),
                      _buildMenuItem(Icons.apps, 'Lokasi Rak', () {}),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Charts section
                  Row(
                    children: [
                      Expanded(
                        child: _buildChartCard('Penjualan', Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildChartCard('Retur', Colors.cyan),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildChartCard('Keuntungan', Colors.green, isWide: true),
                ],
              ),
            ),
          ),
        ],
      );
  }
  
  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD32F2F), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChartCard(String title, Color color, {bool isWide = false}) {
    return Container(
      height: isWide ? 120 : 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart Placeholder',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}