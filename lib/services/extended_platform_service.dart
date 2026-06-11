import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/extended_city_models.dart';

class ExtendedPlatformService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hotels & Guest Houses
  Stream<List<Hotel>> getHotels() {
    return _db.collection('hotels').snapshots().map((snap) => snap.docs.map((doc) => Hotel.fromFirestore(doc)).toList());
  }

  Future<List<Room>> getHotelRooms(String hotelId) async {
    final snap = await _db.collection('hotels').doc(hotelId).collection('rooms').get();
    return snap.docs.map((doc) => Room.fromFirestore(doc)).toList();
  }

  Future<void> bookRoom(String hotelId, Room room, DateTime checkIn, DateTime checkOut) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('hotel_bookings').add({
      'userId': uid,
      'hotelId': hotelId,
      'roomId': room.id,
      'roomType': room.type,
      'price': room.price,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'status': 'confirmed',
      'qrCode': 'HOTEL-${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Restaurants & Food
  Stream<List<Restaurant>> getRestaurants() {
    return _db.collection('restaurants').snapshots().map((snap) => snap.docs.map((doc) => Restaurant.fromFirestore(doc)).toList());
  }

  Future<List<FoodMenuItem>> getRestaurantMenu(String restaurantId) async {
    final snap = await _db.collection('restaurants').doc(restaurantId).collection('menu').get();
    return snap.docs.map((doc) => FoodMenuItem.fromFirestore(doc)).toList();
  }

  Future<void> placeFoodOrder(String restaurantId, List<Map<String, dynamic>> items, double total) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('orders').add({
      'userId': uid,
      'businessId': restaurantId,
      'type': 'Food',
      'items': items,
      'totalAmount': total,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Business Owner Access
  Stream<List<CityOrder>> getBusinessOrders(String businessId) {
    return _db.collection('orders')
      .where('businessId', isEqualTo: businessId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => CityOrder.fromFirestore(doc)).toList());
  }
}
