import 'package:flutter/material.dart';

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
    final restaurants = [
      {'name': 'Haile Resort Dining', 'dish': 'Fresh Tilapia', 'price': '350 ETB'},
      {'name': 'Lewi Hotel', 'dish': 'Sidama Special Kitfo', 'price': '420 ETB'},
      {'name': 'Piazza Burger', 'dish': 'Zemenaw Burger', 'price': '180 ETB'},
    ];

    return Column(
      children: [
        const _DeliveryTrackingCard(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final r = restaurants[index];
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
                          Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(r['dish']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(r['price']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Medicine Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const TextField(decoration: InputDecoration(hintText: 'Enter medicine name...', border: OutlineInputBorder())),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.local_pharmacy, color: Colors.red),
          title: const Text('Gudumale Pharmacy'),
          subtitle: const Text('Verified • 1.2km away'),
          trailing: ElevatedButton(onPressed: () {}, child: const Text('Upload Prescription')),
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
