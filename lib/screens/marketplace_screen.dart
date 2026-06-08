import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.electrical_services, 'label': 'Electricians'},
      {'icon': Icons.plumbing, 'label': 'Plumbers'},
      {'icon': Icons.build_rounded, 'label': 'Mechanics'},
      {'icon': Icons.format_paint, 'label': 'Painters'},
      {'icon': Icons.chair_rounded, 'label': 'Carpenters'},
      {'icon': Icons.engineering, 'label': 'Engineers'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('CONTRACTOR HUB')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CATEGORIES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) => _buildCategory(categories[i]),
            ),
            const SizedBox(height: 32),
            const Text('TOP RATED PROVIDERS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildProviderCard('Samuel Electric', 'Electrician • 5.0 ⭐', '120 jobs done'),
            _buildProviderCard('Aman Plumbing', 'Plumber • 4.8 ⭐', '85 jobs done'),
            _buildProviderCard('Hawassa Builders', 'Construction • 4.9 ⭐', '40 projects'),
            const SizedBox(height: 32),
            const Text('REQUEST QUOTATION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            _buildQuotationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(Map<String, dynamic> cat) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(cat['icon'] as IconData, color: Colors.deepOrangeAccent),
          const SizedBox(height: 8),
          Text(cat['label'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProviderCard(String name, String sub, String stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.deepOrange, child: Icon(Icons.person, color: Colors.white)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub),
        trailing: Text(stats, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ),
    );
  }

  Widget _buildQuotationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.withOpacity(0.3))),
      child: Column(
        children: [
          const Text('Need a custom project estimate?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Submit your project details and get quotes from verified contractors.', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('GET FREE QUOTE')),
        ],
      ),
    );
  }
}
