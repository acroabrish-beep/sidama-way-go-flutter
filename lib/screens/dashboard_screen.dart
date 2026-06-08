import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('City Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hawassa Transport Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _statBox('24', 'Buses', Colors.blue),
                const SizedBox(width: 12),
                _statBox('156', 'Taxis', Colors.green),
                const SizedBox(width: 12),
                _statBox('89', 'Deliveries', Colors.orange),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Weekly Trip Volume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _bar(40, 'Mon'),
                  _bar(70, 'Tue'),
                  _bar(90, 'Wed'),
                  _bar(60, 'Thu'),
                  _bar(80, 'Fri'),
                  _bar(100, 'Sat'),
                  _bar(50, 'Sun'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('City Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _alertCard('Road Construction', 'Piassa area road closed for 2 days.', Colors.orange),
            _alertCard('New Bus Route', 'Route 4 now connecting Stadium to Lake.', Colors.green),
            _alertCard('Heavy Rain Warning', 'Expect delays due to flooding near Market.', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _bar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 20, height: height, decoration: BoxDecoration(color: Colors.deepPurple.shade300, borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _alertCard(String title, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.warning, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}
