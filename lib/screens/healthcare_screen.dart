import 'package:flutter/material.dart';

class HealthcareScreen extends StatelessWidget {
  const HealthcareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitals = [
      {'name': 'Hawassa Referral Hospital', 'type': 'Public', 'distance': '1.2 km', 'icon': Icons.local_hospital},
      {'name': 'Kibebe Tsehay Hospital', 'type': 'Private', 'distance': '2.5 km', 'icon': Icons.local_hospital},
      {'name': 'Adare Hospital', 'type': 'Public', 'distance': '3.8 km', 'icon': Icons.medical_services},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('HEALTHCARE HUB')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QUICK ACTIONS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAction('Book Appointment', Icons.calendar_month, Colors.blue),
                const SizedBox(width: 12),
                _buildAction('Ambulance', Icons.emergency, Colors.red),
                const SizedBox(width: 12),
                _buildAction('Tele-Health', Icons.video_call, Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            const Text('NEARBY HOSPITALS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            ...hospitals.map((h) => _buildHospitalCard(h)),
            const SizedBox(height: 32),
            const Text('SPECIALISTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildDoctorList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> h) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1), child: Icon(h['icon'] as IconData, color: Colors.red)),
        title: Text(h['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${h['type']} • ${h['distance']}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildDoctorList() {
    final doctors = [
      {'name': 'Dr. Abebe K.', 'specialty': 'Cardiologist', 'rating': '4.9'},
      {'name': 'Dr. Selam T.', 'specialty': 'Pediatrician', 'rating': '4.8'},
    ];
    return Column(
      children: doctors.map((d) => Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(d['name']!),
          subtitle: Text(d['specialty']!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(' ${d['rating']}')],
          ),
        ),
      )).toList(),
    );
  }
}
