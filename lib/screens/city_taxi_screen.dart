import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as custom_auth;

class CityTaxiScreen extends StatefulWidget {
  const CityTaxiScreen({super.key});

  @override
  State<CityTaxiScreen> createState() => _CityTaxiScreenState();
}

class _CityTaxiScreenState extends State<CityTaxiScreen> {
  String? _activeRequestId;

  Future<void> _seedTaxiRoutes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('taxi_routes').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final List<Map<String, dynamic>> initialRoutes = [
          {'from': 'Piassa', 'to': 'Menaharia', 'fare': 8, 'duration': '10 min'},
          {'from': 'Piassa', 'to': 'Haik Dar', 'fare': 6, 'duration': '8 min'},
          {'from': 'Piassa', 'to': 'Tabor', 'fare': 7, 'duration': '12 min'},
          {'from': 'Piassa', 'to': 'Hawella Tula', 'fare': 10, 'duration': '15 min'},
          {'from': 'Piassa', 'to': 'Addis Ketema', 'fare': 8, 'duration': '11 min'},
          {'from': 'Piassa', 'to': 'Gudumale', 'fare': 9, 'duration': '13 min'},
          {'from': 'Piassa', 'to': 'Misrak', 'fare': 7, 'duration': '10 min'},
          {'from': 'Piassa', 'to': 'Alamura', 'fare': 12, 'duration': '18 min'},
        ];
        final batch = FirebaseFirestore.instance.batch();
        for (var route in initialRoutes) {
          final docRef = FirebaseFirestore.instance.collection('taxi_routes').doc();
          batch.set(docRef, route);
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error seeding taxi routes: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _seedTaxiRoutes();
  }

