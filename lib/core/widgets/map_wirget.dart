import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../config/map_config.dart';

Future<List<LatLng>> fetchRoute({
  required LatLng start,
  required LatLng end,
}) async {
  final url = Uri.parse(
    '${MapConfig.routingUrl}/route'
    '?point=${start.latitude},${start.longitude}'
    '&point=${end.latitude},${end.longitude}'
    '&profile=car&type=json&elevation=false&points_encoded=false',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final paths = data['paths'];
    if (paths != null && paths.isNotEmpty) {
      final coords = paths[0]['points']['coordinates'] as List;
      return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
    } else {
      throw Exception('No route found');
    }
  } else {
    throw Exception('Failed to load route: ${response.statusCode}');
  }
}

List<LatLng> getLatLngBounds(List<LatLng> points) {
  if (points.isEmpty) {
    throw ArgumentError('Points list cannot be empty');
  }
  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;
  for (var p in points) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLng) minLng = p.longitude;
    if (p.longitude > maxLng) maxLng = p.longitude;
  }
  return [LatLng(minLat, minLng), LatLng(maxLat, maxLng)];
}

enum MapDirection {
  north,
  heading,
  custom
}

class XYZ {
  final int _dec = 3;
  final double x;
  final double y;
  final double z;

  const XYZ(this.x, this.y, this.z);

  @override
  String toString() => '(${x.toStringAsFixed(_dec)}, ${y.toStringAsFixed(_dec)}, ${z.toStringAsFixed(_dec)})';
}

class MapWidget extends StatefulWidget {
  final List<LatLng> locations;
  final LatLng? currentLocation;
  final MapController? controller;

  const MapWidget({
    super.key,
    required this.locations,
    this.currentLocation,
    this.controller,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late final MapController _mapController;
  final LatLng _fallbackLocation = LatLng(-7.17823, 112.65155);
  List<LatLng> routePoints = [];
  double _currentZoom = 13.0;
  double _rotation = 0.0;
  bool _mapReady = false;
  double _heading = 0.0;
  String _accelStatus = 'Waiting...';
  String _gyroStatus = 'Waiting...';
  XYZ _magnet = XYZ(0.0,0.0,0.0);
  XYZ _accel = XYZ(0.0,0.0,0.0);
  XYZ _gyro = XYZ(0.0,0.0,0.0);
  StreamSubscription<MagnetometerEvent>? _magnetSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<Position>? _posSub;
  double _speedKmh = 0.0; // km/h
  MapDirection _mapDirection = MapDirection.north;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.mapEventStream.listen((event) {
        if (!_mapReady) {
          setState(() => _mapReady = true);
        }
      });
    });

    // Location speed
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((pos) {
      setState(() => _speedKmh = pos.speed * 3.6); // m/s to km/h
    });

