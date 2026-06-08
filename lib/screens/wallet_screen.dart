import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        'title': 'Book Ride — Bajaj',
        'amount': '-40 ETB',
        'date': 'Today 10:30',
        'icon': Icons.local_taxi,
        'credit': false,
      },
      {
        'title': 'Wallet Top-up',
        'amount': '+200 ETB',
        'date': 'Today 09:00',
        'icon': Icons.add_circle,
        'credit': true,
      },
      {
        'title': 'Delivery — Small',
        'amount': '-20 ETB',
        'date': 'Yesterday',
        'icon': Icons.inventory_2,
        'credit': false,
      },
      {
        'title': 'Bus Ticket',
        'amount': '-15 ETB',
        'date': 'Yesterday',
        'icon': Icons.directions_bus,
        'credit': false,
      },
      {
        'title': 'Wallet Top-up',
        'amount': '+500 ETB',
        'date': '2 days ago',
        'icon': Icons.add_circle,
        'credit': true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4527A0),
        title: const Text(
          'My Wallet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4527A0), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '625 ETB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _walletBtn(Icons.add, 'Top Up'),
                    _walletBtn(Icons.send, 'Send'),
                    _walletBtn(Icons.history, 'History'),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, i) {
                final t = transactions[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (t['credit'] as bool)
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        t['icon'] as IconData,
                        color: (t['credit'] as bool)
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(
                      t['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(t['date'] as String),
                    trailing: Text(
                      t['amount'] as String,
                      style: TextStyle(
                        color: (t['credit'] as bool)
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _walletBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
