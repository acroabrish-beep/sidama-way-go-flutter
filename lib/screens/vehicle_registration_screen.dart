import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _driverController = TextEditingController();
  final _ownerController = TextEditingController();
  final _routeController = TextEditingController();
  String _vehicleType = 'City Taxi';
  bool _isLoading = false;

  @override
  void dispose() {
    _plateController.dispose();
    _driverController.dispose();
    _ownerController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('vehicles').add({
        'plateNumber': _plateController.text,
        'type': _vehicleType,
        'driverName': _driverController.text,
        'ownerName': _ownerController.text,
        'route': _routeController.text,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle Registered Successfully')));
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Registration')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'Plate Number', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Enter plate number' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _vehicleType,
                      decoration: const InputDecoration(labelText: 'Vehicle Type', border: OutlineInputBorder()),
                      items: ['City Taxi', 'Minibus', 'Intercity Bus']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _vehicleType = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _driverController,
                      decoration: const InputDecoration(labelText: 'Driver Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Enter driver name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ownerController,
                      decoration: const InputDecoration(labelText: 'Owner Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _routeController,
                      decoration: const InputDecoration(labelText: 'Assigned Route', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading ? const CircularProgressIndicator() : const Text('REGISTER VEHICLE'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Recently Registered', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vehicles').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['plateNumber']),
                      subtitle: Text('${data['type']} - ${data['driverName']}'),
                      trailing: Chip(label: Text(data['status'] ?? 'Active')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
