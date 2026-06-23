import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _plateController = TextEditingController();
  final _routeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _plateController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('drivers').add({
        'fullName': _nameController.text,
        'phone': _phoneController.text,
        'licenseNumber': _licenseController.text,
        'vehiclePlate': _plateController.text,
        'routeAssignment': _routeController.text,
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver Registered Successfully')));
      _formKey.currentState!.reset();
      _nameController.clear();
      _phoneController.clear();
      _licenseController.clear();
      _plateController.clear();
      _routeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Registration')),
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
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Enter full name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _licenseController,
                      decoration: const InputDecoration(labelText: 'License Number', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Enter license number' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(labelText: 'Vehicle Plate', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _routeController,
                      decoration: const InputDecoration(labelText: 'Route Assignment', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading ? const CircularProgressIndicator() : const Text('SAVE DRIVER'),
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
            child: Text('Active Drivers', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('drivers').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No drivers yet.'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(data['fullName'] ?? 'N/A'),
                      subtitle: Text('Phone: ${data['phone']} | Plate: ${data['vehiclePlate']}'),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
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
