import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/wms_models.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';
import 'package:cargoind/modules/wms/screens/quality_control_screen.dart';

class GoodsReceiptScreen extends StatefulWidget {
  final PO? po;

  const GoodsReceiptScreen({super.key, this.po});

  @override
  State<GoodsReceiptScreen> createState() => _GoodsReceiptScreenState();
}

class _GoodsReceiptScreenState extends State<GoodsReceiptScreen> {
  List<DetailPO> poDetails = [];
  List<TextEditingController> receivedControllers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPODetails();
  }

  Future<void> loadPODetails() async {
    setState(() => isLoading = true);
    try {
      final details = await WMSService.getPODetails(widget.po?.uuidOrder ?? '');
      setState(() {
        poDetails = details;
        receivedControllers = details.map((e) => TextEditingController()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PO details: $e')),
      );
    }
  }

 Future<void> processReceipt() async {
  List<Map<String, dynamic>> receivedItems = [];

  for (int i = 0; i < poDetails.length; i++) {
    final detail = poDetails[i];
    final text = receivedControllers[i].text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter received quantity for ${detail.produk?.namaProduk ?? "Product ${detail.idProduk}"}',
          ),
        ),
      );
      return; // hentikan proses jika ada field kosong
    }

    final receivedQty = int.tryParse(text);
    if (receivedQty == null || receivedQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid quantity for ${detail.produk?.namaProduk ?? "Product ${detail.idProduk}"}',
          ),
        ),
      );
      return; // hentikan proses jika input bukan angka positif
    }

    receivedItems.add({
      'id_produk': detail.idProduk,
      'jumlah_diterima': receivedQty,
      'jumlah_po': detail.jumlah,
    });
  }

  // Semua input valid, buat data receipt
  final receiptData = {
    'id_po': widget.po?.idOrder ?? 1,
    'items': receivedItems,
    'tanggal_terima': DateTime.now().toIso8601String(),
  };

  try {
    final success = await WMSService.createGoodsReceipt(receiptData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goods receipt created successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QualityControlScreen(po: widget.po),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create goods receipt')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error creating receipt: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goods Receipt - ${widget.po?.nomorPO ?? 'N/A'}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.receipt, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PO: ${widget.po?.nomorPO ?? 'N/A'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Date: ${widget.po?.tglPO.toString().split(' ')[0] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: poDetails.length,
                    itemBuilder: (context, index) {
                      final detail = poDetails[index];
                      return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Product ID: ${detail.idProduk}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),

                          Text('Kuntitas: ${detail.jumlah}'),
                          Text('Harga: ${detail.harga}'),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: receivedControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Received',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );

                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: processReceipt,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Process Receipt'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    for (var controller in receivedControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}