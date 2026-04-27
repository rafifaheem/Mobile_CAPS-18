import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/gudang_model.dart';
import 'package:cargoind/modules/wms/services/gudang_service.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';
import 'package:cargoind/modules/wms/screens/tambah_gudang_screen.dart';
import 'package:cargoind/services/auth_service.dart';
import 'package:cargoind/core/mixins/error_handler_mixin.dart';

class GudangScreen extends StatefulWidget {
  const GudangScreen({super.key});

  @override
  State<GudangScreen> createState() => _GudangScreenState();
}

class _GudangScreenState extends State<GudangScreen> with ErrorHandlerMixin {
  final GudangService _gudangService = GudangService();
  final StatusGudangService _statusService = StatusGudangService();
  List<Gudang> _gudangList = [];
  Map<int, String> statusMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _debugAndLoadGudang();
  }
  
  Future<void> _debugAndLoadGudang() async {
    final authService = AuthService();
    await authService.testSharedPreferences();
    await authService.debugToken();
    await _loadStatusGudang();
    _loadGudang();
  }
  
  Future<void> _loadStatusGudang() async {
    try {
      final statusList = await _statusService.getStatusGudang();
      setState(() {
        statusMap = {for (var status in statusList) status.id: status.nama};
      });
    } catch (e) {
      print('Error loading status: $e');
    }
  }

  Future<void> _loadGudang() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      print('🔧 Loading gudang list...');
      final gudangList = await _gudangService.getGudang();
      
      setState(() {
        _gudangList = gudangList;
        _isLoading = false;
      });
      
      print('🔧 Loaded ${gudangList.length} gudang successfully');
    } catch (e) {
      print('🔧 Error loading gudang: $e');
      setState(() {
        _gudangList = [];
        _isLoading = false;
      });
      
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data gudang: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: _loadGudang,
            ),
          ),
        );
      }
    }
  }
  
  Future<void> _refreshData() async {
    await _loadStatusGudang();
    await _loadGudang();
  }

  Future<void> _deleteGudang(int id) async {
    try {
      await _gudangService.deleteGudang(id);
      _loadGudang();
      showSuccessMessage(context, 'Gudang berhasil dihapus');
    } catch (e) {
      handleError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Gudang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gudangList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warehouse, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada gudang',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan gudang pertama Anda',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TambahGudangScreen()),
                          ).then((_) => _loadGudang());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Gudang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _gudangList.length,
                itemBuilder: (context, index) {
                  final gudang = _gudangList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(gudang.namaGudang),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(gudang.alamat),
                          Row(
                            children: [
                              Text('Jumlah: ${gudang.jumlah}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  gudang.namaStatus ?? 'Unknown',
                                  style: TextStyle(fontSize: 10, color: Colors.blue[800]),
                                ),

                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TambahGudangScreen(gudang: gudang),
                              ),
                            ).then((_) => _loadGudang());
                          } else if (value == 'delete') {
                            _showDeleteDialog(gudang);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahGudangScreen()),
          ).then((_) => _loadGudang());
        },
        backgroundColor: const Color(0xFFD32F2F),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(Gudang gudang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Gudang'),
        content: Text('Yakin ingin menghapus ${gudang.namaGudang}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGudang(gudang.idGudang!);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showTokenExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text('Sesi Anda telah berakhir. Silakan login ulang.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Login Ulang'),
          ),
        ],
      ),
    );
  }
}