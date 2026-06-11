import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'terminal_screen.dart';
import 'city_taxi_screen.dart';
import 'queue_screen.dart';
import 'emergency_screen.dart';
import 'admin_dashboard_screen.dart';
import 'map_screen.dart';
import 'tourist_screen.dart';
import 'healthcare_screen.dart';
import 'pharmacy_screen.dart';
import 'food_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _MainHub(),
    const TerminalScreen(),
    const MapScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Terminal'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
        backgroundColor: Colors.red,
        tooltip: 'Emergency',
        child: const Icon(Icons.emergency, color: Colors.white),
      ),
    );
  }
}

class _MainHub extends StatelessWidget {
  const _MainHub();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final lang = Provider.of<LanguageProvider>(context);

    final List<Map<String, dynamic>> services = [
      {'title': 'Bus Terminal', 'icon': Icons.directions_bus_filled, 'color': 0xFF1565C0, 'screen': const TerminalScreen()},
      {'title': 'City Taxi', 'icon': Icons.local_taxi, 'color': 0xFFE65100, 'screen': const CityTaxiScreen()},
      {'title': 'Taxi Queue', 'icon': Icons.queue, 'color': 0xFF6A1B9A, 'screen': const QueueScreen()},
      {'title': 'Emergency', 'icon': Icons.emergency, 'color': 0xFFC62828, 'screen': const EmergencyScreen()},
      {'title': 'Tourist Guide', 'icon': Icons.map, 'color': 0xFF00897B, 'screen': const TouristScreen()},
      {'title': 'Healthcare', 'icon': Icons.local_hospital, 'color': 0xFFD32F2F, 'screen': const HealthcareScreen()},
      {'title': 'Pharmacy', 'icon': Icons.local_pharmacy, 'color': 0xFF388E3C, 'screen': const PharmacyScreen()},
      {'title': 'Food Delivery', 'icon': Icons.restaurant, 'color': 0xFFF57C00, 'screen': const FoodScreen()},
      {'title': 'Wallet', 'icon': Icons.account_balance_wallet, 'color': 0xFF4527A0, 'screen': const WalletScreen()},
      {'title': 'Admin', 'icon': Icons.admin_panel_settings, 'color': 0xFF37474F, 'screen': const AdminDashboardScreen()},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.email?.split('@')[0] ?? 'Citizen'}! 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Hawassa Smart City Mobility',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('City Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => s['screen'])),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(s['color']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(s['icon'], color: Color(s['color']), size: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s['title'],
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _announcementCard(
                    'Bus Service Update',
                    'New routes added to the New Terminal for Bahir Dar and Jimma.',
                    Colors.blue,
                  ),
                  _announcementCard(
                    'Health Notice',
                    'Vaccination drive starting Monday at Hawassa Referral Hospital.',
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(String title, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.campaign, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}
