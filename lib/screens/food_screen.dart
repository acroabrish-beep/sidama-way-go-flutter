import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  bool _isDelivery = true;

  @override
  void initState() {
    super.initState();
    _seedRestaurants();
  }

  Future<void> _seedRestaurants() async {
    final snap = await FirebaseFirestore.instance.collection('restaurants').limit(1).get();
    if (snap.docs.isEmpty) {
      final restaurants = [
        {'name': 'Haile Resort', 'location': 'Lakeside', 'color': '0xFF1976D2'},
        {'name': 'Lewi Hotel', 'location': 'City Center', 'color': '0xFFF57C00'},
        {'name': 'Sidama Cultural Restaurant', 'location': 'Traditional Area', 'color': '0xFF795548'},
      ];
      for (var r in restaurants) {
        final docRef = await FirebaseFirestore.instance.collection('restaurants').add(r);
        final menu = [
          {'name': 'Tilapia', 'price': 180, 'restaurantId': docRef.id},
          {'name': 'Kitfo', 'price': 220, 'restaurantId': docRef.id},
          {'name': 'Shiro', 'price': 65, 'restaurantId': docRef.id},
        ];
        for (var m in menu) {
          await FirebaseFirestore.instance.collection('menu_items').add(m);
        }
      }
    }
  }

  void _placeOrder(DocumentSnapshot restDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _OrderBottomSheet(restDoc: restDoc, isDelivery: _isDelivery),
    );
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final r = docs[i].data() as Map<String, dynamic>;
                    final color = Color(int.parse(r['color'] ?? '0xFFAD1457'));
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
                              color: color.withOpacity(0.2),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Icon(Icons.restaurant, size: 60, color: color),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(r['location'] as String, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 12),
                                _buildMenuSnippet(docs[i].id),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _placeOrder(docs[i]),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSnippet(String restaurantId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('menu_items').where('restaurantId', isEqualTo: restaurantId).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Menu Highlights:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ...snapshot.data!.docs.map((m) {
              final d = m.data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d['name'] ?? '', style: const TextStyle(fontSize: 12)),
                    Text('${d['price']} ETB', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _OrderBottomSheet extends StatefulWidget {
  final DocumentSnapshot restDoc;
  final bool isDelivery;
  const _OrderBottomSheet({required this.restDoc, required this.isDelivery});

  @override
  State<_OrderBottomSheet> createState() => _OrderBottomSheetState();
}

class _OrderBottomSheetState extends State<_OrderBottomSheet> {
  final Map<String, int> _cart = {};

  @override
  Widget build(BuildContext context) {
    final rest = widget.restDoc.data() as Map<String, dynamic>;
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rest['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('menu_items').where('restaurantId', isEqualTo: widget.restDoc.id).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i].data() as Map<String, dynamic>;
                    final name = item['name'];
                    final price = item['price'];
                    return ListTile(
                      title: Text(name),
                      subtitle: Text('$price ETB'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () => setState(() => _cart[name] = (_cart[name] ?? 0) - 1), icon: const Icon(Icons.remove)),
                          Text('${_cart[name] ?? 0}'),
                          IconButton(onPressed: () => setState(() => _cart[name] = (_cart[name] ?? 0) + 1), icon: const Icon(Icons.add)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _cart.values.any((q) => q > 0) ? _checkout : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAD1457), foregroundColor: Colors.white),
              child: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _checkout() async {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      final rest = widget.restDoc.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> orderItems = [];
      _cart.forEach((name, qty) {
        if (qty > 0) {
          orderItems.add({'name': name, 'quantity': qty});
        }
      });

      await FirebaseFirestore.instance.collection('food_orders').add({
        'restaurantId': widget.restDoc.id,
        'restaurantName': rest['name'],
        'items': orderItems,
        'userId': user?.uid,
        'userName': user?.fullName,
        'status': 'pending',
        'type': widget.isDelivery ? 'delivery' : 'dine-in',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout error: $e')));
    }
  }
}
