import 'package:flutter/material.dart';
import 'package:cargoind/core/services/auth_service.dart';
import 'package:cargoind/modules/wms/models/gudang_model.dart';
import 'package:cargoind/modules/wms/services/gudang_service.dart';
import 'package:cargoind/modules/wms/services/selected_gudang_service.dart';
import 'package:cargoind/modules/wms/screens/gudang_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GudangService _gudangService = GudangService();
  List<Gudang> _gudangList = [];
  Gudang? _selectedGudang;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadGudangList();
    await _loadSelectedGudang();
  }

  Future<void> _loadGudangList() async {
    try {
      print('🔧 Profile: Loading gudang list...');
      final gudangList = await _gudangService.getGudang();
      print('🔧 Profile: Loaded ${gudangList.length} gudang');
      setState(() {
        _gudangList = gudangList;
        _isLoading = false;
      });
    } catch (e) {
      print('🔧 Profile: Error loading gudang: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSelectedGudang() async {
    final selectedGudang = await SelectedGudangService.getSelectedGudang();
    
    if (selectedGudang != null && _gudangList.isNotEmpty) {
      final matchingGudang = _gudangList.firstWhere(
        (gudang) => gudang.idGudang == selectedGudang.idGudang,
        orElse: () => _gudangList.first,
      );
      setState(() {
        _selectedGudang = matchingGudang;
      });
    } else if (_gudangList.isNotEmpty) {
      setState(() {
        _selectedGudang = _gudangList.first;
      });
      await SelectedGudangService.setSelectedGudang(_gudangList.first);
    }
  }

  Future<void> _onGudangChanged(Gudang? gudang) async {
    if (gudang != null) {
      setState(() {
        _selectedGudang = gudang;
      });
      await SelectedGudangService.setSelectedGudang(gudang);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gudang berubah ke: ${gudang.namaGudang}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Putri Cahyani ✏️',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'putricahyani.gsk@gmail.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.pink,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Warehouse selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Gudang>(
                      initialValue: _selectedGudang,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Warehouse',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: _gudangList.map((gudang) {
                        print('🔧 Profile: Adding dropdown item: ${gudang.namaGudang}');
                        return DropdownMenuItem<Gudang>(
                          value: gudang,
                          child: Text(
                            gudang.namaGudang,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _onGudangChanged,
                      icon: const Icon(Icons.keyboard_arrow_down),
                    ),
            ),
            
            const SizedBox(height: 32),
            
            // Account section
            const Text(
              'Akun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildMenuItem(
              Icons.person_outline,
              'Informasi Akun',
              () {},
            ),
            _buildMenuItem(
              Icons.lock_outline,
              'Ganti Password',
              () {},
            ),
            
            const SizedBox(height: 32),
            
            // Warehouse section
            const Text(
              'Warehouse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildMenuItem(
              Icons.info_outline,
              'Informasi Gudang',
              () {},
            ),
            _buildMenuItem(
              Icons.sync,
              'Tambah Gudang',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GudangScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Others section
            const Text(
              'Lainnya',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildMenuItem(
              Icons.palette_outlined,
              'Tema',
              () {},
            ),
            _buildMenuItem(
              Icons.language,
              'Bahasa',
              () {},
            ),
            _buildMenuItem(
              Icons.logout,
              'LogOut',
              () => _showLogoutDialog(context),
              isLogout: true,
            ),
            
            const SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isLogout ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final authService = AuthService();
                await authService.logout();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}