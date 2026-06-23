import 'package:flutter/material.dart';
import '../widgets/dashboard_base.dart';
import '../widgets/glass_card.dart';
import 'crud_list_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class NewTerminalDashboard extends StatelessWidget {
  const NewTerminalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardBase(
      title: 'New Terminal Admin',
      children: [
        _buildLiveStats(),
        const SizedBox(height: 24),
        const Text(
          'Core Routes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        _buildRouteChips(),
        const SizedBox(height: 24),
        _buildManagementGrid(context),
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
          .where('terminal', isEqualTo: 'Hawassa New Terminal')
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

  Widget _buildBookingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings')
          .where('terminal', isEqualTo: 'Hawassa New Terminal')
          .orderBy('createdAt', descending: true)
          .limit(10).snapshots(),
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

  Widget _buildRouteChips() {
    final routes = [
      'Aleta Wondo', 'Bensa', 'Bona', 'Hager Selam', 'Yirgalem', 'Bursa'
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: routes.map((r) => Chip(
        label: Text(r),
        backgroundColor: Colors.white24,
        labelStyle: const TextStyle(color: Colors.white),
      )).toList(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    const newTerminalMeta = {'terminal': 'Hawassa New Terminal'};
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildManageItem(context, 'Route CRUD', Icons.edit_road, 'terminal_routes', ['route', 'origin', 'destination', 'fare'], initialData: newTerminalMeta),
        _buildManageItem(context, 'Vehicle CRUD', Icons.directions_bus, 'vehicles', ['plateNumber', 'type', 'capacity'], initialData: newTerminalMeta),
        _buildManageItem(context, 'Driver CRUD', Icons.person, 'drivers', ['name', 'phone', 'licenseNumber'], initialData: newTerminalMeta),
        _buildManageItem(context, 'Verify Ticket', Icons.qr_code_scanner, '', []), // Special handling below
      ],
    );
  }

  Widget _buildManageItem(BuildContext context, String title, IconData icon, String collection, List<String> fields, {Map<String, dynamic>? initialData}) {
    return GestureDetector(
      onTap: () {
        if (title == 'Verify Ticket') {
          _openScanner(context);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CRUDListScreen(collection: collection, title: title, fields: fields, initialData: initialData)));
        }
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
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
                  String ticketId = code;
                  if (code.contains('ticketId')) {
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
