import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Hawassa Map Placeholder for Web/Offline support
class HawassaMapPlaceholder extends StatelessWidget {
  final LatLng? userLocation;
  final Set<Marker> markers;
  final LatLng? destination;

  const HawassaMapPlaceholder({
    super.key,
    this.userLocation,
    required this.markers,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: Stack(
        children: [
          // Background - Stylized Map Grid/Pattern
          CustomPaint(
            painter: MapPatternPainter(),
            size: Size.infinite,
          ),

          // User Location Indicator
          if (userLocation != null)
            _PositionedMarker(
              location: userLocation!,
              color: Colors.blue,
              icon: Icons.person_pin_circle,
              label: 'You',
            ),

          // Route Simulation
          if (userLocation != null && destination != null)
            CustomPaint(
              painter: RoutePainter(
                start: userLocation!,
                end: destination!,
              ),
              size: Size.infinite,
            ),

          // Landmarks/Vehicles Markers
          ...markers.map((m) => _PositionedMarker(
                location: m.position,
                color: Colors.green,
                icon: Icons.location_on,
                label: m.infoWindow.title ?? '',
              )),

          // Destination Marker (if navigating)
          if (destination != null)
            _PositionedMarker(
              location: destination!,
              color: Colors.red,
              icon: Icons.flag,
              label: 'Destination',
            ),

          const Positioned(
            top: 10,
            right: 10,
            child: Chip(
              label: Text('Map Simulation', style: TextStyle(fontSize: 10)),
              backgroundColor: Colors.orangeAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionedMarker extends StatelessWidget {
  final LatLng location;
  final Color color;
  final IconData icon;
  final String label;

  const _PositionedMarker({
    required this.location,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Simple projection logic for placeholder (Hawassa focused)
    // Hawassa approx: 7.05, 38.48
    double x = (location.longitude - 38.45) * 5000 + 100;
    double y = (7.10 - location.latitude) * 5000 + 100;

    return Positioned(
      left: x % 400, // Wrap or clamp for visual safety
      top: y % 600,
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          if (label.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white70,
              child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePainter extends CustomPainter {
  final LatLng start;
  final LatLng end;

  RoutePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double x1 = (start.longitude - 38.45) * 5000 + 100;
    double y1 = (7.10 - start.latitude) * 5000 + 100;
    double x2 = (end.longitude - 38.45) * 5000 + 100;
    double y2 = (7.10 - end.latitude) * 5000 + 100;

    final path = Path();
    path.moveTo(x1 % 400 + 15, y1 % 600 + 15);
    path.lineTo(x2 % 400 + 15, y2 % 600 + 15);

    // Draw dashed line
    double dashWidth = 10.0;
    double dashSpace = 5.0;
    double distance = 0.0;
    for (PathMetric measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        canvas.drawPath(
          measurePath.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
