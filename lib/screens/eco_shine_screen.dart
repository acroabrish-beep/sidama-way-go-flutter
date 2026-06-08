import 'package:flutter/material.dart';

class EcoShineScreen extends StatelessWidget {
  const EcoShineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final packages = [
      {'name': 'Basic', 'price': '80', 'features': ['Exterior Wash', 'Tire Shine']},
      {'name': 'Premium', 'price': '150', 'features': ['Exterior Wash', 'Interior Vacuum', 'Wax', 'Tire Shine']},
      {'name': 'VIP', 'price': '250', 'features': ['Premium Features', 'Engine Clean', 'Leather Care', 'Fragrance']},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco-Shine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00695C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hawassa Eco Car Wash', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Choose a package for your vehicle', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ...packages.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p['name'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('${p['price']} ETB', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00695C))),
                      ],
                    ),
                    const Divider(),
                    ...(p['features'] as List<String>).map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [const Icon(Icons.check_circle, size: 16, color: Colors.green), const SizedBox(width: 8), Text(f)]),
                    )),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                        child: const Text('Select Package', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),
            const Text('Schedule Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_today), label: const Text('Select Date')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.access_time), label: const Text('Select Time')),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('BOOK NOW', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
