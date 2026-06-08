import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'name': 'Telebirr', 'icon': Icons.account_balance_wallet, 'color': Colors.blue},
      {'name': 'CBE Birr', 'icon': Icons.account_balance, 'color': Colors.purple},
      {'name': 'Chapa', 'icon': Icons.payment, 'color': Colors.indigo},
      {'name': 'Cash', 'icon': Icons.money, 'color': Colors.green},
    ];

    final history = [
      {'title': 'Ride to Piazza', 'amount': '-40 ETB', 'date': 'Today'},
      {'title': 'Eco-Shine Basic', 'amount': '-80 ETB', 'date': 'Yesterday'},
      {'title': 'Top up', 'amount': '+200 ETB', 'date': '2 days ago'},
      {'title': 'Food Delivery', 'amount': '-150 ETB', 'date': '3 days ago'},
      {'title': 'Ride to Stadium', 'amount': '-30 ETB', 'date': '4 days ago'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF283593),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            color: const Color(0xFF283593),
            child: Column(
              children: [
                const Text('Total Balance', style: TextStyle(color: Colors.white70)),
                const Text('425.50 ETB', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Money'),
                  style: ElevatedButton.styleFrom(foregroundColor: const Color(0xFF283593), backgroundColor: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Payment Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...methods.map((m) => Card(
                  child: ListTile(
                    leading: Icon(m['icon'] as IconData, color: m['color'] as Color),
                    title: Text(m['name'] as String),
                    trailing: TextButton(onPressed: () {}, child: const Text('Select')),
                  ),
                )),
                const SizedBox(height: 24),
                const Text('Recent Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...history.map((h) => ListTile(
                  title: Text(h['title']!),
                  subtitle: Text(h['date']!),
                  trailing: Text(h['amount']!, style: TextStyle(fontWeight: FontWeight.bold, color: h['amount']!.startsWith('+') ? Colors.green : Colors.black)),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
