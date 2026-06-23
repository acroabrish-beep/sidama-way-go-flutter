import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';

class CitizenReportingScreen extends StatefulWidget {
  const CitizenReportingScreen({super.key});

  @override
  State<CitizenReportingScreen> createState() => _CitizenReportingScreenState();
}

class _CitizenReportingScreenState extends State<CitizenReportingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'Road Damage';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Road Damage',
    'Waste Problems',
    'Broken Street Lights',
    'Illegal Activities',
    'Public Service Issues',
    'Water Supply Leak',
    'Other'
  ];

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      await FirebaseFirestore.instance.collection('citizen_reports').add({
        'userId': user?.uid,
        'userName': user?.fullName,
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully! Thank you for your contribution.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen Reporting'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report a City Issue',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Help us build a better Hawassa by reporting infrastructure or service issues in your neighborhood.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Address or Landmark)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Provide details about the issue...',
                ),
                validator: (v) => v!.isEmpty ? 'Please provide description' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Icon(Icons.send),
                  label: const Text('SUBMIT REPORT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text('Your Previous Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildMyReports(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyReports() {
    final user = Provider.of<AuthProvider>(context).userModel;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('citizen_reports')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Text('No reports submitted yet.', style: TextStyle(color: Colors.grey));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(data['category'] ?? 'Issue'),
                subtitle: Text(data['status'] ?? 'Pending'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}
