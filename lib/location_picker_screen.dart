import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // OpenStreetMap
import 'package:latlong2/latlong.dart';      // Coordinates

class LocationPickerScreen extends StatefulWidget {
  // Naya variable taake hum piche se location bhej sakein
  final LatLng? startLocation;

  const LocationPickerScreen({super.key, this.startLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _pickedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Logic: Agar piche se address mila hai to wo use karo, warna Default Lahore
    _pickedLocation = widget.startLocation ?? const LatLng(31.5204, 74.3587);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adjust Pin Location"),
        backgroundColor: const Color(0xFF20B2AA), // lightSeaGreen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation, // Ab ye dynamic hoga
              initialZoom: 15.0, // Thora zoom-in rakha hai taake gali nazar aye
              onPositionChanged: (position, hasGesture) {
                if (position.center != null) {
                  _pickedLocation = position.center!;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.serveease.app',
              ),
            ],
          ),

          // --- CENTER PIN ---
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, color: Colors.red, size: 50),
            ),
          ),

          // --- CONFIRM BUTTON ---
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pop(context, _pickedLocation);
              },
              child: const Text(
                "Confirm Exact Spot",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}