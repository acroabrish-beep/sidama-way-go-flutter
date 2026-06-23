import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_notifications')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No new notifications'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final isRead = d['isRead'] ?? false;
              final ts = (d['createdAt'] as Timestamp?)?.toDate();

              return Card(
                color: isRead ? Colors.white : Colors.green[50],
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    _getIcon(d['type']),
                    color: isRead ? Colors.grey : const Color(0xFF2E7D32),
                  ),
                  title: Text(d['title'] ?? '', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['message'] ?? ''),
                      const SizedBox(height: 4),
                      Text(ts != null ? DateFormat('dd MMM, HH:mm').format(ts) : '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  onTap: () {
                    if (!isRead) {
                      docs[i].reference.update({'isRead': true});
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'emergency': return Icons.emergency;
      case 'bus': return Icons.directions_bus;
      case 'taxi': return Icons.local_taxi;
      case 'hotel': return Icons.hotel;
      case 'food': return Icons.restaurant;
      default: return Icons.notifications;
    }
  }
}
