import 'package:flutter/material.dart';
import '../widgets/dashboard_base.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class OldTerminalDashboard extends StatelessWidget {
  const OldTerminalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardBase(
      title: 'Old Terminal Admin',
      children: [
        _buildLiveStats(),
        const SizedBox(height: 24),
        _buildActionGrid(context),
        const SizedBox(height: 24),
        const Text(
          'Recent Bookings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildBookingList(),
      ],
    );
  }

  Widget _buildLiveStats() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('terminal', isEqualTo: 'Hawassa Old Terminal')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final bookings = snapshot.data!.docs;
        final todayBookings = bookings.where((doc) {
          final createdAt = (doc['createdAt'] as Timestamp?)?.toDate();
          return createdAt != null && createdAt.isAfter(todayStart);
        }).toList();

        double revenue = 0;
        for (var doc in bookings) {
          revenue += (doc['fare'] ?? 0).toDouble();
        }

        return Row(
          children: [
            Expanded(child: _buildStatCard('Today\'s Bookings', todayBookings.length.toString(), Icons.confirmation_number, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Total Revenue', '${revenue.toInt()} ETB', Icons.account_balance_wallet, Colors.blue)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    const oldTerminalMeta = {'terminal': 'Hawassa Old Terminal'};
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActionButton(Icons.add_road, 'Routes', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CRUDListScreen(collection: 'terminal_routes', title: 'Routes', fields: ['route', 'origin', 'destination', 'fare'], initialData: oldTerminalMeta)))),
        _buildActionButton(Icons.bus_alert, 'Vehicles', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CRUDListScreen(collection: 'vehicles', title: 'Vehicles', fields: ['plateNumber', 'type', 'capacity'], initialData: oldTerminalMeta)))),
        _buildActionButton(Icons.person_add, 'Drivers', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CRUDListScreen(collection: 'drivers', title: 'Drivers', fields: ['name', 'phone', 'licenseNumber'], initialData: oldTerminalMeta)))),
        _buildActionButton(Icons.event_note, 'Schedules', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CRUDListScreen(collection: 'schedules', title: 'Schedules', fields: ['route', 'busNumber', 'departureTime', 'status'], initialData: oldTerminalMeta)))),
        _buildActionButton(Icons.qr_code_scanner, 'Verify QR', () => _openScanner(context)),
        _buildActionButton(Icons.campaign, 'Alerts', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CRUDListScreen(collection: 'announcements', title: 'Announcements', fields: ['title', 'message', 'category'], initialData: {'category': 'Traffic'})))),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings')
          .where('terminal', isEqualTo: 'Hawassa Old Terminal')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading bookings', style: TextStyle(color: Colors.white)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No bookings found', style: TextStyle(color: Colors.white70)));

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'confirmed';
            return GlassCard(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['route']?.toString() ?? 'Unknown Route', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Passenger: ${data['passengerName']}\nTicket: ${data['ticketId']}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                trailing: Chip(
                  label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                  backgroundColor: status == 'verified' ? Colors.green : Colors.blue,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _openScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Verify Ticket QR')),
          body: MobileScanner(
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  // Assuming the QR code data is the ticketId or a map containing it
                  String ticketId = code;
                  if (code.contains('ticketId')) {
                    // It's a map string, try to parse or just search for TK-
                    final match = RegExp(r'TK-\d+').firstMatch(code);
                    if (match != null) ticketId = match.group(0)!;
                  }

                  final query = await FirebaseFirestore.instance
                      .collection('bookings')
                      .where('ticketId', isEqualTo: ticketId)
                      .limit(1)
                      .get();

                  if (query.docs.isNotEmpty) {
                    await query.docs.first.reference.update({'status': 'verified'});
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ticket Verified Successfully!'), backgroundColor: Colors.green),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid Ticket!'), backgroundColor: Colors.red),
                      );
                    }
                  }
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
