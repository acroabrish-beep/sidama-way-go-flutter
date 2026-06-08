import 'package:flutter/material.dart';

class GovernmentFleetScreen extends StatelessWidget {
  const GovernmentFleetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fleets = [
      {'name': 'City Bus #104', 'type': 'Bus', 'status': 'Active'},
      {'name': 'Ambulance #02', 'type': 'Emergency', 'status': 'Active'},
      {'name': 'Utility Truck #4', 'type': 'Utility', 'status': 'Maintenance'},
      {'name': 'City Bus #210', 'type': 'Bus', 'status': 'Idle'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Fleet'),
      ),
      body: ListView.builder(
        itemCount: fleets.length,
        itemBuilder: (context, index) {
          final fleet = fleets[index];
          Color statusColor = Colors.green;
          if (fleet['status'] == 'Maintenance') statusColor = Colors.orange;
          if (fleet['status'] == 'Idle') statusColor = Colors.grey;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                fleet['type'] == 'Bus' ? Icons.directions_bus :
                fleet['type'] == 'Emergency' ? Icons.medical_services : Icons.settings,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(fleet['name']!),
              subtitle: Text('Type: ${fleet['type']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fleet['status']!,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
