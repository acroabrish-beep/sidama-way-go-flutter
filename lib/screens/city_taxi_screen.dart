import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CityTaxiScreen extends StatefulWidget {
  const CityTaxiScreen({super.key});

  @override
  State<CityTaxiScreen> createState() => _CityTaxiScreenState();
}

class _CityTaxiScreenState extends State<CityTaxiScreen> {
  final List<Map<String, dynamic>> _areas = [
    {'name': 'Menaharia', 'fare': 8},
    {'name': 'Piassa', 'fare': 0},
    {'name': 'Haik Dar', 'fare': 6},
    {'name': 'Tabor', 'fare': 7},
    {'name': 'Hawella Tula', 'fare': 10},
    {'name': 'Addis Ketema', 'fare': 8},
    {'name': 'Gudumale', 'fare': 9},
    {'name': 'Misrak', 'fare': 7},
    {'name': 'Alamura', 'fare': 12},
    {'name': 'Hiteta', 'fare': 11},
    {'name': 'Dato', 'fare': 15},
  ];

  void _showBookingSheet(Map<String, dynamic> area) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return _BookingBottomSheet(area: area);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _areas.length,
              itemBuilder: (context, index) {
                final area = _areas[index];
                if (area['name'] == 'Piassa') return const SizedBox.shrink();
                return Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () => _showBookingSheet(area),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFE65100)),
                          const SizedBox(height: 8),
                          Text(area['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${area['fare']} ETB', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> area;
  const _BookingBottomSheet({required this.area});

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
      final userId = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('taxi_bookings').add({
        'destination': widget.area['name'],
        'fare': widget.area['fare'],
        'paymentMethod': _paymentMethod,
        'userId': userId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Taxi booked! Driver will arrive in 3-5 mins'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking error: $e')));
    }
  }
}
