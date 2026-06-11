import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/extended_platform_provider.dart';
import '../../models/extended_city_models.dart';
import '../../services/extended_platform_service.dart';

class HotelBookingScreen extends StatefulWidget {
  const HotelBookingScreen({super.key});

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExtendedPlatformProvider>().fetchHotels();
  }

  @override
  Widget build(BuildContext context) {
    final hotels = context.watch<ExtendedPlatformProvider>().hotels;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Hotel & Guest House')),
      body: ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          return Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (hotel.photos.isNotEmpty)
                  Image.network(hotel.photos.first, height: 150, width: double.infinity, fit: BoxFit.cover),
                ListTile(
                  title: Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(hotel.address),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _viewRooms(context, hotel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _viewRooms(BuildContext context, Hotel hotel) async {
    final rooms = await ExtendedPlatformService().getHotelRooms(hotel.id);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(hotel.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, i) {
                  final room = rooms[i];
                  return ListTile(
                    title: Text(room.type),
                    subtitle: Text('${room.price} ETB / night'),
                    trailing: ElevatedButton(
                      onPressed: () => _confirmBooking(context, hotel.id, room),
                      child: const Text('Book Now'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBooking(BuildContext context, String hotelId, Room room) async {
    await ExtendedPlatformService().bookRoom(hotelId, room, DateTime.now(), DateTime.now().add(const Duration(days: 1)));
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reservation Confirmed! QR generated.')));
  }
}