    // Accelerometer
    _accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      _accel = XYZ(event.x,event.y,event.z);
      double magnitude = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      setState(() {
        _accelStatus = magnitude > 12 ? 'Motion detected' : 'Stable';
      });
    });

    // Gyroscope
    _gyroSub = gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (!mounted) return;
      _gyro = XYZ(event.x,event.y,event.z);
      double rot = (event.x.abs() + event.y.abs() + event.z.abs()) / 3;
      setState(() {
        _gyroStatus = rot > 1 ? 'Rotating' : 'Steady';
      });
    });
    _startPositionStream();

    // Compass
    _magnetSub = magnetometerEventStream().listen((MagnetometerEvent event) {
      if (!mounted) return;      
      _magnet = XYZ(event.x, event.y, event.z);

      setState(() {
        _heading = _calculateHeading(mx: _magnet.x, my: _magnet.y, mz: _magnet.z, 
                                     ax: _accel.x, ay: _accel.y, az: _accel.z) ;
      });
    }, onError: (error) {
      print('Magnetometer error: $error');
    });

  }

  @override
  void dispose() {
    _magnetSub?.cancel();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _posSub?.cancel();
    super.dispose();
  }

  void _startPositionStream() {
    // minimal options - adjust desiredAccuracy if needed
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1, // meters
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings)
      .listen((Position pos) {
    final s = (pos.speed.isFinite ? pos.speed : 0.0);
    setState(() {
      _speedKmh = (s * 3.6);
    });
    }, onError: (e) {
      debugPrint('Position stream error: $e');
    });
  }

  Future<void> _loadRoute() async {
    try {
      final points = await fetchRoute(
        start: widget.locations.first,
        end: widget.locations.last,
      );
      setState(() {
        routePoints = points;
      });
    } catch (e) {
      debugPrint('Route fetch error: $e');
    }
  }

  void _resetBearing() {
    setState(() {
      _rotation = 0;
      _mapDirection = MapDirection.north;
    });

    if(_mapReady){
      _mapController.rotate(_rotation);
    }
  }

  void _resetHeading() {
    setState(() {
      _rotation = _heading;
      _mapDirection = MapDirection.heading;
    });
    
    if(_mapReady){
      _mapController.rotate(_rotation);
    }
  }

  double _calculateHeading({
    required double mx,
    required double my,
    required double mz,
    required double ax,
    required double ay,
    required double az,
  }) {
    // Roll & pitch
    final roll  = math.atan2(ay, az);
    final pitch = math.atan2(-ax, math.sqrt(ay * ay + az * az));

    // Tilt compensation
    final mxComp = mx * math.cos(pitch) + mz * math.sin(pitch);
    final myComp = mx * math.sin(roll) * math.sin(pitch)
                + my * math.cos(roll)
                - mz * math.sin(roll) * math.cos(pitch);

    // Heading
    var heading = math.atan2(-mxComp, myComp) * 180 / pi;
    if (heading < 0) heading += 360;
    return heading;
  }


  void _zoomIn() {
    setState(() => _currentZoom += 1);
    if(_mapReady){
      _mapController.move(_mapController.camera.center, _currentZoom);
    }
  }

  void _zoomOut() {
    setState(() => _currentZoom -= 1);
    if(_mapReady){
      _mapController.move(_mapController.camera.center, _currentZoom);
    }
  }

  double get _cameraDistance {
    if (!_mapReady || widget.currentLocation == null) return 0;
    final Distance distance = Distance();
    return distance(_mapController.camera.center, widget.currentLocation!);
  }

  @override
  Widget build(BuildContext context) {
    double _deg2rad = math.pi / 180;
    LatLng currentLocation = widget.currentLocation ?? _fallbackLocation;
    List<LatLng> locationsBound =
        getLatLngBounds(widget.locations.isNotEmpty ? widget.locations : [currentLocation]);
    final center = LatLng(
      (locationsBound.first.latitude + locationsBound.last.latitude) / 2,
      (locationsBound.first.longitude + locationsBound.last.longitude) / 2,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center, initialZoom: _currentZoom,
            onMapEvent: (event) {
              if (event is MapEventRotate) {
                setState(() => _rotation = _mapController.camera.rotation % 360 );
              }
              if (event is MapEventScrollWheelZoom || event is MapEventDoubleTapZoom || event is MapEventMove){
                setState(() => _currentZoom = _mapController.camera.zoom );
              }
            },
          ),
          children: [
            TileLayer(
              //urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              urlTemplate: MapConfig.tileUrl,
               //subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.cargoind.app',
            ),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              showFlutterMapAttribution: false,
              attributions: [
                TextSourceAttribution(
                  MapConfig.mapAttribution,
                  onTap: () => launchUrl(
                    Uri.parse(MapConfig.mapAttributionUrl),
                  ),
                ),
              ],
            ),

            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(points: routePoints, strokeWidth: 4, color: Colors.blue),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40, height: 40,
                  point: widget.currentLocation!,
                  alignment: Alignment.topCenter,
                  
                  child: Transform.rotate(
                    angle: -_rotation * _deg2rad, // rotate marker based on map rotation
                    alignment: Alignment.bottomCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
                /*Marker(
                  width: 40,
                  height: 40,
                  point: widget.locations.last,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                ),*/
              ],
            ),
          ],
        ),

        // 🧭 Compass (tilts dynamically with rotation)
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: _mapDirection!=MapDirection.north?_resetBearing:_resetHeading,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer compass rotates with the map
                    Transform.rotate(
                      angle: _rotation * _deg2rad,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _rotation==0?Colors.black:Colors.red),
                          color: Colors.white.withValues(alpha:0.8),
                        ),
                        child: Center(
                          child: Icon(Icons.navigation, color: Colors.red, size: 30),
                        ),
                      ),
                    ),

                    Transform.rotate(
                      angle: (_heading + _rotation) * _deg2rad,
                      child: Container(
                        width: 50,
                        height: 50,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 2,
                            height: 25, // half of circle diameter
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),


                    // “N” text fixed (doesn’t rotate)
                    Positioned(
                      top: 20 - 18 * math.cos(_rotation * _deg2rad),
                      left: 20 + 18 * math.sin(_rotation * _deg2rad),
                      child: Text(
                        'N',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _rotation==0?"":"${(360 - _rotation).toStringAsFixed(1)}° ${(_heading).toStringAsFixed(1)}°",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        
        // GPS recenter button (above zoom buttons)
        Positioned(
          bottom: 110, // slightly above the zoom in/out buttons
          right: 10,
          child: FloatingActionButton(
            heroTag: 'gps',
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              if (_mapReady) {
                _mapController.move(widget.currentLocation!, _currentZoom);
              }
            },
            child: Icon(Icons.gps_fixed, 
              color: _mapReady?_cameraDistance>50?Colors.red:Colors.blueGrey:Colors.blueGrey
              ),
          ),
        ),

        // ➕➖ Zoom controls
        Positioned(
          bottom: 10,
          right: 10,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: "zoom_in",
                mini: true,
                onPressed: _zoomIn,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "zoom_out",
                mini: true,
                onPressed: _zoomOut,
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),

        // bottom-left speedometer overlay
        Positioned(
          left: 50,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.speed, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_speedKmh.toStringAsFixed(1)} km/h',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        // Accelerometer & Gyro bottom-right
        Positioned(
          top: 70,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Accel: $_accel',
                    style: const TextStyle(color: Colors.white)),
                Text('Gyro: $_gyro',
                    style: const TextStyle(color: Colors.white)),
                Text('Magnet: $_magnet',
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),

      ],
    );
  }
}
