import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id, pharmacyId, name;
  final double price;
  final int quantity;
  final bool available;

  Medicine({
    this.id = '',
    required this.pharmacyId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.available,
  });

  factory Medicine.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return Medicine(
      id: d.id,
      pharmacyId: m['pharmacyId'] ?? '',
      name: m['name'] ?? '',
      price: (m['price'] ?? 0).toDouble(),
      quantity: (m['quantity'] ?? 0).toInt(),
      available: m['available'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'pharmacyId': pharmacyId,
    'name': name,
    'nameLower': name.toLowerCase(),
    'price': price,
    'quantity': quantity,
    'available': available,
  };
}