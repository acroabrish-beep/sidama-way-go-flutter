import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/city_platform_models.dart';
import '../services/city_platform_service.dart';

class CityPlatformProvider with ChangeNotifier {
  final CityPlatformService _service = CityPlatformService();

  // Selected Terminal
  String _selectedTerminalId = 'old_terminal';
  String get selectedTerminalId => _selectedTerminalId;

  void selectTerminal(String id) {
    _selectedTerminalId = id;
    notifyListeners();
  }

  // Intercity Routes
  List<IntercityRoute> _intercityRoutes = [];
  List<IntercityRoute> get intercityRoutes => _intercityRoutes;

  void fetchIntercityRoutes() {
    _service.getIntercityRoutes(_selectedTerminalId).listen((routes) {
      _intercityRoutes = routes;
      notifyListeners();
    });
  }

  // Emergency
  Future<void> triggerEmergency(String type, GeoPoint location) async {
    await _service.sendEmergencyAlert(type, location);
  }

  // Announcements
  List<Announcement> _announcements = [];
  List<Announcement> get announcements => _announcements;

  void fetchAnnouncements() {
    _service.getAnnouncements().listen((list) {
      _announcements = list;
      notifyListeners();
    });
  }
}
