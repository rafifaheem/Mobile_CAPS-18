import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/widgets/warehouse_card.dart';
import 'package:cargoind/modules/wms/utils/app_colors.dart';
import 'package:cargoind/modules/wms/screens/purchase_order_screen.dart';
import 'package:cargoind/modules/wms/screens/delivery_order_screen.dart';
import '../widgets/warehouse_card.dart';
import '../utils/app_colors.dart';


class InboundDashboardScreen extends StatelessWidget {
  const InboundDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbound Operations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            WarehouseCard(
              title: 'Delivery Order',
              subtitle: 'View & manage DOs',
              icon: Icons.local_mall,
              color: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryOrderScreen(),
                  ),
                );
              },
            ),
            WarehouseCard(
              title: 'Purchase Orders',
              subtitle: 'View & manage POs',
              icon: Icons.shopping_cart,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseOrderScreen(),
                  ),
                );
              },
            ),
            WarehouseCard(
              title: 'Goods Receipt',
              subtitle: 'Receive incoming goods',
              icon: Icons.receipt_long,
              color: Colors.green,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a PO first from Purchase Orders')),
                );
              },
            ),
            WarehouseCard(
              title: 'Put Away',
              subtitle: 'Store items in locations',
              icon: Icons.place,
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete Quality Control first')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}