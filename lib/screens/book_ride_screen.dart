import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum RideState { idle, searching, driverFound, driverComing, rideStarted, completed, payment, rating }

class BookRideScreen extends StatefulWidget {
  final String? initialDestination;
  const BookRideScreen({super.key, this.initialDestination});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> with SingleTickerProviderStateMixin {
  RideState _state = RideState.idle;
  String? _selectedDestination;
  String _selectedVehicle = 'Bajaj 🛺';
  int _countdown = 180;
  Timer? _timer;
  double _progress = 0.0;
  late AnimationController _animController;
  int _selectedRating = 0;

  final List<Map<String, dynamic>> _destinations = [
    {'name': 'Piazza', 'dist': 1.5},
    {'name': 'Hawassa University', 'dist': 4.2},
    {'name': 'Amora Gedel', 'dist': 2.8},
    {'name': 'Haile Resort', 'dist': 5.5},
    {'name': 'Gudumale Center', 'dist': 3.1},
    {'name': 'Tabor Mountain', 'dist': 6.0},
    {'name': 'Industrial Park', 'dist': 12.0},
  ];

  final Map<String, Map<String, dynamic>> _vehicles = {
    'Motor 🏍️': {'base': 40, 'km': 15},
    'Bajaj 🛺': {'base': 60, 'km': 20},
    'Car 🚗': {'base': 100, 'km': 30},
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null) {
      _selectedDestination = widget.initialDestination;
    }
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  int get _calculateFare {
    if (_selectedDestination == null) return 0;
    final dest = _destinations.firstWhere((d) => d['name'] == _selectedDestination);
    final v = _vehicles[_selectedVehicle]!;
    return (v['base'] + (v['km'] * dest['dist'])).round();
  }

  void _startSearch() {
    setState(() => _state = RideState.searching);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _state = RideState.driverFound;
        _startCountdown();
      });
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _startRide();
      }
    });
  }

  void _startRide() {
    setState(() => _state = RideState.driverComing);
    _animController.forward().then((_) {
       setState(() => _state = RideState.rideStarted);
       Future.delayed(const Duration(seconds: 5), () {
         setState(() => _state = RideState.completed);
         Future.delayed(const Duration(seconds: 2), () => setState(() => _state = RideState.payment));
       });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_state == RideState.idle ? 'Book Ride' : 'Ride Status'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    switch (_state) {
      case RideState.idle: return _buildIdle();
      case RideState.searching: return _buildSearching();
      case RideState.driverFound: return _buildDriverFound();
      case RideState.driverComing:
      case RideState.rideStarted: return _buildActiveRide();
      case RideState.completed: return _buildCompleted();
      case RideState.payment: return _buildPayment();
      case RideState.rating: return _buildRating();
    }
  }

  Widget _buildIdle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Where to?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _destinations.map((d) => ChoiceChip(
              label: Text(d['name']),
              selected: _selectedDestination == d['name'],
              onSelected: (s) => setState(() => _selectedDestination = s ? d['name'] : null),
            )).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Select Vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(
            children: _vehicles.keys.map((v) => ListTile(
              title: Text(v),
              trailing: Text('${_vehicles[v]!['base']} ETB Base'),
              leading: Radio<String>(
                value: v, groupValue: _selectedVehicle,
                onChanged: (val) => setState(() => _selectedVehicle = val!),
              ),
            )).toList(),
          ),
          if (_selectedDestination != null) ...[
            const Divider(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Fare:', style: TextStyle(fontSize: 16)),
                  Text('$_calculateFare ETB', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _startSearch,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                child: const Text('REQUEST RIDE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearching() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 80, height: 80, child: CircularProgressIndicator(strokeWidth: 8, color: Color(0xFF2E7D32))),
          const SizedBox(height: 32),
          const Text('Searching for nearby drivers...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Text('Matching you with the best $_selectedVehicle', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDriverFound() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Driver Found!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    children: [
                      CircleAvatar(radius: 30, child: Icon(Icons.person, size: 40)),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tadesse Bekele', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Text(' 4.8 (240 trips)')]),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  const Text('Toyota Corolla - ET-3421 AA', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Text('Arriving in ${_countdown ~/ 60}:${(_countdown % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Text('Driver is coming to your location', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActiveRide() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green.shade50,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              Text(_state == RideState.driverComing ? 'Driver is on the way' : 'Ride in progress',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            ],
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return CustomPaint(
                painter: RideMapPainter(_animController.value),
                child: Container(),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)]),
          child: Column(
            children: [
              Text('Destination: $_selectedDestination', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_state == RideState.rideStarted)
                Text('Current Fare: $_calculateFare ETB', style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompleted() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: Colors.green),
          const SizedBox(height: 24),
          const Text('You have arrived!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Total Fare: $_calculateFare ETB', style: const TextStyle(fontSize: 20, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPayment() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Select Payment Method', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Total Amount: $_calculateFare ETB', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 32),
          _payBtn('Telebirr', Colors.green, Icons.account_balance_wallet),
          const SizedBox(height: 16),
          _payBtn('CBE Birr', Colors.blue, Icons.account_balance),
          const SizedBox(height: 16),
          _payBtn('Cash', Colors.grey, Icons.money),
        ],
      ),
    );
  }

  Widget _payBtn(String name, Color color, IconData icon) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _state = RideState.rating),
        icon: Icon(icon), label: Text(name),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      ),
    );
  }

  Widget _buildRating() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            const Text('Rate Tadesse Bekele', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                icon: Icon(i < _selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 40),
                onPressed: () => setState(() => _selectedRating = i + 1),
              )),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => setState(() => _state = RideState.idle),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                child: const Text('SUBMIT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RideMapPainter extends CustomPainter {
  final double progress;
  RideMapPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 4..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.8, size.height * 0.2);
    canvas.drawPath(path, paint);

    final activePaint = Paint()..color = Colors.green..strokeWidth = 4..style = PaintingStyle.stroke;
    final activePath = Path();
    activePath.moveTo(size.width * 0.2, size.height * 0.8);
    activePath.lineTo(
      size.width * 0.2 + (size.width * 0.6 * progress),
      size.height * 0.8 - (size.height * 0.6 * progress)
    );
    canvas.drawPath(activePath, activePaint);

    final textPainter = TextPainter(text: const TextSpan(text: '🚕', style: TextStyle(fontSize: 30)), textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset(
      size.width * 0.2 + (size.width * 0.6 * progress) - 15,
      size.height * 0.8 - (size.height * 0.6 * progress) - 15
    ));
  }

  @override
  bool shouldRepaint(RideMapPainter oldDelegate) => oldDelegate.progress != progress;
}
