import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/city_platform_provider.dart';
import '../../models/city_platform_models.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IntercitySystemScreen extends StatefulWidget {
  const IntercitySystemScreen({super.key});

  @override
  State<IntercitySystemScreen> createState() => _IntercitySystemScreenState();
}

class _IntercitySystemScreenState extends State<IntercitySystemScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CityPlatformProvider>().fetchIntercityRoutes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CityPlatformProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Terminals'),
        backgroundColor: Colors.green.shade800,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'old_terminal', label: Text('Old Terminal')),
                ButtonSegment(value: 'new_terminal', label: Text('New Terminal')),
              ],
              selected: {provider.selectedTerminalId},
              onSelectionChanged: (val) {
                provider.selectTerminal(val.first);
                provider.fetchIntercityRoutes();
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.intercityRoutes.length,
              itemBuilder: (context, index) {
                final route = provider.intercityRoutes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Hawassa → ${route.destination}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Fare: ${route.fare} ETB\nNext Bus: ${route.schedule.first}'),
                    trailing: ElevatedButton(
                      onPressed: () => _showBookingDialog(context, route),
                      child: const Text('Book'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, IntercityRoute route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Confirm Booking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Route: Hawassa to ${route.destination}'),
            Text('Terminal: ${context.read<CityPlatformProvider>().selectedTerminalId == 'old_terminal' ? 'Old' : 'New'}'),
            const SizedBox(height: 24),
            const Text('Choose Seat:'),
            Wrap(
              spacing: 8,
              children: List.generate(4, (i) => ChoiceChip(label: Text('${i+1}'), selected: false, onSelected: (s){})),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _generateTicket(context, route);
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text('Pay ${route.fare} ETB via Telebirr'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateTicket(BuildContext context, IntercityRoute route) {
    final vCode = 'QR-${DateTime.now().millisecondsSinceEpoch}';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ticket Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: QrImageView(data: vCode, version: QrVersions.auto),
            ),
            const SizedBox(height: 12),
            Text('Code: $vCode'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Download'))],
      ),
    );
  }
}
