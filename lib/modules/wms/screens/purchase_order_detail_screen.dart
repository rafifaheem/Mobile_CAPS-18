import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/wms_models.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';
import 'package:cargoind/modules/wms/screens/goods_receipt_screen.dart';
import 'package:cargoind/modules/wms/screens/quality_control_screen.dart';
import 'package:cargoind/modules/wms/screens/put_away_screen.dart';

class PurchaseOrderDetailScreen extends StatefulWidget {
  final PO po;

  const PurchaseOrderDetailScreen({Key? key, required this.po}) : super(key: key);

  @override
  _PurchaseOrderDetailScreenState createState() => _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  List<DetailPO> details = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _debugPOData();
    _loadPODetails();
  }

  void _debugPOData() {
    print('🔧 === DEBUG PO DATA ===');
    print('🔧 UUID Order: "${widget.po.uuidOrder}"');
    print('🔧 ID Order: ${widget.po.idOrder}');
    print('🔧 Harga Total: ${widget.po.hargaTotal}');
    print('🔧 ID Gudang: ${widget.po.idGudang}');
    print('🔧 ID Vendor: ${widget.po.idVendor}');
    print('🔧 Gudang: ${widget.po.gudang?.namaGudang}');
    print('🔧 =====================');
  }

  Future<void> _loadPODetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      print('🔧 Loading PO details for: ${widget.po.uuidOrder}');
      print('🔧 PO ID: ${widget.po.idOrder}');
      
      final result = await WMSService.getPODetails(widget.po.uuidOrder);
      
      setState(() {
        details = result;
        isLoading = false;
      });
      
      print('🔧 Successfully loaded ${result.length} details');
    } catch (e) {
      print('🔧 Error loading PO details: $e');
      setState(() {
        errorMessage = 'PO ini belum memiliki detail item. Silakan tambahkan item terlebih dahulu.';
        isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      print('🔧 Testing API connection...');
      final apiCheck = await WMSService.testApiConnection();
      final poListCheck = await WMSService.testPOListEndpoint();
      
      setState(() {
        isLoading = false;
        errorMessage = 'Connection Test Results:\n'
            'API Connection: ${apiCheck ? "✅ OK" : "❌ Failed"}\n'
            'PO List Endpoint: ${poListCheck ? "✅ OK" : "❌ Failed"}\n\n'
            'Endpoint yang bekerja: /api/po/list\n'
            'Detail PO endpoint: /api/po/detail/{uuid}';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Connection test failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PO Detail - ${widget.po.nomorPO}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // PO Header Info
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.po.nomorPO,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Total: Rp ${widget.po.hargaTotal.toStringAsFixed(0)}'),
                Text('UUID: ${widget.po.uuidOrder}'),
                Text('ID Order: ${widget.po.idOrder}'),
                if (widget.po.gudang != null) ...[
                  const SizedBox(height: 4),
                  Text('Warehouse: ${widget.po.gudang!.namaGudang}'),
                  Text('Address: ${widget.po.gudang!.alamat}'),
                ],
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoodsReceiptScreen(po: widget.po),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inventory),
                    label: const Text('Goods Receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QualityControlScreen(po: widget.po),
                        ),
                      );
                    },
                    icon: const Icon(Icons.verified),
                    label: const Text('Quality Control'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // PO Details List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadPODetails,
                              child: const Text('Retry'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _testConnection,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Test Connection'),
                            ),
                          ],
                        ),
                      )
                    : details.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No details found for this PO'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: details.length,
                            itemBuilder: (context, index) {
                              final detail = details[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    detail.produk?.namaProduk ?? 'Product #${detail.idProduk}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Quantity: ${detail.jumlah}'),
                                      Text('Price: Rp ${detail.harga.toStringAsFixed(0)}'),
                                      Text('Total: Rp ${(detail.jumlah * detail.harga).toStringAsFixed(0)}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.warehouse),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PutAwayScreen(po: widget.po),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}