import 'package:flutter/material.dart';

class ContractRideScreen extends StatelessWidget {
  const ContractRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract & Private Rides'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Premium Transportation Services',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Book private rides for your special needs in Hawassa.'),
            const SizedBox(height: 25),
            _buildContractOption(context, 'Airport Transfer', 'Hawassa Airport to City', Icons.airplanemode_active),
            _buildContractOption(context, 'Full Day Booking', 'City tours & private usage', Icons.event_available),
            _buildContractOption(context, 'Hotel Transfer', 'Seamless travel to your resort', Icons.hotel),
            _buildContractOption(context, 'Corporate Transport', 'For business meetings & events', Icons.business),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Pre-booking required', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Please book at least 2 hours in advance for guaranteed availability.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractOption(BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: Colors.blue[800], child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
          child: const Text('Book'),
        ),
      ),
    );
  }
}
