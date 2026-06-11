import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/extended_platform_provider.dart';
import '../../models/extended_city_models.dart';
import '../../services/extended_platform_service.dart';

class FoodDeliveryScreen extends StatefulWidget {
  const FoodDeliveryScreen({super.key});

  @override
  State<FoodDeliveryScreen> createState() => _FoodDeliveryScreenState();
}

class _FoodDeliveryScreenState extends State<FoodDeliveryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExtendedPlatformProvider>().fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = context.watch<ExtendedPlatformProvider>().restaurants;

    return Scaffold(
      appBar: AppBar(title: const Text('Food Delivery')),
      body: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundImage: NetworkImage(restaurant.logo)),
              title: Text(restaurant.name),
              subtitle: Text(restaurant.address),
              onTap: () => _viewMenu(context, restaurant),
            ),
          );
        },
      ),
    );
  }

  void _viewMenu(BuildContext context, Restaurant restaurant) async {
    final menu = await ExtendedPlatformService().getRestaurantMenu(restaurant.id);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(restaurant.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: menu.length,
                itemBuilder: (context, i) {
                  final item = menu[i];
                  return ListTile(
                    leading: Image.network(item.photo, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    trailing: Text('${item.price} ETB'),
                    onTap: () => _addToCart(context, restaurant.id, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, String restaurantId, FoodMenuItem item) async {
    // Simplified order flow
    await ExtendedPlatformService().placeFoodOrder(restaurantId, [{'name': item.name, 'price': item.price, 'qty': 1}], item.price);
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Placed Successfully!')));
  }
}
