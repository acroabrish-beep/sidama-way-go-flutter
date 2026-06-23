import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../widgets/glass_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _toggleUserStatus(String uid, bool currentStatus) async {
    await _db.collection('users').doc(uid).update({'isActive': !currentStatus});
  }

  void _changeRole(String uid, UserRole newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole.name});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final userData = doc.data() as Map<String, dynamic>;
              final user = UserModel.fromMap(userData, doc.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(user.fullName),
                  subtitle: Text('${user.email}\nRole: ${user.role.name}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(user.isActive ? Icons.check_circle : Icons.block, color: user.isActive ? Colors.green : Colors.red),
                        onPressed: () => _toggleUserStatus(user.uid, user.isActive),
                      ),
                      PopupMenuButton<UserRole>(
                        onSelected: (role) => _changeRole(user.uid, role),
                        itemBuilder: (context) => UserRole.values.map((role) => PopupMenuItem(
                          value: role,
                          child: Text(role.name),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
