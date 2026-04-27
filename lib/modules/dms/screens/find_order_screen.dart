import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:cargoind/core/widgets/map_wirget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cargoind/modules/dms/services/api_service.dart';

class FindOrderScreen extends StatefulWidget {
  const FindOrderScreen({super.key});

  @override
  State<FindOrderScreen> createState() => _FindOrderScreenState();
}

class _FindOrderScreenState extends State<FindOrderScreen> {
  final String title = "Find Order";
  bool autoRefresh = true;
  String searchQuery = '';
  List<LatLng> locations = [];
  LatLng? currentLocation;
  Timer? _timer;
  List<dynamic> _nearbyOrders = [];
  bool _isSearching = false;
  final ApiService _apiService = ApiService();
  bool _autoSearchEnabled = false;

  @override
  void initState() {
    super.initState();
    _detectCurrentLocation();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _detectCurrentLocation();
      if (_autoSearchEnabled && currentLocation != null) {
        _searchNearbyOrders();
      }
    });
  }

  Future<void> _detectCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        locations = [currentLocation!]; // center marker on user position
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _searchNearbyOrders() async {
    if (currentLocation == null) {
      if (!_autoSearchEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi belum terdeteksi. Tunggu sebentar...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final orders = await _apiService.searchOrdersByLocation(
        currentLocation!.latitude,
        currentLocation!.longitude,
        radiusKm: 5.0,
      );

      setState(() {
        _nearbyOrders = orders;
        _isSearching = false;
      });

      if (!_autoSearchEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ditemukan ${orders.length} order dalam radius 5km'),
            backgroundColor: orders.isNotEmpty ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _nearbyOrders = [];
      });

      if (!_autoSearchEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencari order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // stop refreshing when screen closes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: title,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Text("Auto"),
                Switch(
                  value: _autoSearchEnabled,
                  onChanged: (v) {
                    setState(() {
                      _autoSearchEnabled = v;
                      if (v && currentLocation != null) {
                        _searchNearbyOrders();
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: MapWidget(
              locations: locations,
              currentLocation: currentLocation,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentLocation == null)
                  const Text("Detecting location..."),
                if (currentLocation != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current: (${currentLocation!.latitude.toStringAsFixed(5)}, "
                        "${currentLocation!.longitude.toStringAsFixed(5)})",
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _autoSearchEnabled ? Icons.search : Icons.search_off,
                            size: 16,
                            color: _autoSearchEnabled ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _autoSearchEnabled ? 'Auto search: ON' : 'Auto search: OFF',
                            style: TextStyle(
                              fontSize: 12,
                              color: _autoSearchEnabled ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: currentLocation != null && !_isSearching ? _searchNearbyOrders : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Cari Order (5km)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_nearbyOrders.isNotEmpty) ...[
                  const Text(
                    'Order Terdekat (5km):',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: _nearbyOrders.length,
                      itemBuilder: (context, index) {
                        final order = _nearbyOrders[index];
                        final jarakPickup = order['jarak_pickup'] ?? 0.0;
                        final jarakDelivery = order['jarak_delivery'] ?? 0.0;
                        final jarakTerdekat = jarakPickup < jarakDelivery ? jarakPickup : jarakDelivery;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.local_shipping, color: Colors.blue),
                            title: Text(order['pickup_address'] ?? 'Alamat pickup'),
                            subtitle: Text(
                              'Tujuan: ${order['delivery_address'] ?? 'Alamat tujuan'}\n'
                              'Jarak: ${jarakTerdekat.toStringAsFixed(1)} km • Order: ${order['nomor_order'] ?? 'N/A'}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp ${(order['fee'] ?? 0).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  order['kode_jenis_order'] ?? 'PICKUP',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              // TODO: Navigate to order details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Order: ${order['nomor_order']} - ${order['uuid_order']}'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (_nearbyOrders.isEmpty && currentLocation != null && !_isSearching) ...[
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Tidak ada order dalam radius 5km',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Coba cari lagi atau aktifkan auto search',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isSearching) ...[
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          'Mencari order terdekat...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
