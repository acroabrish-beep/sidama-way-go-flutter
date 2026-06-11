import 'package:flutter/material.dart';
import '../../services/mobility_service.dart';
import '../../models/mobility_models.dart';

class TaxiQueueScreen extends StatelessWidget {
  const TaxiQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MobilityService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxi Queue Management'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<TaxiQueue>>(
        stream: service.getTaxiQueue(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final queue = snapshot.data!;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: Colors.blueGrey[900],
                child: Column(
                  children: [
                    const Text('Current Queue Active', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('${queue.length}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                    const Text('Vehicles Waiting', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final item = queue[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text('Taxi Number: ${item.plateNumber}'),
                      subtitle: Text('Joined: ${item.joinedAt}'),
                      trailing: const Icon(Icons.more_vert),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _joinQueue(context),
                  icon: const Icon(Icons.add),
                  label: const Text('JOIN QUEUE'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _joinQueue(BuildContext context) async {
    // Mock join queue logic
    await MobilityService().joinTaxiQueue('driver_123', 'HW-34567');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined queue at position 12')));
  }
}
