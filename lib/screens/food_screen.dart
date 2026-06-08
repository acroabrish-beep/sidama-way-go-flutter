import 'package:flutter/material.dart';

enum FoodOrderState { idle, ordering, findingRider, riderComing, delivered }

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  FoodOrderState _state = FoodOrderState.idle;
  bool _isDelivery = true;

  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Haile Resort',
      'menu': [
        {'item': 'Grilled Fish', 'price': 350},
        {'item': 'Chicken Burger', 'price': 280},
      ],
    },
    {
      'name': 'Lewi Hotel',
      'menu': [
        {'item': 'Special Kitfo', 'price': 450},
        {'item': 'Pasta with Veggies', 'price': 200},
      ],
    },
    {
      'name': 'Sidama Cultural Restaurant',
      'menu': [
        {'item': 'Bursame', 'price': 180},
        {'item': 'Wassa', 'price': 150},
      ],
    },
  ];

  void _placeOrder() {
    setState(() => _state = FoodOrderState.ordering);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _state = FoodOrderState.findingRider);
      Future.delayed(const Duration(seconds: 3), () {
        setState(() => _state = FoodOrderState.riderComing);
        Future.delayed(const Duration(seconds: 5), () {
          setState(() => _state = FoodOrderState.delivered);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food & Dining'),
        backgroundColor: const Color(0xFFAD1457),
        foregroundColor: Colors.white,
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_state == FoodOrderState.idle) return _buildRestaurantList();
    return _buildOrderTracking();
  }

  Widget _buildRestaurantList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Delivery'), icon: Icon(Icons.delivery_dining)),
              ButtonSegment(value: false, label: Text('Dine-in'), icon: Icon(Icons.restaurant)),
            ],
            selected: {_isDelivery},
            onSelectionChanged: (s) => setState(() => _isDelivery = s.first),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _restaurants.length,
            itemBuilder: (context, i) {
              final r = _restaurants[i];
              return ExpansionTile(
                title: Text(r['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                leading: const Icon(Icons.store, color: Color(0xFFAD1457)),
                children: (r['menu'] as List).map((m) => ListTile(
                  title: Text(m['item']),
                  trailing: Text('${m['price']} ETB'),
                  onTap: _placeOrder,
                )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTracking() {
    String status = '';
    IconData icon = Icons.timer;
    switch (_state) {
      case FoodOrderState.ordering: status = 'Placing Order...'; icon = Icons.shopping_cart; break;
      case FoodOrderState.findingRider: status = 'Finding Delivery Rider...'; icon = Icons.person_search; break;
      case FoodOrderState.riderComing: status = 'Rider is on the way 🛵'; icon = Icons.delivery_dining; break;
      case FoodOrderState.delivered: status = 'Order Delivered! Enjoy your meal.'; icon = Icons.check_circle; break;
      default: break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: const Color(0xFFAD1457)),
          const SizedBox(height: 24),
          Text(status, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (_state == FoodOrderState.delivered) ...[
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => setState(() => _state = FoodOrderState.idle),
              child: const Text('Order Again'),
            ),
          ],
        ],
      ),
    );
  }
}
