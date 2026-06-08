import 'dart:async';
import 'package:flutter/material.dart';

enum RideState { idle, searching, driverFound, driverComing, rideStarted, completed, payment, rating }

class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> with TickerProviderStateMixin {
  RideState _state = RideState.idle;
  String? _selectedDest;
  String? _selectedVehicle;
  int _countdown = 3;
  Timer? _timer;
  int _rating = 0;
  String? _paymentMethod;
  bool _isPaying = false;

  late final AnimationController _pulseController;
  late final AnimationController _carController;

  final Map<String, int> _destDistances = {
    'Piazza': 2,
    'Hawassa University': 5,
    'Amora Gedel': 3,
    'Haile Resort': 4,
    'Gudumale Cultural Center': 6,
    'Tabor Mountain': 7,
    'Tula/Industrial Park': 9,
    'Millennium Park': 4,
  };

  final Map<String, Map<String, int>> _vehiclePrices = {
    'Motor': {'base': 40, 'km': 15},
    'Bajaj': {'base': 60, 'km': 20},
    'Car': {'base': 100, 'km': 30},
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _carController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _carController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  int get _calculateFare {
    if (_selectedDest == null || _selectedVehicle == null) return 0;
    final dist = _destDistances[_selectedDest]!;
    final price = _vehiclePrices[_selectedVehicle]!;
    return price['base']! + (dist * price['km']!);
  }

  void _startSearching() {
    setState(() => _state = RideState.searching);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _state = RideState.driverFound;
        _countdown = 3;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown > 0) {
          setState(() => _countdown--);
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _startComing() {
    setState(() => _state = RideState.driverComing);
    _carController.reset();
    _carController.forward();
  }

  void _startRide() {
    setState(() => _state = RideState.rideStarted);
    _carController.reset();
    _carController.forward();
  }

  void _finishRide() {
    setState(() => _state = RideState.completed);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _state = RideState.payment);
    });
  }

  void _processPayment() {
    setState(() => _isPaying = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isPaying = false;
        _state = RideState.rating;
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case RideState.idle:
        return _buildIdle();
      case RideState.searching:
        return _buildSearching();
      case RideState.driverFound:
        return _buildDriverFound();
      case RideState.driverComing:
        return _buildDriverComing();
      case RideState.rideStarted:
        return _buildRideStarted();
      case RideState.completed:
        return _buildCompleted();
      case RideState.payment:
        return _buildPayment();
      case RideState.rating:
        return _buildRating();
    }
  }

  Widget _buildIdle() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Destination', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: _destDistances.keys.map((dest) {
              final isSelected = _selectedDest == dest;
              return ChoiceChip(
                label: Text(dest),
                selected: isSelected,
                onSelected: (val) => setState(() => _selectedDest = val ? dest : null),
                selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Choose Vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: _vehiclePrices.keys.map((v) {
              final isSelected = _selectedVehicle == v;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedVehicle = v),
                  child: Card(
                    color: isSelected ? const Color(0xFF2E7D32).withOpacity(0.1) : null,
                    shape: isSelected ? RoundedRectangleBorder(side: const BorderSide(color: Color(0xFF2E7D32)), borderRadius: BorderRadius.circular(8)) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Icon(v == 'Motor' ? Icons.motorcycle : v == 'Bajaj' ? Icons.electric_rickshaw : Icons.directions_car, color: const Color(0xFF2E7D32)),
                          Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${_vehiclePrices[v]!['base']}+${_vehiclePrices[v]!['km']}/km', style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedDest != null && _selectedVehicle != null) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Text('Estimated Fare', style: TextStyle(color: Colors.grey)),
                  Text('${_calculateFare} ETB', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_selectedDest != null && _selectedVehicle != null) ? _startSearching : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
              child: const Text('REQUEST RIDE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearching() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF2E7D32)),
          const SizedBox(height: 24),
          const Text('Searching for nearby drivers...', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildDriverFound() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ScaleTransition(
            scale: _pulseController,
            child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
          ),
          const SizedBox(height: 24),
          const Text('Driver Found!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Tadesse Bekele', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Toyota Corolla ET-3421 AA'),
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.star, color: Colors.amber, size: 16), Text(' 4.8')],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('Arriving in $_countdown mins', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _startComing,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
              child: const Text('TRACK DRIVER'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverComing() {
    return Column(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _carController,
            builder: (context, child) {
              return CustomPaint(
                painter: MapPainter(_carController.value),
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
              const Text('Driver is on the way', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _startRide,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                  child: const Text('PASSENGER PICKED UP'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRideStarted() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🚕', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text('Ride in Progress', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                const SizedBox(height: 8),
                Text('To: $_selectedDest', style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)]),
          child: Column(
            children: [
              Text('Total Fare: $_calculateFare ETB', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _finishRide,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                  child: const Text('ARRIVE AT DESTINATION'),
                ),
              ),
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
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text('You have arrived!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Total Fare: $_calculateFare ETB', style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildPayment() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Payment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$_calculateFare ETB', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          const SizedBox(height: 32),
          _paymentOption('Telebirr', 'Fast and secure mobile money', Colors.green, Icons.account_balance_wallet),
          const SizedBox(height: 12),
          _paymentOption('CBE Birr', 'Official bank mobile payment', Colors.blue, Icons.account_balance),
          const SizedBox(height: 12),
          _paymentOption('Cash', 'Pay with cash to driver', Colors.grey, Icons.money),
          const Spacer(),
          if (_isPaying)
            const CircularProgressIndicator(color: Color(0xFF2E7D32))
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _paymentMethod != null ? _processPayment : null,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                child: Text('PAY NOW $_calculateFare ETB'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _paymentOption(String name, String desc, Color color, IconData icon) {
    final isSelected = _paymentMethod == name;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = name),
      child: Card(
        color: isSelected ? color.withOpacity(0.1) : null,
        shape: isSelected ? RoundedRectangleBorder(side: BorderSide(color: color, width: 2), borderRadius: BorderRadius.circular(8)) : null,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(desc),
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Tadesse Bekele', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Toyota Corolla ET-3421 AA'),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Rate your driver', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 40),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _rating > 0 ? () => setState(() => _state = RideState.idle) : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
              child: const Text('SUBMIT RATING'),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final double progress;
  MapPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 5..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(size.width / 2, 50);
    path.lineTo(size.width / 2, size.height - 50);
    canvas.drawPath(path, paint);

    final markerPaint = Paint()..color = const Color(0xFF2E7D32)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 50), 10, markerPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height - 50), 10, Paint()..color = Colors.red);

    final carOffset = Offset(size.width / 2, 50 + (size.height - 100) * progress);
    const textSpan = TextSpan(text: '🚕', style: TextStyle(fontSize: 30));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, carOffset - const Offset(15, 15));
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => oldDelegate.progress != progress;
}
