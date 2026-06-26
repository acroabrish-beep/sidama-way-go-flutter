import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  String? _selectedStation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Station Selector Grid
        Container(
          padding: const EdgeInsets.all(12),
          height: 130, // Increased height to prevent overflow
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('taxi_stations').where('isActive', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final stations = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final stationData = stations[index].data() as Map<String, dynamic>;
                  final stationName = stationData['name'] ?? 'Unknown';
                  final isSelected = _selectedStation == stationName;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedStation = stationName),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1B5E20) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? const Color(0xFF1B5E20) : Colors.grey.shade300),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              stationName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('queues')
                                  .where('station', isEqualTo: stationName)
                                  .snapshots(),
                              builder: (context, qSnapshot) {
                                // Filter in Dart to avoid index requirement
                                final waitingTaxis = qSnapshot.data?.docs.where((doc) => doc.data() is Map && (doc.data() as Map)['status'] == 'waiting').toList() ?? [];
                                final count = waitingTaxis.length;

                                return Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.local_taxi, size: 14, color: isSelected ? Colors.white70 : Colors.green),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '$count taxis waiting',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isSelected ? Colors.white70 : Colors.grey[600]
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          ),
        ),
        const Divider(),
        if (_selectedStation == null)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Select a station to see available taxis', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('queues')
                  .where('station', isEqualTo: _selectedStation)
                  .orderBy('joinTime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                // Filter in Dart to avoid index requirement
                final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map)['status'] == 'waiting').toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline, size: 64, color: Colors.orange),
                          const SizedBox(height: 16),
                          Text(
                            'No taxis currently at $_selectedStation — check another station',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Text(
                        '${docs.length} taxis waiting at $_selectedStation',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final joinTime = data['joinTime'] as Timestamp?;
                          String timeAgo = 'Just now';
                          if (joinTime != null) {
                            final diff = DateTime.now().difference(joinTime.toDate());
                            if (diff.inMinutes < 60) {
                              timeAgo = '${diff.inMinutes} min ago';
                            } else {
                              timeAgo = DateFormat('hh:mm a').format(joinTime.toDate());
                            }
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1B5E20),
                                foregroundColor: Colors.white,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(data['plateNumber'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Joined: $timeAgo'),
                              trailing: const Chip(
                                label: Text('Waiting', style: TextStyle(fontSize: 10, color: Colors.white)),
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
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

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('Please login to join queue'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        // Filter in Dart
        final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map)['status'] == 'waiting').toList();

        if (docs.isNotEmpty) {
          final doc = docs.first;
          final data = doc.data() as Map<String, dynamic>;
          return _buildInQueueView(doc.id, data['station'], data['joinTime'] as Timestamp?);
        }

        return _buildJoinQueueForm();
      },
    );
  }

  Widget _buildJoinQueueForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Join Driver Queue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 24),
          TextField(
            controller: _plateController,
            decoration: const InputDecoration(
              labelText: 'Taxi Plate Number',
              hintText: 'e.g. HW-34567',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('taxi_stations').where('isActive', isEqualTo: true).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              final stations = snapshot.data?.docs ?? [];
              if (stations.isEmpty) {
                return const Text('No stations configured. Please contact admin.', style: TextStyle(color: Colors.red));
              }

              return DropdownButtonFormField<String>(
                initialValue: _selectedStation,
                decoration: const InputDecoration(
                  labelText: 'Select Station',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
                items: stations.map((s) {
                  final name = s['name'] as String;
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: (v) => setState(() => _selectedStation = v),
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
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
      ),
    );
  }

  Widget _buildInQueueView(String docId, String station, Timestamp? joinTime) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('station', isEqualTo: station)
          .orderBy('joinTime')
          .snapshots(),
      builder: (context, snapshot) {
        int position = 0;
        if (snapshot.hasData) {
          // Filter in Dart
          final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map)['status'] == 'waiting').toList();
          for (int i = 0; i < docs.length; i++) {
            if (docs[i].id == docId) {
              position = i + 1;
              break;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text('Current Station: $station', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(height: 40),
                      const Text('Your Position', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Text(position > 0 ? '$position' : '...',
                        style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))
                      ),
                      const SizedBox(height: 12),
                      Text(position > 1 ? '${position - 1} taxis ahead of you' : (position == 1 ? 'You are next!' : 'Calculating...'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => _leaveQueue(docId),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('LEAVE QUEUE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _joinQueue() async {
    if (_plateController.text.isEmpty || _selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('queues').add({
        'userId': user!.uid,
        'plateNumber': _plateController.text,
        'station': _selectedStation,
        'joinTime': FieldValue.serverTimestamp(),
        'status': 'waiting',
        'driverName': user.displayName ?? ""
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error joining queue: $e')));
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
