import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_ride_screen.dart';
import 'bus_track_screen.dart';
import 'food_screen.dart';
import 'profile_screen.dart';
import 'tourist_screen.dart';
import 'wallet_screen.dart';
import 'driver_panel_screen.dart';
import 'eco_shine_screen.dart';
import 'delivery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomePage(),
    const BusTrackScreen(),
    const FoodScreen(),
    const TouristScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Bus'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Food'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Tourist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final services = [
      {'icon': Icons.local_taxi, 'label': 'Book Ride', 'color': 0xFF2E7D32, 'screen': const BookRideScreen()},
      {'icon': Icons.directions_bus, 'label': 'Bus Track', 'color': 0xFF1565C0, 'screen': const BusTrackScreen()},
      {'icon': Icons.restaurant, 'label': 'Food', 'color': 0xFFAD1457, 'screen': const FoodScreen()},
      {'icon': Icons.map, 'label': 'Tourist Guide', 'color': 0xFF009688, 'screen': const TouristScreen()},
      {'icon': Icons.drive_eta, 'label': 'Driver Panel', 'color': 0xFF673AB7, 'screen': const DriverPanelScreen()},
      {'icon': Icons.local_car_wash, 'label': 'Eco-Shine', 'color': 0xFF00695C, 'screen': const EcoShineScreen()},
      {'icon': Icons.delivery_dining, 'label': 'Delivery', 'color': 0xFFE65100, 'screen': const DeliveryScreen()},
      {'icon': Icons.account_balance_wallet, 'label': 'Wallet', 'color': 0xFF4527A0, 'screen': const WalletScreen()},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📍 Hawassa, Sidama', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                'Hello, ${user?.email?.split('@')[0] ?? 'User'}! 👋',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _headerBadge('🗺️ Tourist', Colors.white.withOpacity(0.2)),
                              const SizedBox(width: 8),
                              _headerBadge('🚨 SOS', Colors.red),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Search destination (Piassa, University...)',
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text('Sidama Way Go', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => s['screen'] as Widget)),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(s['color'] as int).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(s['icon'] as IconData, color: Color(s['color'] as int), size: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(s['label'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Choose Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _rideQuickCard(context, 'Motor', Icons.motorcycle, Colors.orange),
                      _rideQuickCard(context, 'Bajaj', Icons.electric_rickshaw, Colors.blue),
                      _rideQuickCard(context, 'Car', Icons.directions_car, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Recent Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _tripCard('Piassa → Stadium', 'Bajaj • 40 ETB', '10 min ago', Icons.electric_rickshaw, 0xFFE65100),
                  _tripCard('Adebabay → University', 'Taxi • 120 ETB', 'Yesterday', Icons.local_taxi, 0xFF2E7D32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _rideQuickCard(BuildContext context, String name, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookRideScreen())),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tripCard(String route, String detail, String time, IconData icon, int color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Color(color).withOpacity(0.1), child: Icon(icon, color: Color(color))),
        title: Text(route, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(detail),
        trailing: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    );
  }
}
