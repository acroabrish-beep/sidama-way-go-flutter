import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CITY FLOW ANALYTICS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('REAL-TIME MONITORING', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Row(
              children: [
                _miniStat('FLOW', '94%', Icons.speed_rounded, Colors.green),
                const SizedBox(width: 12),
                _miniStat('ACTIVE', '1.2k', Icons.drive_eta_rounded, Colors.blue),
              ],
            ),
            const SizedBox(height: 32),
            const Text('TRANSPORT DEMAND FORECAST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _bar(30), _bar(50), _bar(80), _bar(100), _bar(70), _bar(40),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('RECENT CITY ALERTS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _alertItem('Road Closure', 'Piazza intersection closed for maintenance.', 'High'),
            _alertItem('Traffic Surge', 'Unusual traffic detected near Stadium.', 'Medium'),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _bar(double h) {
    return Container(
      width: 20,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _alertItem(String title, String desc, String priority) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.warning_rounded, color: priority == 'High' ? Colors.red : Colors.orange),
        title: Text(title),
        subtitle: Text(desc),
        trailing: Text(priority, style: TextStyle(color: priority == 'High' ? Colors.red : Colors.orange, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
