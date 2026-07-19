import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // OpenStreetMap
import 'package:latlong2/latlong.dart';      // Coordinates & Distance
import 'package:geocoding/geocoding.dart';   // Address Lookup (Fallback)
import 'package:geolocator/geolocator.dart'; // GPS for User

class WorkerMapScreen extends StatefulWidget {
  // Hum sab kuch optional (?) rakhenge taake purana aur naya dono code chalain
  final double? workerLat;
  final double? workerLng;
  final String? address;
  final String? city;
  final bool showExactLocation;

  const WorkerMapScreen({
    super.key,
    this.workerLat,
    this.workerLng,
    this.address,
    this.city,
    required this.showExactLocation,
  });

  @override
  State<WorkerMapScreen> createState() => _WorkerMapScreenState();
}

class _WorkerMapScreenState extends State<WorkerMapScreen> {
  static const Color lightSeaGreen = Color(0xFF20B2AA);
  LatLng _workerPosition = const LatLng(31.5497, 74.3436); // Default Lahore
  LatLng? _userPosition;
  bool _isLoading = true;
  String _distanceInfo = "Calculating...";

  List<Marker> _markers = [];
  List<CircleMarker> _circles = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  // --- YE FUNCTION DECIDE KAREGA KE COORDINATES USE KARNE HAIN YA ADDRESS ---
  Future<void> _resolveLocation() async {
    try {
      // SCENARIO 1: Coordinates Available hain (New Method)
      if (widget.workerLat != null && widget.workerLng != null) {
        _workerPosition = LatLng(widget.workerLat!, widget.workerLng!);
        _setupMarkers(); // Seedha Markers lagao
      }
      // SCENARIO 2: Coordinates nahi hain, Address use karo (Old Method - Backup)
      else if (widget.address != null && widget.city != null) {
        await _geocodeAddress();
      }

      // Step 2: User ki GPS Location lo
      await _getUserLocation();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Setup Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // Address se Coordinates nikalne ka logic (Backup for old screens)
  Future<void> _geocodeAddress() async {
    try {
      String query = widget.showExactLocation
          ? "${widget.address}, ${widget.city}, Pakistan"
          : "${widget.city}, Pakistan";

      List<Location> locations = [];
      try {
        locations = await locationFromAddress(query);
      } catch (e) {
        // Fallback to City only
        try {
          locations = await locationFromAddress("${widget.city}, Pakistan");
        } catch (_) {}
      }

      if (locations.isNotEmpty) {
        final loc = locations.first;
        _workerPosition = LatLng(loc.latitude, loc.longitude);
        _setupMarkers();
      }
    } catch (e) {
      debugPrint("Geocoding Failed: $e");
    }
  }

  // Markers Lagane ka Logic
  void _setupMarkers() {
    if (widget.showExactLocation) {
      // PUBLIC: Show Pin
      _markers.add(
        Marker(
          point: _workerPosition,
          width: 80,
          height: 80,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                ),
                child: const Text("Worker", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
              ),
              const Icon(Icons.location_on, color: Colors.red, size: 45),
            ],
          ),
        ),
      );
    } else {
      // PRIVATE: Show Circle
      _circles.add(
        CircleMarker(
          point: _workerPosition,
          color: lightSeaGreen.withOpacity(0.3),
          borderColor: lightSeaGreen,
          borderStrokeWidth: 2,
          useRadiusInMeter: true,
          radius: 1000,
        ),
      );
      _markers.add(
        Marker(
          point: _workerPosition,
          width: 40,
          height: 40,
          child: Icon(Icons.circle, color: lightSeaGreen.withOpacity(0.8), size: 15),
        ),
      );
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          Position position = await Geolocator.getCurrentPosition();
          _userPosition = LatLng(position.latitude, position.longitude);

          // User Marker (Blue Pin)
          _markers.add(
            Marker(
              point: _userPosition!,
              width: 60,
              height: 60,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                    child: const Text("You", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.my_location, color: Colors.blue, size: 30),
                ],
              ),
            ),
          );

          // Calculate Distance
          final Distance distance = const Distance();
          double meter = distance.as(LengthUnit.Meter, _userPosition!, _workerPosition);

          if (meter < 1000) {
            _distanceInfo = "${meter.toStringAsFixed(0)} meters away";
          } else {
            double km = meter / 1000;
            _distanceInfo = "${km.toStringAsFixed(1)} km away";
          }
        }
      }
    } catch (e) {
      debugPrint("GPS Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Map"),
        backgroundColor: lightSeaGreen,
        actions: [
          if (_userPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(_userPosition!, 14);
              },
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPosition ?? _workerPosition,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.serveease.app',
              ),
              CircleLayer(circles: _circles),
              MarkerLayer(markers: _markers),
            ],
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car, color: lightSeaGreen),
                  const SizedBox(width: 10),
                  Text(
                    _distanceInfo == "Calculating..." ? "Locating..." : _distanceInfo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}