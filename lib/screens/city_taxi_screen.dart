import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart' as custom_auth;
import '../models/taxi_models.dart';
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
  final TextEditingController _searchController = TextEditingController();

  String? _activeRequestId;
  LatLng _userLocation = const LatLng(7.0504, 38.4955);
  String _searchQuery = '';
  String? _selectedStation;
  final ScrollController _scrollController = ScrollController();

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
    _forceSeedStations();
    _initTaxi();
  }

  Future<void> _forceSeedStations() async {
    try {
      final col = FirebaseFirestore.instance.collection('taxi_stations');
      final existing = await col.limit(1).get();
      if (existing.docs.isEmpty) {
        // Seed all 11 stations
        final batch = FirebaseFirestore.instance.batch();
        final stations = [
          {'name': 'Piassa', 'description': 'Piassa main roundabout', 'zone': 'Zone 1', 'maxCapacity': 20, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Menaharia', 'description': 'Menaharia market area', 'zone': 'Zone 2', 'maxCapacity': 15, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Tabor', 'description': 'Near Tabor Mountain', 'zone': 'Zone 3', 'maxCapacity': 10, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Gudumale', 'description': 'Gudumale area', 'zone': 'Zone 2', 'maxCapacity': 12, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Addis Ketema', 'description': 'Addis Ketema neighborhood', 'zone': 'Zone 3', 'maxCapacity': 10, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Haik Dar', 'description': 'Haik Dar area', 'zone': 'Zone 2', 'maxCapacity': 8, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Hawella Tula', 'description': 'Hawella Tula area', 'zone': 'Zone 4', 'maxCapacity': 10, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Misrak', 'description': 'Misrak area', 'zone': 'Zone 3', 'maxCapacity': 8, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Alamura', 'description': 'Alamura area', 'zone': 'Zone 4', 'maxCapacity': 8, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Hiteta', 'description': 'Hiteta area', 'zone': 'Zone 4', 'maxCapacity': 6, 'isActive': true, 'currentTaxis': 0},
          {'name': 'Dato', 'description': 'Dato area', 'zone': 'Zone 4', 'maxCapacity': 6, 'isActive': true, 'currentTaxis': 0},
        ];
        for (final s in stations) {
          batch.set(col.doc(), {...s, 'createdAt': FieldValue.serverTimestamp(), 'location': const GeoPoint(7.0504, 38.4955), 'activeTaxiCount': 0, 'waitingPassengers': 0, 'status': 'Active'});
        }
        await batch.commit();
        debugPrint('Stations seeded successfully');
      }
    } catch (e) {
      debugPrint('Seed error: $e');
    }
  }

  void _initTaxi() async {
    await _taxiService.seedStations();
    await _taxiService.fixMissingStationIds();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_userLocation, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<custom_auth.AuthProvider>(context);
    final user = authProvider.userModel;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Smart Taxi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          _buildTopSearch(),
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

  Widget _buildTopSearch() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(30),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Where are you going?',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFE65100)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('drivers')
          .where('status', isEqualTo: 'APPROVED')
          .snapshots(),
      builder: (context, snapshot) {
        List<Marker> markers = [];
        markers.add(Marker(point: _userLocation, child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40)));

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map)['isOnline'] == true).toList();
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final loc = data['location'] as GeoPoint?;
            if (loc != null) {
              markers.add(Marker(
                point: LatLng(loc.latitude, loc.longitude),
                child: Transform.rotate(
                  angle: (data['heading'] ?? 0.0) * (3.14159 / 180),
                  child: const Icon(Icons.local_taxi, color: Color(0xFFE65100), size: 30),
                ),
              ));
            }
          }
        }
        return MarkerLayer(markers: markers);
      },
    );
  }

  Widget _buildOverlayUI() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Popular Destinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 12),
              _buildPopularDestinationsGrid(),
              const SizedBox(height: 24),
              const Text('Taxi Stations nearby', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              _buildStationsList(),
              if (_selectedStation != null) ...[
                const SizedBox(height: 24),
                Text('Available Taxis at $_selectedStation', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                const SizedBox(height: 12),
                _buildAvailableTaxisAtStation(_selectedStation!),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableTaxisAtStation(String stationName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('station', isEqualTo: stationName)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final taxis = snapshot.data!.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'waiting';
            })
            .toList();

        // Sort by joinTime in Dart
        taxis.sort((a, b) {
          final aTime = (a.data() as Map)['joinTime'];
          final bTime = (b.data() as Map)['joinTime'];
          if (aTime == null || bTime == null) return 0;
          return (aTime as Timestamp).compareTo(bTime as Timestamp);
        });

        if (taxis.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('No taxis currently waiting at this station.', style: TextStyle(color: Colors.grey))),
          );
        }

        return Column(
          children: taxis.asMap().entries.map((entry) {
            final data = entry.value.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(data['plateNumber'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['driverName'] ?? 'Driver'),
                trailing: ElevatedButton(
                  onPressed: () {
                    FirebaseFirestore.instance.collection('taxi_requests').add({
                      'plateNumber': data['plateNumber'],
                      'driverName': data['driverName'],
                      'pickup': stationName,
                      'passengerId': FirebaseAuth.instance.currentUser?.uid ?? '',
                      'status': 'pending',
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                    entry.value.reference.update({'status': 'in_progress'});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Taxi booked! ${data['plateNumber']} is coming to $stationName'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: const Text('Book'),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPopularDestinationsGrid() {
    final filtered = _popularDestinations.where((d) => d['name'].toLowerCase().contains(_searchQuery)).toList();
    return SizedBox(
      height: 220,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final dest = filtered[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: InkWell(
              onTap: () => _showBookingBottomSheet(dest),
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_taxi, color: Colors.orange, size: 20),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        dest['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${dest['fare']} ETB',
                      style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('taxi_stations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final docs = snapshot.data!.docs;

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final stationName = data['name'] ?? 'Unknown';
              final isSelected = _selectedStation == stationName;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedStation = stationName);
                  _scrollController.animateTo(
                    300,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.orange.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isSelected ? Colors.orange : Colors.grey[200]!),
                    boxShadow: [
                      if (isSelected) BoxShadow(color: Colors.orange.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: Text(stationName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.orange.shade900 : Colors.black87), overflow: TextOverflow.ellipsis)),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('queues')
                            .where('station', isEqualTo: stationName)
                            .snapshots(),
                        builder: (context, qSnap) {
                          final waitingCount = qSnap.data?.docs.where((d) => (d.data() as Map)['status'] == 'waiting').length ?? 0;
                          return Row(
                            children: [
                              Icon(Icons.local_taxi, size: 12, color: waitingCount > 0 ? Colors.green : Colors.grey),
                              const SizedBox(width: 4),
                              Text('$waitingCount waiting', style: TextStyle(fontSize: 11, color: waitingCount > 0 ? Colors.green : Colors.black54, fontWeight: waitingCount > 0 ? FontWeight.bold : FontWeight.normal)),
                            ],
                          );
                        }
                      ),
                    ],
                  ),
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

  final List<String> _defaultStations = [
    'Piassa',
    'Menaharia',
    'Tabor',
    'Gudumale',
    'Addis Ketema',
    'Haik Dar',
    'Hawella Tula',
    'Misrak',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.destination['name'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${widget.destination['fare']} ETB', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Est. duration: ${widget.destination['duration']}', style: const TextStyle(color: Colors.grey)),
          const Divider(height: 40),
          const Text('Select your pickup station:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _defaultStations.map((station) => ChoiceChip(
              label: Text(station),
              selected: _selectedStation == station,
              selectedColor: Colors.orange,
              onSelected: (selected) {
                setState(() {
                  _selectedStation = selected ? station : null;
                  _showingTaxis = false;
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 32),
          if (!_showingTaxis)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedStation == null ? null : () => setState(() => _showingTaxis = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('SEE AVAILABLE TAXIS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else
            _buildTaxisList(),
        ],
      ),
    );
  }

  Widget _buildTaxisList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('station', isEqualTo: _selectedStation)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'waiting';
        }).toList();

        // Sort by joinTime in Dart
        docs.sort((a, b) {
          final timeA = (a.data() as Map)['joinTime'] as Timestamp?;
          final timeB = (b.data() as Map)['joinTime'] as Timestamp?;
          if (timeA == null || timeB == null) return 0;
          return timeA.compareTo(timeB);
        });

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
            const Text('Available Taxis:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: const Icon(Icons.local_taxi, color: Colors.orange)),
                      title: Text(data['plateNumber'] ?? 'Unknown'),
                      subtitle: const Text('Verified Driver'),
                      trailing: ElevatedButton(
                        onPressed: () => _bookTaxi(data['plateNumber']),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
      final requestId = await widget.taxiService.createRideRequest(RideRequest(
        id: '',
        userId: user?.uid ?? '',
        userName: user?.displayName ?? 'Passenger',
        pickup: _selectedStation ?? '',
        pickupLocation: const GeoPoint(0,0), // This should ideally come from station location
        destination: widget.destination['name'],
        destinationLocation: const GeoPoint(0,0),
        fare: (widget.destination['fare'] as num).toDouble(),
        status: 'Pending',
        plateNumber: plateNumber,
        timestamp: DateTime.now(),
      ));

      if (mounted) {
        Navigator.pop(context);
        widget.onBooked(requestId);
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
    final TaxiService taxiService = TaxiService();
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: StreamBuilder<RideRequest?>(
        stream: taxiService.watchRide(requestId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
          final ride = snapshot.data;
          if (ride == null) return const Center(child: Text('Ride not found', style: TextStyle(color: Colors.white)));

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_taxi, color: Colors.white, size: 100),
                  const SizedBox(height: 48),
                  Text(
                    ride.status == 'Pending' ? 'Dispatching your Driver...' : 'Taxi Dispatched!',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (ride.driverName != null)
                    Text('Driver: ${ride.driverName}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 48),
                  const LinearProgressIndicator(color: Colors.orangeAccent, backgroundColor: Colors.white24),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                         taxiService.cancelRide(requestId);
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

