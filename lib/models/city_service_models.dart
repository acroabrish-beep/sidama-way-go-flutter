import 'package:cloud_firestore/cloud_firestore.dart';

class TourismSiteModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String history;
  final List<String> imageUrls;
  final String videoUrl;
  final GeoPoint location;

  TourismSiteModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.history,
    required this.imageUrls,
    required this.videoUrl,
    required this.location,
  });

  factory TourismSiteModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TourismSiteModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      history: data['history'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrl: data['videoUrl'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
    );
  }
}

class HotelModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final GeoPoint location;
  final double rating;
  final bool isActive;

  HotelModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.location,
    required this.rating,
    required this.isActive,
  });

  factory HotelModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return HotelModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      rating: (data['rating'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
    );
  }
}

class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isActive;

  PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  factory PharmacyModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return PharmacyModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}
