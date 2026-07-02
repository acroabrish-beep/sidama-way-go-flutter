import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../utils/firestore_utils.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Taxi Queue System'),
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Passenger View'),
              Tab(text: 'Driver View'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PassengerView(),
            _DriverView(),
          ],
        ),
      ),
    );
  }
}

class _PassengerView extends StatefulWidget {
  const _PassengerView();

  @override
  State<_PassengerView> createState() => _PassengerViewState();
}

class _PassengerViewState extends State<_PassengerView> {
  String? _expandedStation;
  final List<String> _stations = ['Piassa', 'Menaharia', 'Tabor', 'Gudumale', 'Addis Ketema', 'Haik Dar', 'Hawella Tula', 'Misrak', 'Alamura', 'Hiteta', 'Dato'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stations.length,
      itemBuilder: (context, index) {
        final stationName = _stations[index];
        final isExpanded = _expandedStation == stationName;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: isExpanded ? 4 : 1,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpanded ? const Color(0xFF1B5E20) : Colors.orange.withOpacity(0.1),
                  child: Icon(Icons.place, color: isExpanded ? Colors.white : Colors.orange),
                ),
                title: Text(stationName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('queues')
                      .where('station', isEqualTo: stationName)
                      .snapshots(),
                  builder: (context, qSnapshot) {
                    final waitingTaxis = qSnapshot.data?.docs
                        .where((doc) => (doc.data() as Map)['status'] == 'waiting')
                        .toList() ?? [];
                    return Text('${waitingTaxis.length} taxis waiting');
                  },
                ),
                trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onTap: () {
                  setState(() {
                    _expandedStation = isExpanded ? null : stationName;
                  });
                },
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('queues')
                        .where('station', isEqualTo: stationName)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final taxis = snapshot.data!.docs
                          .where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['status'] == 'waiting';
                          })
                          .toList();

                      // Sort by joinTime in Dart
                      taxis.sort((a, b) {
                        final aTime = FirestoreUtils.parseDateTime((a.data() as Map)['joinTime']) ?? DateTime.now();
                        final bTime = FirestoreUtils.parseDateTime((b.data() as Map)['joinTime']) ?? DateTime.now();
                        return aTime.compareTo(bTime);
                      });

                      if (taxis.isEmpty) {
                        return const Text('No taxis available at this station', style: TextStyle(color: Colors.grey));
                      }

                      return Column(
                        children: [
                          const Divider(),
                          ...taxis.asMap().entries.map((entry) {
                            final data = entry.value.data() as Map<String, dynamic>;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange,
                                radius: 15,
                                child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                              ),
                              title: Text(data['plateNumber'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(data['driverName'] ?? 'Driver'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Book this taxi
                                  FirebaseFirestore.instance.collection('taxi_requests').add({
                                    'plateNumber': data['plateNumber'],
                                    'driverName': data['driverName'],
                                    'pickup': stationName,
                                    'passengerId': FirebaseAuth.instance.currentUser?.uid ?? '',
                                    'status': 'pending',
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                                  // Update taxi status to in_progress
                                  entry.value.reference.update({'status': 'in_progress'});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Taxi booked! ${data['plateNumber']} is coming to $stationName'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                child: const Text('Book', style: TextStyle(color: Colors.white)),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DriverView extends StatefulWidget {
  const _DriverView();

  @override
  State<_DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends State<_DriverView> {
  final _plateController = TextEditingController();
  String? _selectedStation;
  bool _isLoading = false;
  final List<String> _stations = ['Piassa', 'Menaharia', 'Tabor', 'Gudumale', 'Addis Ketema', 'Haik Dar', 'Hawella Tula', 'Misrak', 'Alamura', 'Hiteta', 'Dato'];

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _addDemoTaxis() async {
    final demoTaxis = [
      {'plateNumber': 'HW-34567', 'driverName': 'Kebede Alemu', 'station': 'Piassa', 'status': 'waiting', 'vehicleType': 'City Taxi'},
      {'plateNumber': 'HW-12345', 'driverName': 'Tadesse Bekele', 'station': 'Piassa', 'status': 'waiting', 'vehicleType': 'City Taxi'},
      {'plateNumber': 'HW-99888', 'driverName': 'Hailu Dawit', 'station': 'Menaharia', 'status': 'waiting', 'vehicleType': 'City Taxi'},
      {'plateNumber': 'HW-55432', 'driverName': 'Sara Tekle', 'station': 'Tabor', 'status': 'waiting', 'vehicleType': 'Bajaj'},
      {'plateNumber': 'HW-77654', 'driverName': 'Abebe Girma', 'station': 'Gudumale', 'status': 'waiting', 'vehicleType': 'City Taxi'},
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final taxi in demoTaxis) {
      final ref = FirebaseFirestore.instance.collection('queues').doc();
      batch.set(ref, {
        ...taxi,
        'userId': '',
        'joinTime': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo taxis added to stations!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please login to join queue'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.email == 'acroabrish@gmail.com')
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: _addDemoTaxis,
                icon: const Icon(Icons.add),
                label: const Text('Add Demo Taxis (Admin)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
            ),

          _buildJoinQueueForm(),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Your Active Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('queues')
                .where('userId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final activeQueues = snapshot.data!.docs.where((doc) => (doc.data() as Map)['status'] == 'waiting').toList();

              if (activeQueues.isEmpty) {
                return const Text('You are not in any queue currently.', style: TextStyle(color: Colors.grey));
              }

              return Column(
                children: activeQueues.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    color: Colors.green.shade50,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.green.shade200)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Station: ${data['station']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Chip(label: Text('Waiting', style: TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Plate: ${data['plateNumber']}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _leaveQueue(doc.id),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                              child: const Text('Leave Queue'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJoinQueueForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Join Driver Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
        const SizedBox(height: 16),
        TextField(
          controller: _plateController,
          decoration: const InputDecoration(
            labelText: 'Taxi Plate Number',
            hintText: 'e.g. HW-34567',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedStation,
          decoration: const InputDecoration(
            labelText: 'Select Station',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.place),
          ),
          items: _stations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedStation = v),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_isLoading || _selectedStation == null) ? null : _joinQueue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('JOIN QUEUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _joinQueue() async {
    final plate = _plateController.text.trim();
    if (plate.isEmpty || _selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;

      // Check if already in queue at this station
      final existing = await FirebaseFirestore.instance
          .collection('queues')
          .where('plateNumber', isEqualTo: plate)
          .where('station', isEqualTo: _selectedStation)
          .where('status', isEqualTo: 'waiting')
          .get();

      if (existing.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are already in queue at $_selectedStation'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      await FirebaseFirestore.instance.collection('queues').add({
        'userId': user!.uid,
        'plateNumber': plate,
        'station': _selectedStation,
        'joinTime': FieldValue.serverTimestamp(),
        'status': 'waiting',
        'driverName': user.displayName ?? "Driver"
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined queue at $_selectedStation! You will be called when it\'s your turn.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error joining queue: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveQueue(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('queues').doc(docId).update({'status': 'left'});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error leaving queue: $e')));
    }
  }
}
