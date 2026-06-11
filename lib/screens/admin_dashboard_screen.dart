import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vehicle_registration_screen.dart';
import 'driver_registration_screen.dart';
import 'admin_location_dashboard.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
              Tab(icon: Icon(Icons.directions_car), text: 'Vehicles'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminLocationDashboard(),
            _TerminalsTab(),
            _CityTaxiTab(),
            _VehiclesTab(),
          ],
        ),
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
          stream: FirebaseFirestore.instance.collection('bookings').orderBy('timestamp', descending: true).limit(10).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(data['passengerName'] ?? 'No Name'),
                    subtitle: Text('${data['route']} - ${data['fare']} ETB'),
                    trailing: Chip(label: Text(data['status'] ?? 'Confirmed')),
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
        _simpleStat('Total Taxi Bookings', 'taxi_bookings'),
        _simpleStat('Drivers in Queue', 'queues', whereField: 'status', whereValue: 'waiting'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('Recent Taxi Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('taxi_bookings').orderBy('timestamp', descending: true).limit(10).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snapshot.data!.docs;
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text('Destination: ${data['destination']}'),
                    subtitle: Text('Fare: ${data['fare']} ETB | ${data['paymentMethod']}'),
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
