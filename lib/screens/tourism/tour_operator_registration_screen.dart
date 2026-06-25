import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TourOperatorRegistrationScreen extends StatefulWidget {
  const TourOperatorRegistrationScreen({super.key});

  @override
  State<TourOperatorRegistrationScreen> createState() => _TourOperatorRegistrationScreenState();
}

class _TourOperatorRegistrationScreenState extends State<TourOperatorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyC = TextEditingController();
  final _ownerC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emailC = TextEditingController();
  final _addressC = TextEditingController();
  final _licenseC = TextEditingController();
  final _descC = TextEditingController();

  final List<String> _selectedServices = [];
  final List<String> _services = ['Tour Packages', 'Vehicle Hire', 'Guide Provision', 'Airport Transfer', 'Hotel Booking'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register as Tour Operator"), backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _companyC, decoration: const InputDecoration(labelText: "Company Name"), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              TextFormField(controller: _ownerC, decoration: const InputDecoration(labelText: "Owner Full Name"), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneC, decoration: const InputDecoration(labelText: "Business Phone"), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailC, decoration: const InputDecoration(labelText: "Business Email"), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              TextFormField(controller: _addressC, decoration: const InputDecoration(labelText: "Office Address"), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 16),
              TextFormField(controller: _licenseC, decoration: const InputDecoration(labelText: "Business License Number"), validator: (v) => v!.isEmpty ? "Required" : null),
              const SizedBox(height: 24),
              const Text("Services Offered", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _services.map((service) {
                  final isSelected = _selectedServices.contains(service);
                  return FilterChip(
                    label: Text(service),
                    selected: isSelected,
                    onSelected: (v) => setState(() => v ? _selectedServices.add(service) : _selectedServices.remove(service)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descC,
                decoration: const InputDecoration(labelText: "Company Description", hintText: "Max 300 characters"),
                maxLines: 4,
                maxLength: 300,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitRegistration,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Submit Registration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one service")));
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('tour_operators').doc(user?.uid).set({
        'companyName': _companyC.text,
        'ownerName': _ownerC.text,
        'phone': _phoneC.text,
        'email': _emailC.text,
        'address': _addressC.text,
        'licenseNumber': _licenseC.text,
        'description': _descC.text,
        'services': _selectedServices,
        'userId': user?.uid,
        'status': "pending",
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text("Registration Submitted!"),
          content: const Text("Thank you for registering. Our team will verify your business license and details."),
          actions: [TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("OK"))],
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
