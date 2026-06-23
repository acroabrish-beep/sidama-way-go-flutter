import 'package:flutter/material.dart';
import '../widgets/dashboard_base.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TourismDashboard extends StatelessWidget {
  const TourismDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardBase(
      title: 'Tourism Admin',
      children: [
        _buildStats(),
        const SizedBox(height: 24),
        const Text(
          'Manage Destinations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildSitesList(),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CRUDListScreen(collection: 'tourism_sites', title: 'Tourism Sites', fields: ['name', 'category', 'description', 'imageUrl']))),
        backgroundColor: Colors.tealAccent,
        child: const Icon(Icons.add_location_alt, color: Colors.teal),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: _statCardStream('Total Sites', 'tourism_sites', Icons.landscape, Colors.greenAccent)),
        const SizedBox(width: 12),
        Expanded(child: _statCardStream('Total Views', 'tourism_views', Icons.visibility, Colors.orangeAccent)),
      ],
    );
  }

  Widget _statCardStream(String label, String collection, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        String value = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
        return _buildStatCard(label, value, icon, color);
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSitesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tourism_sites').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading sites', style: TextStyle(color: Colors.white)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No tourism sites found', style: TextStyle(color: Colors.white70)));

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final imgUrl = data['imageUrl']?.toString() ?? '';
            return GlassCard(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: imgUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imgUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[800],
                  ),
                  child: imgUrl.isEmpty ? const Icon(Icons.landscape, color: Colors.white24) : null,
                ),
                title: Text(data['name']?.toString() ?? 'Site Name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(data['category']?.toString() ?? 'Category', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: 'tourism_sites', title: 'Edit Site', fields: ['name', 'category', 'description', 'imageUrl']))),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => doc.reference.delete(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
