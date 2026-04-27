import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/wms_models.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';
import 'package:cargoind/modules/wms/screens/purchase_order_detail_screen.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  List<PO> purchaseOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPurchaseOrders();
  }

  Future<void> loadPurchaseOrders() async {
    setState(() => isLoading = true);
    try {
      final pos = await WMSService.getPurchaseOrders();
      setState(() {
        purchaseOrders = pos;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading POs: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchaseOrders.isEmpty
              ? const Center(
                  child: Text(
                    'No Purchase Orders found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadPurchaseOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: purchaseOrders.length,
                    itemBuilder: (context, index) {
                      final po = purchaseOrders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              po.idOrder.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            po.nomorPO ?? 'PO #${po.idOrder}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total: Rp ${po.hargaTotal.toStringAsFixed(0)}'),
                              if (po.gudang != null)
                                Text('Warehouse: ${po.gudang!.namaGudang}'),
                              if (po.idVendor != null)
                                Text('Vendor ID: ${po.idVendor}'),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PurchaseOrderDetailScreen(po: po),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}