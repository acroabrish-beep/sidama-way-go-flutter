import 'package:cloud_firestore/cloud_firestore.dart';

enum ApprovalStatus { pending, approved, rejected, suspended }

class TouristSite {
  final String id, name, description, category;
  final double lat, lng, rating;
  final List<String> images;
  final String openingHours, entryFee;
  final bool isActive;
  TouristSite({required this.id, required this.name, required this.description, required this.category, required this.lat, required this.lng, required this.rating, required this.images, required this.openingHours, required this.entryFee, required this.isActive});
  factory TouristSite.fromMap(Map<String, dynamic> d, String id) => TouristSite(id: id, name: d['name'] ?? '', description: d['description'] ?? '', category: d['category'] ?? '', lat: (d['lat'] as num?)?.toDouble() ?? 7.0504, lng: (d['lng'] as num?)?.toDouble() ?? 38.4955, rating: (d['rating'] as num?)?.toDouble() ?? 4.5, images: List<String>.from(d['images'] ?? []), openingHours: d['openingHours'] ?? '6:00 AM - 6:00 PM', entryFee: d['entryFee'] ?? 'Free', isActive: d['isActive'] ?? true);
  Map<String, dynamic> toMap() => {'name': name, 'description': description, 'category': category, 'lat': lat, 'lng': lng, 'rating': rating, 'images': images, 'openingHours': openingHours, 'entryFee': entryFee, 'isActive': isActive};
}

class TourPackage {
  final String id, name, description, destination, duration, guideId, guideName, operatorId;
  final double price;
  final List<String> images;
  final bool guideIncluded, vehicleIncluded;
  final String status;
  TourPackage({required this.id, required this.name, required this.description, required this.destination, required this.duration, required this.price, required this.images, required this.guideIncluded, required this.vehicleIncluded, required this.status, required this.guideId, required this.guideName, required this.operatorId});
  factory TourPackage.fromMap(Map<String, dynamic> d, String id) => TourPackage(id: id, name: d['name'] ?? '', description: d['description'] ?? '', destination: d['destination'] ?? '', duration: d['duration'] ?? '1 day', price: (d['price'] as num?)?.toDouble() ?? 0, images: List<String>.from(d['images'] ?? []), guideIncluded: d['guideIncluded'] ?? false, vehicleIncluded: d['vehicleIncluded'] ?? false, status: d['status'] ?? 'active', guideId: d['guideId'] ?? '', guideName: d['guideName'] ?? '', operatorId: d['operatorId'] ?? '');
  Map<String, dynamic> toMap() => {'name': name, 'description': description, 'destination': destination, 'duration': duration, 'price': price, 'images': images, 'guideIncluded': guideIncluded, 'vehicleIncluded': vehicleIncluded, 'status': status, 'guideId': guideId, 'guideName': guideName, 'operatorId': operatorId};
}

class TourGuide {
  final String id, fullName, phone, email, experience, status, nationalId, profilePhoto;
  final List<String> languages;
  final double rating;
  TourGuide({required this.id, required this.fullName, required this.phone, required this.email, required this.experience, required this.status, required this.nationalId, required this.profilePhoto, required this.languages, required this.rating});
  factory TourGuide.fromMap(Map<String, dynamic> d, String id) => TourGuide(id: id, fullName: d['fullName'] ?? '', phone: d['phone'] ?? '', email: d['email'] ?? '', experience: d['experience'] ?? '', status: d['status'] ?? 'pending', nationalId: d['nationalId'] ?? '', profilePhoto: d['profilePhoto'] ?? '', languages: List<String>.from(d['languages'] ?? ['English']), rating: (d['rating'] as num?)?.toDouble() ?? 0);
  Map<String, dynamic> toMap() => {'fullName': fullName, 'phone': phone, 'email': email, 'experience': experience, 'status': status, 'nationalId': nationalId, 'profilePhoto': profilePhoto, 'languages': languages, 'rating': rating};
}

