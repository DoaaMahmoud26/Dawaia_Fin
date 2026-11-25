import 'package:cloud_firestore/cloud_firestore.dart';

class Pharmacy {
  final String id, ownerId, name, address, phone;
  final double lat, lng, rating;
  final bool approved;

  const Pharmacy({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phone,
    required this.lat,
    required this.lng,
    this.rating = 0,
    this.approved = false,
  });

  factory Pharmacy.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return Pharmacy(
      id: d.id,
      ownerId: m['ownerId'] ?? d.id,
      name: m['name'] ?? '',
      address: m['address'] ?? '',
      phone: m['phone'] ?? '',
      lat: (m['lat'] ?? 30.0444).toDouble(),
      lng: (m['lng'] ?? 31.2357).toDouble(),
      rating: (m['rating'] ?? 0).toDouble(),
      approved: m['approved'] ?? false,
    );
  }
}