import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../maps/realtime_map_screen.dart';
import '../tourism/tourism_screen.dart';
import '../healthcare/healthcare_screen.dart';
import '../pharmacy/pharmacy_screen.dart';
import '../contract_ride/contract_ride_screen.dart';
import '../providers/language_provider.dart';
import '../providers/tracking_provider.dart';
import 'profile_screen.dart';
import 'bus_track_screen.dart';
import 'ai_assistant_screen.dart';
import 'admin_dashboard_screen.dart';
import 'government_fleet_screen.dart';
import 'public_transport_screen.dart';
import 'delivery_services_screen.dart';
import 'eco_shine_station_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomePage(),
    const PublicTransportScreen(),
    const RealtimeMapScreen(),
    const AiAssistantScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: lang.translate('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.directions_bus), label: lang.translate('transit')),
          BottomNavigationBarItem(icon: const Icon(Icons.map), label: lang.translate('explore')),
          BottomNavigationBarItem(icon: const Icon(Icons.assistant), label: lang.translate('ai_chat')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: lang.translate('profile')),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final lang = Provider.of<LanguageProvider>(context);

    final services = [
      {'icon': Icons.local_taxi, 'label': lang.translate('book_ride'), 'color': 0xFF2E7D32, 'page': const RealtimeMapScreen()},
      {'icon': Icons.map, 'label': 'Live Map', 'color': 0xFF1565C0, 'page': const MapScreen()},
      {'icon': Icons.directions_bus, 'label': lang.translate('public_transit'), 'color': 0xFF1B5E20, 'page': const PublicTransportScreen()},
      {'icon': Icons.delivery_dining, 'label': lang.translate('delivery'), 'color': 0xFFE65100, 'page': const DeliveryServicesScreen()},
      {'icon': Icons.local_car_wash, 'label': lang.translate('eco_shine'), 'color': 0xFF00695C, 'page': const EcoShineStationScreen()},
      {'icon': Icons.map, 'label': lang.translate('tourism'), 'color': 0xFF1565C0, 'page': const TourismScreen()},
      {'icon': Icons.local_hospital, 'label': lang.translate('healthcare'), 'color': 0xFFAD1457, 'page': const HealthcareScreen()},
      {'icon': Icons.dashboard, 'label': lang.translate('admin_dash'), 'color': 0xFF4527A0, 'page': const AdminDashboardScreen()},
      {'icon': Icons.airport_shuttle, 'label': lang.translate('gov_fleet'), 'color': 0xFF37474F, 'page': const GovernmentFleetScreen()},
      {'icon': Icons.assistant, 'label': lang.translate('ai_assistant'), 'color': 0xFF009688, 'page': const AiAssistantScreen()},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/app_logo.png',
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.auto_awesome);
            },
          ),
        ),
        title: Text(lang.translate('app_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<AppLanguage>(
            icon: const Icon(Icons.language),
            onSelected: (l) => lang.setLanguage(l),
            itemBuilder: (context) => [
              const PopupMenuItem(value: AppLanguage.english, child: Text('English')),
              const PopupMenuItem(value: AppLanguage.amharic, child: Text('አማርኛ')),
              const PopupMenuItem(value: AppLanguage.sidaamuAfoo, child: Text('Sidaamu Afoo')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${lang.translate('hello')}, ${user?.email?.split('@')[0] ?? 'User'}! 👋',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(lang.translate('welcome_msg'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(lang.translate('search_dest'), style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.translate('smart_city_hub'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => s['page'] as Widget)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4)
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(s['color'] as int).withOpacity(0.1),
                                  shape: BoxShape.circle
                                ),
                                child: Icon(s['icon'] as IconData, size: 28, color: Color(s['color'] as int)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s['label'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildEcoStatus(context, lang),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoStatus(BuildContext context, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00695C).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00695C).withOpacity(0.3))
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.translate('eco_status'), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(lang.translate('piazza_solar'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EcoShineStationScreen())),
            child: Text(lang.translate('view_status')),
          )
        ],
      ),
    );
  }
}
