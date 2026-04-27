import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/wms_models.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';
import '../../../core/mixins/error_handler_mixin.dart';

class InventoryStokScreen extends StatefulWidget {
  const InventoryStokScreen({super.key});

  @override
  State<InventoryStokScreen> createState() => _InventoryStokScreenState();
}

class _InventoryStokScreenState extends State<InventoryStokScreen> with ErrorHandlerMixin {
  List<Stok> _stokList = [];
  bool _isLoading = true;
  final WMSService _wmsService = WMSService();
  
  @override
  void initState() {
    super.initState();
    _loadStock();
  }
  
  Future<void> _loadStock() async {
    try {
      final stokList = await _wmsService.getStock();
      setState(() {
        _stokList = stokList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      handleError(context, e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStock,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stokList.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada data inventory',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStock,
                  child: ListView.builder(
                    itemCount: _stokList.length,
                    itemBuilder: (context, index) {
                      final stok = _stokList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: Colors.blue[800],
                            ),
                          ),
                          title: Text(
                            stok.produk?.namaProduk ?? 'Produk ID: ${stok.idProduk}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lokasi: ${stok.lokasi?.namaLokasi ?? 'Lokasi ID: ${stok.idLokasi}'}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                'Tanggal Masuk: ${stok.tglMasuk.day}/${stok.tglMasuk.month}/${stok.tglMasuk.year}',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${stok.jumlah}',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
