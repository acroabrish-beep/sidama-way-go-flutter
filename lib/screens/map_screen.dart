import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng _userLocation = const LatLng(7.0504, 38.4955); // Default Hawassa
  bool _isLoading = true;

  final Set<String> _selectedFilters = {"Me", "Taxi", "Bus", "Hotel", "Pharmacy", "Hospital", "Eco-Shine"};

  // Mock Data
  final Map<String, List<Map<String, dynamic>>> _categoryMarkers = {
    "Taxi": [
      {"name": "Taxi 01", "point": LatLng(7.060, 38.505), "icon": Icons.local_taxi, "color": Colors.orange},
      {"name": "Taxi 02", "point": LatLng(7.040, 38.515), "icon": Icons.local_taxi, "color": Colors.orange},
      {"name": "Taxi 03", "point": LatLng(7.070, 38.485), "icon": Icons.local_taxi, "color": Colors.orange},
    ],
    "Bus": [
      {"name": "Blue Bus A", "point": LatLng(7.055, 38.500), "icon": Icons.directions_bus, "color": Colors.blue},
      {"name": "Blue Bus B", "point": LatLng(7.045, 38.490), "icon": Icons.directions_bus, "color": Colors.blue},
    ],
    "Hotel": [
      {"name": "Haile Resort", "point": LatLng(7.065, 38.510), "icon": Icons.hotel, "color": Colors.purple},
      {"name": "Lewi Hotel", "point": LatLng(7.035, 38.480), "icon": Icons.hotel, "color": Colors.purple},
    ],
    "Pharmacy": [
      {"name": "City Pharmacy", "point": LatLng(7.058, 38.487), "icon": Icons.local_pharmacy, "color": Colors.red},
      {"name": "Lake Pharmacy", "point": LatLng(7.042, 38.503), "icon": Icons.local_pharmacy, "color": Colors.red},
    ],
    "Hospital": [
      {"name": "Hawassa Referral", "point": LatLng(7.062, 38.483), "icon": Icons.local_hospital, "color": Colors.red},
    ],
    "Eco-Shine": [
      {"name": "Eco-Shine Piazza", "point": LatLng(7.052, 38.497), "icon": Icons.wb_sunny, "color": Colors.green},
      {"name": "Eco-Shine University", "point": LatLng(7.070, 38.490), "icon": Icons.eco, "color": Colors.green},
    ],
  };

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_userLocation, 14);
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _showMarkerInfo(String name) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.navigation),
                label: const Text("Navigate"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];

    if (_selectedFilters.contains("Me")) {
      markers.add(
        Marker(
          point: _userLocation,
          width: 40,
          height: 40,
          child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
        ),
      );
    }

    _categoryMarkers.forEach((category, list) {
      if (_selectedFilters.contains(category)) {
        for (var m in list) {
          markers.add(
            Marker(
              point: m['point'],
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showMarkerInfo(m['name']),
                child: Icon(m['icon'], color: m['color'], size: 30),
              ),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("City Map"),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sidama.sidama_way_go',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Category Filter Chips
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: _selectedFilters.union(_categoryMarkers.keys.toSet()).map((category) {
                  final isSelected = _selectedFilters.contains(category);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            _selectedFilters.add(category);
                          } else {
                            _selectedFilters.remove(category);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF2E7D32).withOpacity(0.3),
                      checkmarkColor: const Color(0xFF2E7D32),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),

          // Coordinates at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Lat: ${_userLocation.latitude.toStringAsFixed(4)}, Lng: ${_userLocation.longitude.toStringAsFixed(4)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
