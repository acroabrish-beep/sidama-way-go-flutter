import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';

class TourismDashboard extends StatefulWidget {
  const TourismDashboard({super.key});

  @override
  State<TourismDashboard> createState() => _TourismDashboardState();
}

class _TourismDashboardState extends State<TourismDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tourism Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.tealAccent,
          labelColor: Colors.tealAccent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.landscape), text: 'Attractions'),
            Tab(icon: Icon(Icons.hotel), text: 'Hotels'),
            Tab(icon: Icon(Icons.restaurant), text: 'Restaurants'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
            Tab(icon: Icon(Icons.photo_library), text: 'Gallery'),
            Tab(icon: Icon(Icons.rate_review), text: 'Reviews'),
            Tab(icon: Icon(Icons.notifications_active), text: 'Alerts'),
            Tab(icon: Icon(Icons.emergency), text: 'Emergency'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004D40), Color(0xFF00796B)],
          ),
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(),
              _AttractionsTab(),
              _HotelsTab(),
              _RestaurantsTab(),
              _EventsTab(),
              _GalleryTab(),
              _ReviewsTab(),
              _AlertsTab(),
              _EmergencyTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatGrid(),
        const SizedBox(height: 24),
        const Text('Visitor Analytics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildAnalyticsChart(),
        const SizedBox(height: 24),
        const Text('Popular Destinations', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildPopularSitesList(),
      ],
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _statCard('Sites', 'tourism_sites', Icons.landscape, Colors.tealAccent),
        _statCard('Hotels', 'hotels', Icons.hotel, Colors.blueAccent),
        _statCard('Restaurants', 'restaurants', Icons.restaurant, Colors.orangeAccent),
        _statCard('Events', 'tourism_events', Icons.event, Colors.purpleAccent),
        _statCard('Monthly Visitors', 'tourism_analytics', Icons.people, Colors.greenAccent, valueOverride: '12.4k'),
        _statCard('Total Reviews', 'reviews', Icons.rate_review, Colors.yellowAccent),
      ],
    );
  }

  Widget _statCard(String label, String collection, IconData icon, Color color, {String? valueOverride}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String val = valueOverride ?? (snapshot.hasData ? snapshot.data!.docs.length.toString() : '...');
        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsChart() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2),
                FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 4),
              ],
              isCurved: true,
              color: Colors.tealAccent,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.tealAccent.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSitesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tourism_sites').limit(3).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(data['imageUrl'] ?? 'https://via.placeholder.com/150')),
                  title: Text(data['name'] ?? 'Dest', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${data['category']} • 4.8 ⭐', style: const TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.trending_up, color: Colors.greenAccent),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _AttractionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildCRUDView(
      context,
      'tourism_sites',
      'Attractions',
      ['name', 'category', 'location', 'openingHours', 'entryFee', 'description', 'imageUrl', 'featured'],
      Icons.add_location_alt,
    );
  }
}

Widget _buildCRUDView(BuildContext context, String collection, String title, List<String> fields, IconData addIcon) {
  return Stack(
    children: [
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error', style: TextStyle(color: Colors.white)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No data found.', style: TextStyle(color: Colors.white70)));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final data = docs[i].data() as Map<String, dynamic>? ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: ListTile(
                      title: Text(data[fields.first]?.toString() ?? 'Unnamed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(data[fields[1]]?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields))),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => docs[i].reference.delete(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
        },
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields))),
          backgroundColor: Colors.tealAccent,
          child: Icon(addIcon, color: Colors.teal),
        ),
      ),
    ],
  );
}

class _HotelsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildCRUDView(
      context,
      'hotels',
      'Hotels',
      ['name', 'location', 'priceRange', 'rating', 'contactNumber', 'website', 'description', 'imageUrl'],
      Icons.add_business,
    );
  }
}

class _RestaurantsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildCRUDView(
      context,
      'restaurants',
      'Restaurants',
      ['name', 'foodType', 'location', 'openingHours', 'rating', 'contactNumber', 'description', 'imageUrl'],
      Icons.restaurant_menu,
    );
  }
}

class _EventsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildCRUDView(
      context,
      'tourism_events',
      'Events',
      ['name', 'eventType', 'date', 'time', 'venue', 'ticketInfo', 'description', 'imageUrl'],
      Icons.event_available,
    );
  }
}

class _GalleryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: List.generate(9, (index) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(image: NetworkImage('https://via.placeholder.com/150'), fit: BoxFit.cover),
        ),
        child: const Icon(Icons.play_circle_fill, color: Colors.white70),
      )),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: ListTile(
                  title: Text(data['userName'] ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: List.generate(5, (star) => Icon(Icons.star, size: 12, color: star < (data['rating'] ?? 0) ? Colors.amber : Colors.grey))),
                      Text(data['comment'] ?? '', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'approve', child: Text('Approve')),
                      const PopupMenuItem(value: 'hide', child: Text('Hide')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (val) {
                      if (val == 'delete') snapshot.data!.docs[i].reference.delete();
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AlertsTab extends StatefulWidget {
  @override
  State<_AlertsTab> createState() => _AlertsTabState();
}

class _AlertsTabState extends State<_AlertsTab> {
  final _msgController = TextEditingController();
  String _type = 'Tourism News';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text('Send Tourism Broadcast', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _type,
            dropdownColor: const Color(0xFF004D40),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Alert Type', labelStyle: TextStyle(color: Colors.tealAccent)),
            items: ['Tourism News', 'Event Announcement', 'Festival Alert', 'Emergency Notice']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _msgController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Message Content',
              labelStyle: TextStyle(color: Colors.tealAccent),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('announcements').add({
                  'title': _type,
                  'message': _msgController.text,
                  'category': 'Tourism',
                  'timestamp': FieldValue.serverTimestamp(),
                  'isActive': true,
                });
                _msgController.clear();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Broadcast sent!')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
              child: const Text('SEND NOTIFICATION'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildCRUDView(
      context,
      'emergency_contacts',
      'Emergency Contacts',
      ['name', 'type', 'phone', 'location', 'description'],
      Icons.add_alert,
    );
  }
}

// Extension to allow sub-tabs to use common logic - REMOVED duplicated logic
