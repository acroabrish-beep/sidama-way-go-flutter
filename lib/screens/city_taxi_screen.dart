import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as custom_auth;
import '../models/user_model.dart';
import '../services/taxi_service.dart';
import 'mobility/driver_registration_screen.dart';
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
  String? _selectedStationId;
  String _selectedStationName = 'Piassa';
  final LatLng _userLocation = const LatLng(7.0504, 38.4955); // Default Hawassa center

  final List<Map<String, dynamic>> _popularDestinations = [
    {'name': 'Menaharia', 'fare': 8, 'duration': '10 min', 'icon': Icons.business},
    {'name': 'Haik Dar', 'fare': 6, 'duration': '8 min', 'icon': Icons.waves},
    {'name': 'Tabor', 'fare': 7, 'duration': '12 min', 'icon': Icons.terrain},
    {'name': 'Hawella Tula', 'fare': 10, 'duration': '15 min', 'icon': Icons.location_city},
    {'name': 'Addis Ketema', 'fare': 8, 'duration': '11 min', 'icon': Icons.store},
    {'name': 'Gudumale', 'fare': 9, 'duration': '13 min', 'icon': Icons.festival},
    {'name': 'Misrak', 'fare': 7, 'duration': '10 min', 'icon': Icons.explore},
    {'name': 'Alamura', 'fare': 12, 'duration': '18 min', 'icon': Icons.landscape},
  ];

  @override
  void initState() {
    super.initState();
    _initTaxi();
  }

  void _initTaxi() async {
    await _taxiService.seedStations();
    await _taxiService.fixMissingStationIds();
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
          .where('status', isEqualTo: 'APPROVED')
          .snapshots(),
      builder: (context, snapshot) {
        List<Marker> markers = [];

        // Add User Marker
        markers.add(
          Marker(point: _userLocation, child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40)),
        );

        if (snapshot.hasData) {
          // Filter isOnline in Dart
          final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map)['isOnline'] == true).toList();
          for (var doc in docs) {
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
            const Text('Popular Destinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPopularDestinationsGrid(),
            const SizedBox(height: 24),
            const Text('Taxi Stations nearby', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildStationsList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {}, // Handled by destinations
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('SELECT A DESTINATION ABOVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularDestinationsGrid() {
    return SizedBox(
      height: 160,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.6,
        ),
        itemCount: _popularDestinations.length,
        itemBuilder: (context, index) {
          final dest = _popularDestinations[index];
          return InkWell(
            onTap: () => _showBookingBottomSheet(dest),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(dest['icon'], color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dest['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('${dest['fare']} ETB', style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
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

  Widget _buildStationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('taxi_stations').where('isActive', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final stations = snapshot.data!.docs;
        return SizedBox(
          height: 100, // Increased height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stations.length,
            itemBuilder: (context, i) {
              final s = stations[i].data() as Map<String, dynamic>;
              final stationName = s['name'] ?? 'Station';
              final stationId = stations[i].id;
              final isSelected = _selectedStationId == stationId;

              return InkWell(
                onTap: () => setState(() {
                  _selectedStationId = stationId;
                  _selectedStationName = stationName;
                }),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('queues').where('station', isEqualTo: stationName).snapshots(),
                  builder: (context, qSnap) {
                    final waitingTaxis = qSnap.data?.docs.where((doc) => doc.data() is Map && (doc.data() as Map)['status'] == 'waiting').toList() ?? [];
                    final activeCount = waitingTaxis.length;

                    return Container(
                      width: 150, // Increased width
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE65100).withOpacity(0.1) : Colors.white,
                        border: Border.all(color: isSelected ? const Color(0xFFE65100) : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              stationName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            )
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.local_taxi, size: 14, color: Colors.green),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '$activeCount waiting',
                                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showBookingBottomSheet(Map<String, dynamic> destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _BookingBottomSheet(
        destination: destination,
        taxiService: _taxiService,
        onBooked: (requestId) {
          setState(() => _activeRequestId = requestId);
        },
      ),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> destination;
  final TaxiService taxiService;
  final Function(String) onBooked;

  const _BookingBottomSheet({
    required this.destination,
    required this.taxiService,
    required this.onBooked,
  });

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  String? _selectedStation;
  bool _showingTaxis = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.destination['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('${widget.destination['fare']} ETB', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Est. duration: ${widget.destination['duration']}', style: const TextStyle(color: Colors.grey)),
          const Divider(height: 40),
          const Text('Select your pickup station:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('taxi_stations').where('isActive', isEqualTo: true).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final stations = snapshot.data!.docs;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: stations.map((doc) {
                    final name = doc['name'] as String;
                    final isSelected = _selectedStation == name;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(name),
                        selected: isSelected,
                        onSelected: (val) => setState(() {
                          _selectedStation = name;
                          _showingTaxis = false;
                        }),
                        selectedColor: Colors.orange.withOpacity(0.2),
                        labelStyle: TextStyle(color: isSelected ? Colors.orange : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          ),
          const SizedBox(height: 24),
          if (!_showingTaxis)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedStation == null ? null : () => setState(() => _showingTaxis = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SEE AVAILABLE TAXIS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else
            _buildTaxisList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTaxisList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('station', isEqualTo: _selectedStation)
          .orderBy('joinTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        final docs = snapshot.data!.docs.where((doc) => doc.data() is Map && (doc.data() as Map)['status'] == 'waiting').toList();

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('No taxis currently at $_selectedStation — check another station',
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(data['plateNumber'] ?? 'Unknown'),
                      trailing: ElevatedButton(
                        onPressed: () => _bookTaxi(data['plateNumber']),
                        child: const Text('Book'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _bookTaxi(String plateNumber) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final docRef = await FirebaseFirestore.instance.collection('taxi_requests').add({
        'pickup': _selectedStation,
        'destination': widget.destination['name'],
        'fare': widget.destination['fare'],
        'passengerId': user?.uid,
        'plateNumber': plateNumber,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        widget.onBooked(docRef.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Taxi booked! Your driver will meet you at $_selectedStation')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error booking: $e')));
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
        stream: FirebaseFirestore.instance.collection('taxi_requests').doc(requestId).snapshots(),
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
                    status == 'Pending' ? 'Waiting for Driver...' : 'Driver Confirmed!',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (data['plateNumber'] != null)
                    Text('Taxi: ${data['plateNumber']}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 48),
                  const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24),
                  const Spacer(),
                  Text('Trip to: ${data['destination']}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                         FirebaseFirestore.instance.collection('taxi_requests').doc(requestId).delete();
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
