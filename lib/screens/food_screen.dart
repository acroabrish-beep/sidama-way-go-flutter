import 'package:flutter/material.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  bool _isDelivery = true;

  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Haile Resort',
      'location': 'Lakeside',
      'menu': [
        {'item': 'Tilapia', 'price': 180},
        {'item': 'Kitfo', 'price': 220},
        {'item': 'Injera+Tibs', 'price': 150},
      ],
      'color': Colors.blue,
    },
    {
      'name': 'Lewi Hotel',
      'location': 'City Center',
      'menu': [
        {'item': 'Shiro', 'price': 65},
        {'item': 'Firfir', 'price': 55},
        {'item': 'Coffee', 'price': 45},
      ],
      'color': Colors.orange,
    },
    {
      'name': 'Sidama Cultural Restaurant',
      'location': 'Traditional Area',
      'menu': [
        {'item': 'Bulla', 'price': 45},
        {'item': 'Chukamo', 'price': 35},
        {'item': 'Coffee', 'price': 30},
      ],
      'color': Colors.brown,
    },
  ];

  void _placeOrder(String restaurant) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDelivery ? 'Order placed! Delivery in 25 min' : 'Table reserved at $restaurant!'),
        backgroundColor: const Color(0xFFAD1457),
      ),
    );
    // In a real app, this would navigate to a payment screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Dining', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFAD1457),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _isDelivery = true),
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Delivery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDelivery ? const Color(0xFFAD1457) : Colors.grey.shade200,
                      foregroundColor: _isDelivery ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _isDelivery = false),
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Dine-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isDelivery ? const Color(0xFFAD1457) : Colors.grey.shade200,
                      foregroundColor: !_isDelivery ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _restaurants.length,
              itemBuilder: (context, i) {
                final r = _restaurants[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: (r['color'] as Color).withOpacity(0.2),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Icon(Icons.restaurant, size: 60, color: r['color'] as Color),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(r['location'] as String, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 12),
                            const Text('Menu Highlights:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...(r['menu'] as List).map((m) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(m['item'] as String),
                                  Text('${m['price']} ETB', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _placeOrder(r['name'] as String),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAD1457), foregroundColor: Colors.white),
                                child: Text(_isDelivery ? 'ORDER NOW' : 'RESERVE TABLE'),
                              ),
                            ),
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
      ),
    );
  }
}
