import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vehicle_registration_screen.dart';
import 'mobility/driver_registration_screen.dart';
import 'admin_location_dashboard.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('City Admin Dashboard'),
          backgroundColor: const Color(0xFF37474F),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.location_on), text: 'Live Map'),
              Tab(icon: Icon(Icons.business), text: 'Terminals'),
              Tab(icon: Icon(Icons.local_taxi), text: 'City Taxi'),
              Tab(icon: Icon(Icons.place), text: 'Stations'),
              Tab(icon: Icon(Icons.directions_car), text: 'Vehicles'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminLocationDashboard(),
            _TerminalsTab(),
            _CityTaxiTab(),
            _TaxiStationsTab(),
            _VehiclesTab(),
          ],
        ),
      ),
    );
  }
}

class _TaxiStationsTab extends StatefulWidget {
  const _TaxiStationsTab();

  @override
  State<_TaxiStationsTab> createState() => _TaxiStationsTabState();
}

class _TaxiStationsTabState extends State<_TaxiStationsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _capacityController = TextEditingController();
  String _selectedZone = 'Zone 1';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _addStation() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('taxi_stations').add({
        'name': _nameController.text,
        'description': _descController.text,
        'zone': _selectedZone,
        'maxCapacity': int.tryParse(_capacityController.text) ?? 10,
        'isActive': true,
        'currentTaxis': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _nameController.clear();
      _descController.clear();
      _capacityController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Station added!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New Station', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Station Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Location Description'),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedZone,
                            decoration: const InputDecoration(labelText: 'Zone'),
                            items: ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4']
                                .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedZone = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _capacityController,
                            decoration: const InputDecoration(labelText: 'Max Capacity'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addStation,
                        child: const Text('Add Station'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Stations List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('taxi_stations').orderBy('name').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['description'] ?? ''),
                          Row(
                            children: [
                              Chip(label: Text(data['zone'] ?? '', style: const TextStyle(fontSize: 10))),
                              const SizedBox(width: 8),
                              Text('Cap: ${data['maxCapacity']}'),
                              const SizedBox(width: 8),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('queues').where('station', isEqualTo: data['name']).snapshots(),
                                builder: (context, qSnap) {
                                  // Filter in Dart
                                  final waiting = qSnap.data?.docs.where((d) => (d.data() as Map)['status'] == 'waiting').toList() ?? [];
                                  return Text('Taxis: ${waiting.length}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: data['isActive'] ?? false,
                            onChanged: (v) => doc.reference.update({'isActive': v}),
                          ),
                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editStation(doc)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteStation(doc)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _editStation(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nameC = TextEditingController(text: data['name']);
    final descC = TextEditingController(text: data['description']);
    final capC = TextEditingController(text: data['maxCapacity'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: descC, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: capC, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () async {
            await doc.reference.update({
              'name': nameC.text,
              'description': descC.text,
              'maxCapacity': int.tryParse(capC.text) ?? 10,
            });
            if (mounted) Navigator.pop(context);
          }, child: const Text('Save')),
        ],
      ),
    );
  }

  void _deleteStation(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Station'),
        content: const Text('Are you sure you want to delete this station?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () async {
            await doc.reference.delete();
            if (mounted) Navigator.pop(context);
          }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

class _TerminalsTab extends StatelessWidget {
  const _TerminalsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _statCard('Old Terminal Bookings', 'bookings', 'terminal', 'Hawassa Old Terminal'),
        _statCard('New Terminal Bookings', 'bookings', 'terminal', 'Hawassa New Terminal'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Recent Intercity Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).limit(10).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('Error loading data');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text('No recent bookings.');

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>? ?? {};
                final name = data['passengerName'] as String? ?? 'No Name';
                final route = data['route'] as String? ?? 'Unknown Route';
                final fare = data['fare'] as num? ?? 0;
                final status = data['status'] as String? ?? 'Confirmed';

                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('$route - $fare ETB'),
                    trailing: Chip(label: Text(status)),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _statCard(String label, String collection, String field, String value) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).where(field, isEqualTo: value).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$count', style: const TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CityTaxiTab extends StatelessWidget {
  const _CityTaxiTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _simpleStat('Total Taxi Requests', 'taxi_requests'),
        _simpleStat('Drivers in Queue', 'queues', whereField: 'status', whereValue: 'waiting'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Recent Taxi Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('taxi_requests').orderBy('timestamp', descending: true).limit(10).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('Error loading data');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return const Text('No recent requests.');

            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text('Destination: ${data['destination']}'),
                    subtitle: Text('Fare: ${data['fare']} ETB | Status: ${data['status']}'),
                    trailing: const Icon(Icons.local_taxi, color: Colors.orange),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _simpleStat(String label, String collection, {String? whereField, String? whereValue}) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (whereField != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$count', style: const TextStyle(fontSize: 24, color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VehiclesTab extends StatelessWidget {
  const _VehiclesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _totalCountCard('Registered Vehicles', 'vehicles')),
              const SizedBox(width: 12),
              Expanded(child: _totalCountCard('Total Drivers', 'drivers')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleRegistrationScreen())),
                  icon: const Icon(Icons.add),
                  label: const Text('New Vehicle'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverRegistrationScreen())),
                  icon: const Icon(Icons.person_add),
                  label: const Text('New Driver'),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Vehicle List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text(data['plateNumber']),
                      subtitle: Text('${data['type']} | ${data['driverName']}'),
                      trailing: Chip(label: Text(data['status'] ?? 'Active')),
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

  Widget _totalCountCard(String label, String collection) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Card(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('$count', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
        );
      },
    );
  }
}