class ContractRide {
  final String id, userId, pickup, destination, vehicleType, status, passengerPhone;
  final int passengers;
  final double price;
  final DateTime date;
  ContractRide({required this.id, required this.userId, required this.pickup, required this.destination, required this.vehicleType, required this.status, required this.passengers, required this.price, required this.date, required this.passengerPhone});
  factory ContractRide.fromMap(Map<String, dynamic> d, String id) => ContractRide(id: id, userId: d['userId'] ?? '', pickup: d['pickup'] ?? '', destination: d['destination'] ?? '', vehicleType: d['vehicleType'] ?? 'Taxi', status: d['status'] ?? 'pending', passengers: (d['passengers'] as num?)?.toInt() ?? 1, price: (d['price'] as num?)?.toDouble() ?? 0, date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(), passengerPhone: d['passengerPhone'] ?? '');
  Map<String, dynamic> toMap() => {'userId': userId, 'pickup': pickup, 'destination': destination, 'vehicleType': vehicleType, 'status': status, 'passengers': passengers, 'price': price, 'date': date, 'passengerPhone': passengerPhone, 'createdAt': FieldValue.serverTimestamp()};
}

class TouristEvent {
  final String id, title, location, description, imageUrl;
  final DateTime date;
  TouristEvent({required this.id, required this.title, required this.location, required this.description, required this.imageUrl, required this.date});
  factory TouristEvent.fromMap(Map<String, dynamic> d, String id) => TouristEvent(id: id, title: d['title'] ?? '', location: d['location'] ?? 'Hawassa', description: d['description'] ?? '', imageUrl: d['imageUrl'] ?? '', date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now());
  Map<String, dynamic> toMap() => {'title': title, 'location': location, 'description': description, 'imageUrl': imageUrl, 'date': date};
}

class TouristBooking {
  final String id, userId, userName, passengerName, phone, date, status, packageId, packageName, type;
  final int people, hours;
  final double totalPrice;
  final DateTime createdAt;
  TouristBooking({required this.id, required this.userId, required this.userName, required this.passengerName, required this.phone, required this.date, required this.status, required this.packageId, required this.packageName, required this.type, required this.people, required this.hours, required this.totalPrice, required this.createdAt});
  factory TouristBooking.fromMap(Map<String, dynamic> d, String id) => TouristBooking(id: id, userId: d['userId'] ?? '', userName: d['userName'] ?? '', passengerName: d['passengerName'] ?? '', phone: d['phone'] ?? '', date: d['date'] ?? '', status: d['status'] ?? 'pending', packageId: d['packageId'] ?? '', packageName: d['packageName'] ?? '', type: d['type'] ?? 'package', people: (d['people'] as num?)?.toInt() ?? 1, hours: (d['hours'] as num?)?.toInt() ?? 0, totalPrice: (d['totalPrice'] as num?)?.toDouble() ?? 0.0, createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now());
  Map<String, dynamic> toMap() => {'userId': userId, 'userName': userName, 'passengerName': passengerName, 'phone': phone, 'date': date, 'status': status, 'packageId': packageId, 'packageName': packageName, 'type': type, 'people': people, 'hours': hours, 'totalPrice': totalPrice, 'createdAt': FieldValue.serverTimestamp()};
}

class TourOperator {
  final String id, companyName, ownerName, phone, email, address, licenseNumber, description;
  final List<String> services;
  final String status;
  TourOperator({required this.id, required this.companyName, required this.ownerName, required this.phone, required this.email, required this.address, required this.licenseNumber, required this.description, required this.services, required this.status});
  factory TourOperator.fromMap(Map<String, dynamic> d, String id) => TourOperator(id: id, companyName: d['companyName'] ?? '', ownerName: d['ownerName'] ?? '', phone: d['phone'] ?? '', email: d['email'] ?? '', address: d['address'] ?? '', licenseNumber: d['licenseNumber'] ?? '', description: d['description'] ?? '', services: List<String>.from(d['services'] ?? []), status: d['status'] ?? 'pending');
  Map<String, dynamic> toMap() => {'companyName': companyName, 'ownerName': ownerName, 'phone': phone, 'email': email, 'address': address, 'licenseNumber': licenseNumber, 'description': description, 'services': services, 'status': status};
}
