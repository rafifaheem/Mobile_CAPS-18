import 'package:flutter/material.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  String _selectedOrderType = 'purchase'; // 'sales', 'purchase', 'delivery

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manajemen Order',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFFF0000), width: 3),
        ),
      ),
      body: Column(
        children: [
          // Tab Buttons
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Sales Order',
                    'sales',
                    isMobile,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    'Purchase Order',
                    'purchase',
                    isMobile,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    'Delivery Order',
                    'delivery',
                    isMobile,
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              isMobile ? 12 : 16,
              0,
              isMobile ? 12 : 16,
              isMobile ? 12 : 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari order...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFFF0000)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterButton(
                    'Berdasarkan Tanggal:', Icons.calendar_today),
                const SizedBox(width: 8),
                _buildFilterButton('Urutkan Dari:', Icons.arrow_drop_down),
              ],
            ),
          ),

          // Order List
          Expanded(
            child: _buildOrderList(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String type, bool isMobile) {
    final isActive = _selectedOrderType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedOrderType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF0000) : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFFFF0000) : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildOrderList(bool isMobile) {
    // Sample data untuk Purchase Order sesuai gambar
    final purchaseOrders = [
      {
        'orderId': 'PO016',
        'date': '03 Februari 2026',
        'fromCode': 'SIG',
        'toName': 'Silog',
        'productType': 'Semen ZAK',
        'description': 'Order PO 02 Feb 2026',
        'quantity': 4000,
        'total': 3600000000,
      },
      {
        'orderId': 'PO018',
        'date': '04 Februari 2026',
        'fromCode': 'SIG',
        'toName': 'Silog',
        'productType': 'Semen Curah',
        'description': 'Purchase Order 04 Feb 2026',
        'quantity': 12000,
        'total': 3676572000,
      },
    ];

    final salesOrders = [
      {
        'orderId': 'SO001',
        'date': '05 Februari 2026',
        'fromCode': 'BSD',
        'toName': 'PT Bina',
        'productType': 'Pasir',
        'description': 'Sales Order 05 Feb 2026',
        'quantity': 5000,
        'total': 2500000000,
      },
    ];

    final deliveryOrders = [
      {
        'orderId': 'DO001',
        'date': '06 Februari 2026',
        'fromCode': 'JKT',
        'toName': 'Jakarta',
        'productType': 'Batu Bata',
        'description': 'Delivery Order 06 Feb 2026',
        'quantity': 3000,
        'total': 1800000000,
      },
    ];

    List<Map<String, dynamic>> currentOrders;
    switch (_selectedOrderType) {
      case 'sales':
        currentOrders = salesOrders;
        break;
      case 'purchase':
        currentOrders = purchaseOrders;
        break;
      case 'delivery':
        currentOrders = deliveryOrders;
        break;
      default:
        currentOrders = purchaseOrders;
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: currentOrders.length,
      itemBuilder: (context, index) {
        return _buildPurchaseOrderCard(currentOrders[index], isMobile);
      },
    );
  }

  Widget _buildPurchaseOrderCard(Map<String, dynamic> order, bool isMobile) {
    // Format harga
    String formattedTotal =
        'Rp ${(order['total'] as num).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFF0000), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Order ID & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['orderId'],
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  order['date'],
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // From → To
            Row(
              children: [
                Text(
                  order['fromCode'],
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFFFF0000),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  order['toName'],
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Product Type Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                order['productType'],
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              '"${order['description']}"',
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Quantity
            Text(
              'Jumlah : ${order['quantity']}',
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),

            // Total
            Text(
              'Total : $formattedTotal',
              style: TextStyle(
                fontSize: isMobile ? 14 : 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Details Button
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to detail page
                  _showComingSoon('Detail Order');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF0000), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(
                    color: Color(0xFFFF0000),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('Fitur ini akan segera hadir!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFFF0000)),
            ),
          ),
        ],
      ),
    );
  }
}
