import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/smart_city_models.dart';
import '../services/smart_city_service.dart';

class SmartCityProvider with ChangeNotifier {
  final SmartCityService _service = SmartCityService();

  CityUser? _currentUser;
  CityUser? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUserData() async {
    _currentUser = await _service.getCurrentUser();
    notifyListeners();
  }

  // Intercity Bus State
  List<TerminalBus> _availableBuses = [];
  List<TerminalBus> get availableBuses => _availableBuses;

  void fetchBuses(String terminalId) {
    _service.getBuses(terminalId).listen((buses) {
      _availableBuses = buses;
      notifyListeners();
    });
  }

  Future<void> bookTicket(BusTerminalTicket ticket) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.bookBusTicket(ticket);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Emergency State
  Future<void> triggerSOS(String type, GeoPoint location) async {
    await _service.requestEmergency(type, location);
  }

  // Taxi Queue State
  Future<void> joinQueue(String taxiId, String plateNumber) async {
    await _service.joinTaxiQueue(taxiId, plateNumber);
  }
}
