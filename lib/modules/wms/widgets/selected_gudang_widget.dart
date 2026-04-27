import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cargoind/modules/wms/providers/gudang_provider.dart';

class SelectedGudangWidget extends StatelessWidget {
  const SelectedGudangWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GudangProvider>(
      builder: (context, gudangProvider, child) {
        final selectedGudang = gudangProvider.selectedGudang;
        
        if (selectedGudang == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warehouse, color: Colors.blue),
                SizedBox(width: 8),
                Text('Pilih gudang di profil'),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.warehouse, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedGudang.namaGudang,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    if (selectedGudang.alamat.isNotEmpty)
                      Text(
                        selectedGudang.alamat,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}