  void _showBookingSheet(Map<String, dynamic> area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _BookingBottomSheet(
          area: area,
          onRequested: (id) {
            setState(() {
              _activeRequestId = id;
            });
          },
        );
      },
    );
  }

  Widget _buildAreaGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('taxi_routes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final routes = snapshot.data?.docs ?? [];
        if (routes.isEmpty) return const Center(child: Text('No taxi routes available.'));

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final r = routes[index].data() as Map<String, dynamic>;
            final name = r['to'] ?? 'Unnamed';
            final fare = r['fare'] ?? 10;
            final duration = r['duration'] ?? 'N/A';

            return Card(
              elevation: 2,
              child: InkWell(
                onTap: () => _showBookingSheet({'name': name, 'fare': fare, 'duration': duration}),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_taxi, color: Color(0xFFE65100)),
                      const SizedBox(height: 8),
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      Text('$fare ETB • $duration', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_activeRequestId != null) {
      return _ActiveRequestScreen(
        requestId: _activeRequestId!,
        onClose: () => setState(() => _activeRequestId = null),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hawassa City Taxi'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE65100),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Where are you going?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Select a destination from Piassa base', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Popular Destinations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _buildAreaGrid(),
          ),
        ],
      ),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> area;
  final Function(String) onRequested;
  const _BookingBottomSheet({required this.area, required this.onRequested});

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  String _paymentMethod = 'Cash';
  final int _availableTaxis = Random().nextInt(7) + 2;

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
              Text(widget.area['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('${widget.area['fare']} ETB', style: const TextStyle(fontSize: 22, color: Color(0xFFE65100), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Estimated time: 10-15 mins', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.local_taxi, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text('$_availableTaxis Available Taxis nearby', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _payChip('Telebirr'),
              const SizedBox(width: 8),
              _payChip('CBE Birr'),
              const SizedBox(width: 8),
              _payChip('Cash'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _bookTaxi,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE65100),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('BOOK TAXI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payChip(String method) {
    final isSelected = _paymentMethod == method;
    return ChoiceChip(
      label: Text(method),
      selected: isSelected,
      onSelected: (s) => setState(() => _paymentMethod = method),
      selectedColor: const Color(0xFFE65100).withOpacity(0.2),
      labelStyle: TextStyle(color: isSelected ? const Color(0xFFE65100) : Colors.black),
    );
  }

  Future<void> _bookTaxi() async {
    try {
      final user = Provider.of<custom_auth.AuthProvider>(context, listen: false).userModel;
      final docRef = await FirebaseFirestore.instance.collection('taxi_requests').add({
        'pickup': 'Piassa', // Default base for now
        'destination': widget.area['name'],
        'fare': widget.area['fare'],
        'duration': widget.area['duration'],
        'paymentMethod': _paymentMethod,
        'userId': user?.uid,
        'userName': user?.fullName,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      widget.onRequested(docRef.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking error: $e')));
    }
  }
}

class _ActiveRequestScreen extends StatefulWidget {
  final String requestId;
  final VoidCallback onClose;
  const _ActiveRequestScreen({required this.requestId, required this.onClose});

  @override
  State<_ActiveRequestScreen> createState() => _ActiveRequestScreenState();
}

class _ActiveRequestScreenState extends State<_ActiveRequestScreen> {
  final _commentC = TextEditingController();
  double _rating = 5.0;
  bool _submittedRating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE65100),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('taxi_requests').doc(widget.requestId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.white));
          if (!snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Request no longer exists.', style: TextStyle(color: Colors.white)),
                  ElevatedButton(onPressed: widget.onClose, child: const Text('GO BACK')),
                ],
              ),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Pending';

          if (status == 'Trip Completed' || status == 'Completed') {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 80),
                    const SizedBox(height: 24),
                    const Text('Trip Completed!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text('Total Fare: ${data['fare']} ETB', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                    const SizedBox(height: 40),
                    if (!_submittedRating) ...[
                      const Text('How was your trip?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Slider(
                        value: _rating,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _rating.round().toString(),
                        onChanged: (v) => setState(() => _rating = v),
                        activeColor: Colors.yellowAccent,
                      ),
                      TextField(
                        controller: _commentC,
                        decoration: const InputDecoration(hintText: 'Add a comment (optional)', hintStyle: TextStyle(color: Colors.white60)),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitRating,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.orange),
                        child: const Text('SUBMIT RATING'),
                      ),
                    ] else
                      const Text('Thank you for your feedback!', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: widget.onClose,
                      child: const Text('BACK TO HOME', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_taxi, color: Colors.white, size: 80),
                  const SizedBox(height: 32),
                  Text(
                    _getStatusMsg(status),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (data['driverName'] != null) ...[
                    Text('Driver: ${data['driverName']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Phone: ${data['driverPhone'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                  ],
                  const SizedBox(height: 48),
                  const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.white24),
                  const SizedBox(height: 48),
                  Text('From: ${data['pickup']}\nTo: ${data['destination']}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                  const Spacer(),
                  if (status == 'Pending' || status == 'Driver Assigned')
                    TextButton(
                      onPressed: () => FirebaseFirestore.instance.collection('taxi_requests').doc(widget.requestId).update({'status': 'Cancelled'}).then((_) => widget.onClose()),
                      child: const Text('CANCEL REQUEST', style: TextStyle(color: Colors.white70)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStatusMsg(String status) {
    switch (status) {
      case 'Pending': return 'Finding your driver...';
      case 'Driver Assigned': return 'Driver is on the way!';
      case 'Driver Arrived': return 'Driver has arrived at pickup!';
      case 'Trip Started': return 'Enjoy your trip!';
      default: return status;
    }
  }

  void _submitRating() async {
    final user = Provider.of<custom_auth.AuthProvider>(context, listen: false).userModel;
    await FirebaseFirestore.instance.collection('taxi_ratings').add({
      'requestId': widget.requestId,
      'userId': user?.uid,
      'userName': user?.fullName,
      'rating': _rating.round(),
      'comment': _commentC.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    setState(() => _submittedRating = true);
  }
}
