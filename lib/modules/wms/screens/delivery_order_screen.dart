import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wms_models.dart';
import '../services/wms_service.dart';

class DeliveryOrderScreen extends StatefulWidget {
  const DeliveryOrderScreen({Key? key}) : super(key: key);

  @override
  _DeliveryOrderScreenState createState() => _DeliveryOrderScreenState();
}

class _DeliveryOrderScreenState extends State<DeliveryOrderScreen> {
  List<HeaderDeliveryOrder> deliveryOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDeliveryOrders();
  }

  Future<void> loadDeliveryOrders() async {
    setState(() => isLoading = true);
    try {
      final result = await WMSService.getDeliveryOrders();
      setState(() {
        deliveryOrders = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat Delivery Order: $e')),
      );
    }
  }

  String formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '-';
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Order'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : deliveryOrders.isEmpty
              ? const Center(child: Text('Belum ada Delivery Order'))
              : ListView.builder(
                  itemCount: deliveryOrders.length,
                  itemBuilder: (context, index) {
                    final item = deliveryOrders[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),

                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(Icons.local_shipping, color: Colors.black),
                        ),

                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // KIRI
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("No Polisi     : ${item.noPolisi ?? '-'}"),
                                Text("No Lambung : ${item.noLambung ?? '-'}"),
                              ],
                            ),

                            // KANAN
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Nama Driver : ${item.nama ?? '-'}",),
                                Text("Produk           : ${item.namaProduk ?? '-'}"),
                              ],
                            ),
                          ],
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {},
                      )
                    );
                  },
                ),
    );
  }
}
