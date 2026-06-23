import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryServicesScreen extends StatelessWidget {
  const DeliveryServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Delivery Services'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'Food'),
              Tab(icon: Icon(Icons.medical_services), text: 'Pharmacy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FoodTab(),
            _PharmacyTab(),
          ],
        ),
      ),
    );
  }
}

class _FoodTab extends StatelessWidget {
  const _FoodTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DeliveryTrackingCard(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No restaurants found.'));

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final r = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 100, color: Colors.green.shade100, child: const Center(child: Icon(Icons.restaurant, size: 40))),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r['name'] ?? 'Restaurant', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(r['location'] ?? 'Hawassa', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              const Text('Prices from 50 ETB', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PharmacyTab extends StatelessWidget {
  const _PharmacyTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(decoration: InputDecoration(hintText: 'Enter medicine name...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search))),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('pharmacies').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('No pharmacies found.'));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final p = docs[index].data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_pharmacy, color: Colors.red),
                      title: Text(p['name'] ?? 'Pharmacy'),
                      subtitle: Text(p['location'] ?? 'Hawassa'),
                      trailing: ElevatedButton(onPressed: () {}, child: const Text('Order')),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DeliveryTrackingCard extends StatelessWidget {
  const _DeliveryTrackingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.motorcycle, color: Colors.green),
                SizedBox(width: 8),
                Text('Track Your Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('Map View: Rider at Piazza intersection')),
            ),
          ],
        ),
      ),
    );
  }
}
