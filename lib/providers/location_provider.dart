import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _service = LocationService();

  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  Position? get currentPosition => _currentPosition;
  Set<Marker> get markers => _markers;
  bool get isLoading => _isLoading;

  LocationProvider() {
    _init();
  }

  Future<void> _init() async {
    _currentPosition = await _service.getCurrentLocation();
    if (_currentPosition != null) {
      _service.startLiveTracking('user');
      _addMarker('user', LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 'My Location', BitmapDescriptor.hueAzure);
    }
    _isLoading = false;
    notifyListeners();
  }

  void _addMarker(String id, LatLng position, String title, double hue) {
    _markers.add(
      Marker(
        markerId: MarkerId(id),
        position: position,
        infoWindow: InfoWindow(title: title),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      ),
    );
  }

  void listenToCityLive() {
    _service.getAllCityLocations().listen((locations) {
      _markers.clear();
      if (_currentPosition != null) {
        _addMarker('user', LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 'My Location', BitmapDescriptor.hueAzure);
      }

      for (var loc in locations) {
        double hue = BitmapDescriptor.hueRed;
        String type = loc['type'] ?? 'unknown';

        if (type == 'taxi') hue = BitmapDescriptor.hueYellow;
        else if (type == 'bus') hue = BitmapDescriptor.hueBlue;
        else if (type == 'hotel') hue = BitmapDescriptor.hueGreen;
        else if (type == 'pharmacy') hue = BitmapDescriptor.hueMagenta;
        else if (type == 'hospital') hue = BitmapDescriptor.hueRed;
        else if (type == 'tourism') hue = BitmapDescriptor.hueOrange;

        _addMarker(
          loc['id'],
          LatLng(loc['latitude'], loc['longitude']),
          loc['name'] ?? type.toUpperCase(),
          hue
        );
      }
      notifyListeners();
    });
  }

  Future<void> updateStaticLocation(String type, String name, double lat, double lng) async {
    await _service.saveStaticLocation('${type}_locations', name, {
      'type': type,
      'name': name,
      'latitude': lat,
      'longitude': lng,
    });
    // Also save to global 'locations' for the main map
    await _service.saveStaticLocation('locations', name, {
      'type': type,
      'name': name,
      'latitude': lat,
      'longitude': lng,
    });
  }
}
