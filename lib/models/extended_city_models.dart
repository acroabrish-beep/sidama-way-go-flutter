import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firestore_utils.dart';

class Hotel {
  final String id;
  final String name;
  final String type; // Hotel or Guest House
  final String ownerId;
  final String phone;
  final String email;
  final String description;
  final String address;
  final GeoPoint location;
  final List<String> photos;
  final List<String> facilities;

  Hotel({required this.id, required this.name, required this.type, required this.ownerId, required this.phone, required this.email, required this.description, required this.address, required this.location, required this.photos, required this.facilities});

  factory Hotel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Hotel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'Hotel',
      ownerId: data['ownerId'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      location: data['location'] ?? const GeoPoint(7.0504, 38.4955),
      photos: List<String>.from(data['photos'] ?? []),
      facilities: List<String>.from(data['facilities'] ?? []),
    );
  }
}

class Room {
  final String id;
  final String hotelId;
  final String type;
  final double price;
  final bool isAvailable;
  final List<String> photos;

  Room({required this.id, required this.hotelId, required this.type, required this.price, required this.isAvailable, required this.photos});

  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Room(
      id: doc.id,
      hotelId: data['hotelId'] ?? '',
      type: data['type'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      photos: List<String>.from(data['photos'] ?? []),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String phone;
  final GeoPoint location;
  final String logo;
  final List<String> photos;

  Restaurant({required this.id, required this.name, required this.address, required this.phone, required this.location, required this.logo, required this.photos});

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? const GeoPoint(7.0504, 38.4955),
      logo: data['logo'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
    );
  }
}

class FoodMenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String photo;

  FoodMenuItem({required this.id, required this.restaurantId, required this.name, required this.description, required this.price, required this.photo});

  factory FoodMenuItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return FoodMenuItem(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      photo: data['photo'] ?? '',
    );
  }
}

class CityOrder {
  final String id;
  final String userId;
  final String businessId; // Restaurant, Pharmacy, etc.
  final String type; // Food, Pharmacy
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String status; // pending, preparing, delivering, completed
  final DateTime timestamp;
  final String? driverId;

  CityOrder({required this.id, required this.userId, required this.businessId, required this.type, required this.items, required this.totalAmount, required this.status, required this.timestamp, this.driverId});

  factory CityOrder.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return CityOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      businessId: data['businessId'] ?? '',
      type: data['type'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      timestamp: FirestoreUtils.parseDateTimeOrDefault(data['timestamp']),
      driverId: data['driverId'],
    );
  }
}
