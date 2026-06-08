import 'package:flutter/material.dart';

class HealthcareScreen extends StatelessWidget {
  const HealthcareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare & Emergency'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildEmergencyAction(Icons.emergency, 'Call 939', Colors.red),
                const SizedBox(width: 15),
                _buildEmergencyAction(Icons.medical_services, 'Ambulance', Colors.orange),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Hospitals & Clinics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildHealthFacilityCard('Hawassa Referral Hospital', 'Public • 24/7', '046 220 1541'),
            _buildHealthFacilityCard('Kibebe Tsehay Hospital', 'Private • Specialized', '046 212 4545'),
            _buildHealthFacilityCard('Adare Hospital', 'Public • General', '046 220 3040'),
            const SizedBox(height: 30),
            const Text(
              'Pharmacies',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildHealthFacilityCard('Gudumale Pharmacy', 'Near Piazza', 'Open Now'),
            _buildHealthFacilityCard('Lakeside Pharmacy', 'Near Lake', 'Open 24h'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyAction(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthFacilityCard(String name, String type, String contact) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.local_hospital, color: Colors.white)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(type),
        trailing: const Icon(Icons.phone, color: Colors.green),
        onTap: () {},
      ),
    );
  }
}
