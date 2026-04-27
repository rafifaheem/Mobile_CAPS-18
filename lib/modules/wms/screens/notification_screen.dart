import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateSection('Hari ini'),
          _buildNotificationItem(
            'Pesanan telah selesai. Terima kasih atas kerja keras Anda!',
            '6 Juli 2026, 18.40',
          ),
          _buildNotificationItem(
            'Pesanan telah selesai. Terima kasih atas kerja keras Anda!',
            '6 Juli 2026, 18.40',
          ),
          
          const SizedBox(height: 24),
          _buildDateSection('Kemarin'),
          _buildNotificationItem(
            'Pesanan telah selesai. Terima kasih atas kerja keras Anda!',
            '6 Juli 2026, 18.40',
          ),
          _buildNotificationItem(
            'Pesanan telah selesai. Terima kasih atas kerja keras Anda!',
            '6 Juli 2026, 18.40',
          ),
          
          const SizedBox(height: 24),
          _buildDateSection('7 Hari yang lalu'),
          _buildNotificationItem(
            'Pesanan telah selesai. Terima kasih atas kerja keras Anda!',
            '6 Juli 2026, 18.40',
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String message, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}