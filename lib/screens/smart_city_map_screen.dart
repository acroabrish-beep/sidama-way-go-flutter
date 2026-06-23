import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/glass_card.dart';

class SmartCityMapScreen extends StatefulWidget {
  const SmartCityMapScreen({super.key});

  @override
  State<SmartCityMapScreen> createState() => _SmartCityMapScreenState();
}

class _SmartCityMapScreenState extends State<SmartCityMapScreen> {
  final MapController _mapController = MapController();
  String _selectedFilter = 'All';

  final Map<String, List<Marker>> _markers = {
    'Terminals': [],
    'Taxis': [],
    'Hospitals': [],
    'Pharmacies': [],
    'Hotels': [],
    'Tourism': [],
    'Emergency': [],
  };

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    _loadFromCollection('stations', Icons.local_taxi, Colors.orange, 'Taxis');
    _loadFromCollection('routes', Icons.directions_bus, Colors.blue, 'Terminals');
    _loadFromCollection('hospitals', Icons.local_hospital, Colors.red, 'Hospitals');
    _loadFromCollection('pharmacies', Icons.local_pharmacy, Colors.green, 'Pharmacies');
    _loadFromCollection('hotels', Icons.hotel, Colors.purple, 'Hotels');
    _loadFromCollection('tourism_sites', Icons.landscape, Colors.teal, 'Tourism');
    _loadFromCollection('sos_requests', Icons.warning, Colors.red, 'Emergency');
  }

  void _loadFromCollection(String collection, IconData icon, Color color, String category) {
    FirebaseFirestore.instance.collection(collection).snapshots().listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _markers[category] = snapshot.docs.map((doc) {
          final data = doc.data();
          // Assuming documents have 'lat' and 'lng' fields. Fallback to Hawassa center if missing.
          double lat = (data['lat'] ?? 7.0622).toDouble();
          double lng = (data['lng'] ?? 38.4763).toDouble();

          return Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showDetails(data, category),
              child: Icon(icon, color: color, size: 30),
            ),
          );
        }).toList();
      });
    });
  }

  void _showDetails(Map<String, dynamic> data, String category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name'] ?? data['type'] ?? 'Smart City Service',
                 style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(category, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(data['location'] ?? data['location_name'] ?? 'Hawassa, Sidama',
                 style: const TextStyle(color: Colors.white70)),
            if (data['description'] != null) ...[
              const SizedBox(height: 8),
              Text(data['description'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.navigation), label: const Text('Navigate')),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.call), label: const Text('Contact')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _getVisibleMarkers() {
    if (_selectedFilter == 'All') {
      return _markers.values.expand((element) => element).toList();
    }
    return _markers[_selectedFilter] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(7.0622, 38.4763), // Hawassa Center
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sidama.sidama_way_go',
              ),
              MarkerLayer(markers: _getVisibleMarkers()),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildFilterBar(),
                  const Spacer(),
                  _buildMapControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Smart City Hawassa...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Terminals', 'Taxis', 'Hospitals', 'Pharmacies', 'Hotels', 'Tourism', 'Emergency'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final f = filters[i];
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: isSelected ? Colors.green : null,
                child: Center(
                  child: Text(
                    f,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          children: [
            FloatingActionButton.small(
              heroTag: 'zoom_in',
              onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(Icons.add, color: Colors.black),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'zoom_out',
              onPressed: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
              backgroundColor: Colors.white.withOpacity(0.8),
              child: const Icon(Icons.remove, color: Colors.black),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'my_location',
              onPressed: () {},
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
