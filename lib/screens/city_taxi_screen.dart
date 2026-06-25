import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as custom_auth;
import '../models/taxi_models.dart';
import '../models/user_model.dart';
import '../services/taxi_service.dart';
import 'taxi/driver_registration_screen.dart';
import 'taxi/driver_dashboard_screen.dart';
import 'taxi_admin_dashboard.dart';

class CityTaxiScreen extends StatefulWidget {
  const CityTaxiScreen({super.key});

  @override
  State<CityTaxiScreen> createState() => _CityTaxiScreenState();
}

class _CityTaxiScreenState extends State<CityTaxiScreen> {
  final MapController _mapController = MapController();
  final _taxiService = TaxiService();

  String? _activeRequestId;
  LatLng _userLocation = const LatLng(7.0504, 38.4955); // Default Hawassa center

  @override
  void initState() {
    super.initState();
    _taxiService.seedStations();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context);
    final user = authProvider.userModel;

    // Route based on role
    if (user?.role == UserRole.super_admin || user?.role == UserRole.taxi_admin) {
      return const TaxiAdminDashboard();
    } else if (user?.role == UserRole.taxi_driver) {
      return const TaxiDriverDashboard();
    }

    if (_activeRequestId != null) {
      return _ActiveRequestScreen(
        requestId: _activeRequestId!,
        onClose: () => setState(() => _activeRequestId = null),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawassa Smart Taxi'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverRegistrationScreen())),
            icon: const Icon(Icons.drive_eta, color: Colors.white, size: 18),
            label: const Text('BECOME A DRIVER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildOverlayUI(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation,
        initialZoom: 14.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sidamawaygo.app',
        ),
        _buildMarkersStream(),
      ],
    );
  }

  Widget _buildMarkersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('drivers')
          .where('status', isEqualTo: 'approved')
          .where('isOnline', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<Marker> markers = [];

        // Add User Marker
        markers.add(
          Marker(point: _userLocation, child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40)),
        );

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final loc = data['location'] as GeoPoint?;
            if (loc != null) {
              markers.add(
                Marker(
                  point: LatLng(loc.latitude, loc.longitude),
                  child: const Icon(Icons.local_taxi, color: Color(0xFFE65100), size: 30),
                ),
              );
            }
          }
        }

        return MarkerLayer(markers: markers);
      },
    );
  }

  Widget _buildOverlayUI() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Where to?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildLocationInput(Icons.my_location, 'Current Location (Piassa)'),
            const SizedBox(height: 12),
            _buildLocationInput(Icons.location_on, 'Enter Destination', isDestination: true),
            const SizedBox(height: 24),
            const Text('Taxi Stations nearby', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildStationsList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _requestRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('REQUEST SMART TAXI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInput(IconData icon, String hint, {bool isDestination = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: isDestination ? Colors.red : Colors.blue, size: 20),
          const SizedBox(width: 12),
          Text(hint, style: TextStyle(color: isDestination ? Colors.black87 : Colors.grey[600], fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildStationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('taxi_stations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final stations = snapshot.data!.docs;
        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stations.length,
            itemBuilder: (context, i) {
              final s = stations[i].data() as Map<String, dynamic>;
              final stationName = s['name'] ?? 'Station';
              return StreamBuilder<int>(
                stream: _taxiService.getActiveDriverCount(stationName),
                builder: (context, countSnap) {
                  final activeCount = countSnap.data ?? 0;
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.local_taxi, size: 14, color: Colors.green),
                            const SizedBox(width: 6),
                            Text('$activeCount Active', style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              );
            },
          ),
        );
      },
    );
  }

  void _requestRide() async {
    final user = Provider.of<custom_auth.AuthProvider>(context, listen: false).userModel;
    if (user == null) return;

    try {
      final requestId = await _taxiService.requestSmartTaxi(RideRequest(
        id: '',
        userId: user.uid,
        userName: user.fullName,
        pickup: 'Piassa',
        pickupLocation: const GeoPoint(7.0504, 38.4955),
        destination: 'Menaharia',
        destinationLocation: const GeoPoint(7.0621, 38.4772),
        fare: 50.0,
        status: 'Pending',
        timestamp: DateTime.now(),
      ));

      setState(() {
        _activeRequestId = requestId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }
}

class _ActiveRequestScreen extends StatelessWidget {
  final String requestId;
  final VoidCallback onClose;
  const _ActiveRequestScreen({required this.requestId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE65100),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('ride_requests').doc(requestId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final status = data['status'] ?? 'Pending';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_taxi, color: Colors.white, size: 100),
                  const SizedBox(height: 48),
                  Text(
                    status == 'Pending' ? 'Finding your Driver...' : 'Driver Found!',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (data['driverName'] != null)
                    Text('Driver: ${data['driverName']}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 48),
                  const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24),
                  const Spacer(),
                  Text('Trip to: ${data['destination']}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                         FirebaseFirestore.instance.collection('ride_requests').doc(requestId).delete();
                         onClose();
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white70), foregroundColor: Colors.white),
                      child: const Text('CANCEL REQUEST'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
