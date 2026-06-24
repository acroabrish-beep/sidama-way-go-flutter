import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/glass_card.dart';
import '../utils/language_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'crud_list_screen.dart';

class SmartCityMapScreen extends StatefulWidget {
  const SmartCityMapScreen({super.key});

  @override
  State<SmartCityMapScreen> createState() => _SmartCityMapScreenState();
}

class _SmartCityMapScreenState extends State<SmartCityMapScreen> {
  final MapController _mapController = MapController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final LatLng _hawassaCenter = const LatLng(7.0622, 38.4763);
  LatLng? _currentLocation;

  bool _isListening = false;
  String _searchQuery = "";
  String _aiResponse = "";

  // GIS Layer visibility
  final Map<String, bool> _layers = {
    'Terminals': true,
    'Taxis': true,
    'Hotels': true,
    'Tourism': true,
    'Hospitals': true,
    'Pharmacies': true,
    'Emergency': true,
    'Government': true,
    'Eco-Shine': true,
    'Analytics': false,
  };

  final Map<String, List<Marker>> _markerData = {
    'Terminals': [],
    'Taxis': [],
    'Hotels': [],
    'Tourism': [],
    'Hospitals': [],
    'Pharmacies': [],
    'Emergency': [],
    'Government': [],
    'Eco-Shine': [],
    'Analytics': [],
  };

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _initGISStreams();
    _startLocationUpdatesIfDriver();
  }

  void _startLocationUpdatesIfDriver() {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user != null && (user.role == UserRole.taxi_admin || user.role.name.contains('driver'))) {
      // Periodic update every 10 seconds for testing
      Timer.periodic(const Duration(seconds: 10), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final pos = await Geolocator.getCurrentPosition();
        await FirebaseFirestore.instance.collection('taxi_drivers').doc(user.uid).set({
          'fullName': user.fullName,
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'status': 'available', // Or get from actual driver state
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    }
  }

  Future<void> _triggerSOS() async {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    final pos = await Geolocator.getCurrentPosition();

    await FirebaseFirestore.instance.collection('sos_requests').add({
      'userId': user?.uid ?? 'anonymous',
      'userName': user?.fullName ?? 'Anonymous',
      'latitude': pos.latitude,
      'longitude': pos.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'type': 'Map SOS',
      'location_name': 'GPS Trigger',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOS Alert Sent to Emergency Hub!'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation!, 14.0);
    }
  }

  void _initGISStreams() {
    // 1. Terminals
    _subscribe('terminal_routes', Icons.directions_bus, Colors.blue, 'Terminals');

    // 2. Taxi Stations & Drivers (Live)
    _subscribe('taxi_stations', Icons.local_taxi, Colors.orange, 'Taxis');
    _subscribe('taxi_drivers', Icons.directions_car, Colors.orangeAccent, 'Taxis', statusField: 'status');

    // 3. Hotels
    _subscribe('hotels', Icons.hotel, Colors.purple, 'Hotels');

    // 4. Tourism
    _subscribe('tourism_sites', Icons.landscape, Colors.teal, 'Tourism');

    // 5. Healthcare
    _subscribe('hospitals', Icons.local_hospital, Colors.red, 'Hospitals');
    _subscribe('pharmacies', Icons.local_pharmacy, Colors.green, 'Pharmacies');

    // 6. Emergency Centers & SOS
    _subscribe('emergency_centers', Icons.emergency, Colors.redAccent, 'Emergency');
    _subscribe('sos_requests', Icons.warning, Colors.redAccent, 'Emergency', activeOnly: true);

    // 7. Government
    _subscribe('government_offices', Icons.account_balance, Colors.indigo, 'Government');

    // 8. Eco-Shine
    _subscribe('eco_shine_providers', Icons.wb_sunny, Colors.amber, 'Eco-Shine');

    // 9. Analytics (Heatmap style)
    _subscribe('taxi_requests', Icons.density_medium, Colors.yellow.withOpacity(0.5), 'Analytics', isAnalytics: true);
  }

  void _subscribe(String collection, IconData icon, Color color, String layer, {String? statusField, bool activeOnly = false, bool isAnalytics = false}) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (activeOnly) {
      query = query.where('status', isNotEqualTo: 'resolved');
    }

    final sub = query.snapshots().listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _markerData[layer] = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          double lat = (data['latitude'] ?? data['lat'] ?? 7.0622).toDouble();
          double lng = (data['longitude'] ?? data['lng'] ?? 38.4763).toDouble();

          if (isAnalytics) {
             return Marker(
               point: LatLng(lat, lng),
               width: 80, height: 80,
               child: Container(
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   color: color.withOpacity(0.3),
                 ),
               ),
             );
          }

          Color mColor = color;
          if (statusField != null) {
            String s = (data[statusField] ?? '').toString().toLowerCase();
            if (s == 'busy') {
              mColor = Colors.red;
            } else if (s == 'offline') mColor = Colors.grey;
            else if (s == 'available') mColor = Colors.green;
          }

          return Marker(
            point: LatLng(lat, lng),
            width: 50, height: 50,
            child: GestureDetector(
              onTap: () => _showLocationInfo(data, layer, mColor),
              child: _buildGisMarker(icon, mColor, layer == 'Emergency'),
            ),
          );
        }).toList();
      });
    });
    _subscriptions.add(sub);
  }

  Widget _buildGisMarker(IconData icon, Color color, bool isSOS) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isSOS) _SOSRipple(color: color),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: color, size: 24),
        ),
      ],
    );
  }

  void _showLocationInfo(Map<String, dynamic> data, String layer, Color themeColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GISInfoSheet(data: data, layer: layer, themeColor: themeColor),
    );
  }

  void _startAIVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() => _searchQuery = val.recognizedWords);
          if (val.finalResult) _processAICommand(val.recognizedWords);
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processAICommand(String cmd) {
    setState(() => _isListening = false);
    final q = cmd.toLowerCase();
    String response = "";

    if (q.contains("hospital") || q.contains("ሆስፒታል")) {
      _filterToLayer('Hospitals');
      response = "Highlighting nearest hospitals in Hawassa.";
    } else if (q.contains("taxi") || q.contains("ታክሲ")) {
      _filterToLayer('Taxis');
      response = "Showing active taxi fleet and stations.";
    } else if (q.contains("emergency") || q.contains("emergency") || q.contains("ድንገተኛ")) {
      _filterToLayer('Emergency');
      response = "Locating emergency centers and active SOS requests.";
    } else if (q.contains("tourism") || q.contains("ቱሪስት")) {
      _filterToLayer('Tourism');
      response = "Showing top tourism attractions near you.";
    } else {
      response = "Showing all Smart City layers.";
      _layers.updateAll((k, v) => true);
    }

    setState(() => _aiResponse = response);
    _flutterTts.speak(response);
  }

  void _filterToLayer(String key) {
    setState(() {
      _layers.updateAll((k, v) => k == key);
    });
  }

  List<Marker> _getVisibleMarkers() {
    List<Marker> list = [];
    _layers.forEach((k, v) { if (v) list.addAll(_markerData[k] ?? []); });
    if (_currentLocation != null) {
      list.add(Marker(
        point: _currentLocation!,
        width: 60, height: 60,
        child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 45),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final user = Provider.of<AuthProvider>(context).userModel;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _hawassaCenter, initialZoom: 14.0),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _getVisibleMarkers()),
            ],
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGisHeader(lang),
                  const SizedBox(height: 12),
                  _buildLayerSelector(),
                  if (_aiResponse.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GlassCard(padding: const EdgeInsets.all(12), child: Text(_aiResponse, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                ],
              ),
            ),
          ),

          Positioned(bottom: 24, right: 16, child: _buildGisControls(user)),
          if (_isListening) _buildVoiceOverlay(),
        ],
      ),
    );
  }

  Widget _buildGisHeader(LanguageProvider lang) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(hintText: lang.t('search_city'), hintStyle: const TextStyle(color: Colors.white54), border: InputBorder.none),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          IconButton(icon: Icon(_isListening ? Icons.graphic_eq : Icons.mic, color: _isListening ? Colors.redAccent : Colors.white), onPressed: _startAIVoice),
        ],
      ),
    );
  }

  Widget _buildLayerSelector() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _layers.keys.map((l) {
          bool active = _layers[l]!;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _layers[l] = !active),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: active ? Colors.green.withOpacity(0.7) : null,
                child: Center(child: Text(l, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGisControls(UserModel? user) {
    return Column(
      children: [
        if (user?.role == UserRole.super_admin)
          FloatingActionButton.small(
            heroTag: 'add_loc',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CRUDListScreen(collection: 'locations', title: 'Add Location', fields: ['name', 'latitude', 'longitude', 'category', 'phone', 'address']))),
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add_location, color: Colors.white),
          ),
        const SizedBox(height: 12),
        FloatingActionButton.small(heroTag: 'gps_btn', onPressed: _determinePosition, backgroundColor: Colors.white, child: const Icon(Icons.my_location, color: Colors.blue)),
        const SizedBox(height: 12),
        FloatingActionButton(heroTag: 'sos_map_btn', onPressed: _triggerSOS, backgroundColor: Colors.red, child: const Icon(Icons.sos, color: Colors.white, size: 32)),
      ],
    );
  }

  Widget _buildVoiceOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mic, color: Colors.white, size: 80),
            const SizedBox(height: 24),
            Text(_searchQuery.isEmpty ? "Listening..." : _searchQuery, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _GISInfoSheet extends StatelessWidget {
  final Map<String, dynamic> data;
  final String layer;
  final Color themeColor;

  const _GISInfoSheet({required this.data, required this.layer, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'] ?? data['type'] ?? 'City Service', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(layer.toUpperCase(), style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              if (data['imageUrl'] != null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(data['imageUrl'], width: 80, height: 80, fit: BoxFit.cover)),
            ],
          ),
          const SizedBox(height: 20),
          _gisRow(Icons.location_on, data['address'] ?? data['location'] ?? 'Hawassa, Sidama'),
          if (data['phone'] != null) _gisRow(Icons.phone, data['phone']),
          if (data['openingHours'] != null) _gisRow(Icons.access_time, data['openingHours']),
          if (data['description'] != null) ...[const SizedBox(height: 12), Text(data['description'], style: const TextStyle(color: Colors.white70, fontSize: 14))],
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => _nav(data['latitude'] ?? data['lat'], data['longitude'] ?? data['lng']), icon: const Icon(Icons.navigation), label: const Text('DIRECTIONS'), style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.white))),
              const SizedBox(width: 12),
              if (data['phone'] != null) Expanded(child: OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse('tel:${data['phone']}')), icon: const Icon(Icons.call), label: const Text('CALL'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)))),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _gisRow(IconData icon, String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(icon, color: Colors.white54, size: 18), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: Colors.white)))]));
  void _nav(dynamic lat, dynamic lng) async { final url = 'google.navigation:q=$lat,$lng'; if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url)); }
}

class _SOSRipple extends StatefulWidget {
  final Color color;
  const _SOSRipple({required this.color});
  @override
  State<_SOSRipple> createState() => _SOSRippleState();
}

class _SOSRippleState extends State<_SOSRipple> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return FadeTransition(opacity: Tween(begin: 1.0, end: 0.0).animate(_c), child: ScaleTransition(scale: Tween(begin: 1.0, end: 4.0).animate(_c), child: Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withOpacity(0.4))))); }
}
