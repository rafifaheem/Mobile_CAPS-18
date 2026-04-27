import 'package:flutter/material.dart';
import 'package:cargoind/modules/wms/models/wms_models.dart';
import 'package:cargoind/modules/wms/services/wms_service.dart';
import 'package:cargoind/modules/wms/screens/put_away_screen.dart';

class QualityControlScreen extends StatefulWidget {
  final PO? po;

  const QualityControlScreen({super.key, this.po});

  @override
  State<QualityControlScreen> createState() => _QualityControlScreenState();
}

class _QualityControlScreenState extends State<QualityControlScreen> {
  List<DetailPO> poDetails = [];
  final TextEditingController catatanController = TextEditingController();
  final Map<int, bool> qcResults = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQCList();
  }

  Future<void> loadQCList() async {
    setState(() => isLoading = true);
    try {
      final qcList = await WMSService.getQualityControlList();
      setState(() {
        poDetails = qcList;
        // Initialize QC results
        for (var detail in qcList) {
          qcResults[detail.idDetailPO] = true; // Default to pass
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading QC list: $e')),
      );
    }
  }

  Future<void> submitQualityControl() async {
    final qcData = {
      'id_po': widget.po?.idOrder ?? 1,
      'id_user': 1, // Current user ID
      'catatan': catatanController.text,
      'id_status_qc': _allItemsPass() ? 1 : 2, // 1=Pass, 2=Fail
      'items': poDetails.map((detail) => {
        'id_detailpo': detail.idDetailPO,
        'hasil_qc': qcResults[detail.idDetailPO] == true ? 'PASS' : 'FAIL',
        'memenuhi': qcResults[detail.idDetailPO] == true,
      }).toList(),
    };

    final success = await WMSService.createQualityControl(qcData);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quality control completed')),
      );
      
      if (_allItemsPass()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PutAwayScreen(po: widget.po),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit quality control')),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_outlined,
                      size: 60,
                      color: Colors.orange.shade400,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'No QC Items',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No items available for quality control',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: loadQCList,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  bool _allItemsPass() {
    return qcResults.values.every((result) => result == true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quality Control - ${widget.po?.nomorPO ?? 'N/A'}'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : poDetails.isEmpty
              ? _buildEmptyState()
              : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QC Inspection - ${widget.po?.nomorPO ?? 'N/A'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text('Check each item quality'),
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
                                detail.produk?.namaProduk ?? 'Product ${detail.idProduk}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('Quantity: ${detail.jumlah}'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text('Quality Check: '),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: RadioGroup<bool>( // <-- Use RadioGroup to manage the state
                                      groupValue: qcResults[detail.idDetailPO], // <-- The groupValue goes here
                                      onChanged: (bool? value) { // <-- The onChanged handler goes here
                                        setState(() {
                                          // Update the specific entry in your map using the new value
                                          qcResults[detail.idDetailPO] = value!; 
                                        });
                                      },
                                      child: Row( // The child contains the individual radio buttons
                                        children: [
                                          Radio<bool>(
                                            value: true,
                                            // groupValue and onChanged are handled by the RadioGroup ancestor
                                          ),
                                          const Text('Pass'),
                                          Radio<bool>(
                                            value: false,
                                            // groupValue and onChanged are handled by the RadioGroup ancestor
                                          ),
                                          const Text('Fail'),
                                        ],
                                      ),
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
                  child: Column(
                    children: [
                      TextField(
                        controller: catatanController,
                        decoration: const InputDecoration(
                          labelText: 'QC Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitQualityControl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(_allItemsPass() ? 'Approve & Continue' : 'Reject Items'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }
}