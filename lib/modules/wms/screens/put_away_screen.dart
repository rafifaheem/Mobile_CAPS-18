import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/wms_models.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';

class PutAwayScreen extends StatefulWidget {
  final PO? po;

  const PutAwayScreen({super.key, this.po});

  @override
  State<PutAwayScreen> createState() => _PutAwayScreenState();
}

class _PutAwayScreenState extends State<PutAwayScreen> {
  List<DetailPO> poDetails = [];
  List<LokasiRak> availableLocations = [];
  List<Gudang> warehouses = [];
  final Map<int, int?> selectedLocations = {};
  bool isLoading = true;
  int? selectedWarehouse;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final details = await WMSService.getPODetails(widget.po?.uuidOrder ?? '');
      
      setState(() {
        poDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> loadLocations(int idGudang) async {
    try {
      final locations = await WMSService.getAvailableLocations(idGudang);
      setState(() {
        availableLocations = locations.where((loc) => !loc.statusPenuh).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading locations: $e')),
      );
    }
  }

  Future<void> processPutAway() async {
    if (selectedLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign locations for all items')),
      );
      return;
    }

    final putAwayData = {
      'id_po': widget.po?.idOrder ?? 1,
      'items': poDetails.map((detail) => {
        'id_produk': detail.idProduk,
        'id_lokasi': selectedLocations[detail.idDetailPO],
        'jumlah': detail.jumlah,
      }).toList(),
      'tanggal_putaway': DateTime.now().toIso8601String(),
    };

    final success = await WMSService.putAwayItems(putAwayData);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Put away completed successfully')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete put away')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Put Away - ${widget.po?.nomorPO ?? 'N/A'}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.purple.shade50,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.place, color: Colors.purple.shade700),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Assign Storage Locations',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Select Warehouse',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        initialValue: selectedWarehouse,
                        items: warehouses.map((gudang) {
                          return DropdownMenuItem<int>(
                            value: gudang.idGudang,
                            child: Text(gudang.namaGudang),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedWarehouse = value;
                            selectedLocations.clear();
                          });
                          if (value != null) {
                            loadLocations(value);
                          }
                        },
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
                                detail.produk?.namaProduk ?? 'Product ${detail.idProduk}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('Quantity: ${detail.jumlah}'),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Assign Location',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                initialValue: selectedLocations[detail.idDetailPO],
                                items: availableLocations.map((location) {
                                  return DropdownMenuItem<int>(
                                    value: location.idLokasi,
                                    child: Text('${location.namaLokasi} (${location.kapasitasBerat}kg)'),
                                  );
                                }).toList(),
                                onChanged: selectedWarehouse == null ? null : (value) {
                                  setState(() {
                                    selectedLocations[detail.idDetailPO] = value;
                                  });
                                },
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
                      onPressed: selectedLocations.length == poDetails.length ? processPutAway : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Complete Put Away'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}