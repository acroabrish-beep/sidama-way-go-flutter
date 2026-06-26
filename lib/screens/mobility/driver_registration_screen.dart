import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _plateController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _licenseController = TextEditingController();

  String _vehicleType = 'City Taxi';
  String? _selectedStation;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _vehicleColorController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedStation == null) {
      if (_selectedStation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a station')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? '';
      final timestamp = FieldValue.serverTimestamp();

      // Save to drivers collection
      await FirebaseFirestore.instance.collection('drivers').doc(uid).set({
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'plateNumber': _plateController.text,
        'vehicleType': _vehicleType,
        'vehicleColor': _vehicleColorController.text,
        'licenseNumber': _licenseController.text,
        'stationName': _selectedStation,
        'userId': uid,
        'status': 'active',
        'isAvailable': true,
        'rating': 0,
        'totalTrips': 0,
        'createdAt': timestamp,
      });

      // Save to vehicles collection
      await FirebaseFirestore.instance.collection('vehicles').add({
        'plateNumber': _plateController.text,
        'vehicleType': _vehicleType,
        'driverName': _fullNameController.text,
        'ownerName': _fullNameController.text,
        'route': _selectedStation,
        'status': 'Active',
        'createdAt': timestamp,
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Successful'),
            content: Text('Registration successful! You can now join the queue at $_selectedStation.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Taxi Driver'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(labelText: 'Plate Number (e.g. HW-34567)', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _vehicleType,
                decoration: const InputDecoration(labelText: 'Vehicle Type', border: OutlineInputBorder()),
                items: ['City Taxi', 'Minibus', 'Bajaj'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _vehicleType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleColorController,
                decoration: const InputDecoration(labelText: 'Vehicle Color', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(labelText: 'License Number', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('taxi_stations').where('isActive', isEqualTo: true).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) return Text('Error: ${snapshot.error}');

                  final stations = snapshot.data?.docs ?? [];
                  if (stations.isEmpty) return const Text('No stations available');

                  return DropdownButtonFormField<String>(
                    initialValue: _selectedStation,
                    decoration: const InputDecoration(labelText: 'Select Station', border: OutlineInputBorder()),
                    items: stations.map((doc) {
                      final name = doc['name'] as String;
                      return DropdownMenuItem(value: name, child: Text(name));
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedStation = v),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
