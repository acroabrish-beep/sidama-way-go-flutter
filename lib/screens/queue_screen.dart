import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final List<String> _areas = [
    'Menaharia', 'Piassa', 'Haik Dar', 'Tabor', 'Hawella Tula',
    'Addis Ketema', 'Gudumale', 'Misrak', 'Alamura', 'Hiteta', 'Dato'
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Taxi Queue Management'),
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Passenger View'),
              Tab(text: 'Driver View'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PassengerView(areas: _areas),
            _DriverView(areas: _areas),
          ],
        ),
      ),
    );
  }
}

class _PassengerView extends StatefulWidget {
  final List<String> areas;
  const _PassengerView({required this.areas});

  @override
  State<_PassengerView> createState() => _PassengerViewState();
}

class _PassengerViewState extends State<_PassengerView> {
  String? _selectedArea;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedArea,
            decoration: const InputDecoration(labelText: 'Filter by Area', border: OutlineInputBorder()),
            items: widget.areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (v) => setState(() => _selectedArea = v),
          ),
        ),
        if (_selectedArea == null)
          const Expanded(child: Center(child: Text('Select an area to view the queue')))
        else
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('queues')
                  .where('area', isEqualTo: _selectedArea)
                  .where('status', isEqualTo: 'waiting')
                  .orderBy('joinTime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('${docs.length} taxis waiting in $_selectedArea',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF6A1B9A),
                                foregroundColor: Colors.white,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(data['plateNumber'] ?? 'Unknown'),
                              subtitle: const Text('Status: Waiting'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Request sent to driver')),
                                  );
                                },
                                child: const Text('Request'),
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
  final List<String> areas;
  const _DriverView({required this.areas});

  @override
  State<_DriverView> createState() => _DriverViewState();
}

class _DriverViewState extends State<_DriverView> {
  final _plateController = TextEditingController();
  String? _selectedArea;
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
          .where('driverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'waiting')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final isInQueue = docs.isNotEmpty;

        if (isInQueue) {
          final data = docs.first.data() as Map<String, dynamic>;
          final area = data['area'];
          final joinTime = data['joinTime'] as Timestamp;

          return _buildInQueueView(docs.first.id, area, joinTime);
        }

        return _buildJoinQueueForm();
      },
    );
  }

  Widget _buildJoinQueueForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Driver Queue Registration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _plateController,
            decoration: const InputDecoration(labelText: 'Plate Number (e.g. HW-34567)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedArea,
            decoration: const InputDecoration(labelText: 'Select Area', border: OutlineInputBorder()),
            items: widget.areas.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (v) => setState(() => _selectedArea = v),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _joinQueue,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('JOIN QUEUE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInQueueView(String docId, String area, Timestamp joinTime) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queues')
          .where('area', isEqualTo: area)
          .where('status', isEqualTo: 'waiting')
          .orderBy('joinTime')
          .snapshots(),
      builder: (context, snapshot) {
        int position = 0;
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
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
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text('Queue Position', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('$position', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                      const SizedBox(height: 8),
                      Text('Vehicles ahead: ${position > 0 ? position - 1 : "..."}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      const Divider(height: 32),
                      Text('Area: $area', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _leaveQueue(docId),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('LEAVE QUEUE'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _joinQueue() async {
    if (_plateController.text.isEmpty || _selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('queues').add({
        'driverId': user!.uid,
        'plateNumber': _plateController.text,
        'area': _selectedArea,
        'joinTime': FieldValue.serverTimestamp(),
        'status': 'waiting',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error joining queue: $e')));
    } finally {
      setState(() => _isLoading = false);
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
