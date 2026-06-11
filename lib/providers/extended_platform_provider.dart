import 'package:flutter/material.dart';
import '../models/extended_city_models.dart';
import '../services/extended_platform_service.dart';

class ExtendedPlatformProvider with ChangeNotifier {
  final ExtendedPlatformService _service = ExtendedPlatformService();

  // Hotels
  List<Hotel> _hotels = [];
  List<Hotel> get hotels => _hotels;

  void fetchHotels() {
    _service.getHotels().listen((list) {
      _hotels = list;
      notifyListeners();
    });
  }

  // Restaurants
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  void fetchRestaurants() {
    _service.getRestaurants().listen((list) {
      _restaurants = list;
      notifyListeners();
    });
  }
}
