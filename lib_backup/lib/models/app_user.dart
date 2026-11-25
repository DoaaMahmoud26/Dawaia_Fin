import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid, name, email, role; // patient | pharmacist | admin
  final bool isActive;
  final List<String> favorites;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.favorites = const [],
  });

  factory AppUser.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return AppUser(
      uid: d.id,
      name: m['name'] ?? '',
      email: m['email'] ?? '',
      role: m['role'] ?? 'patient',
      isActive: m['isActive'] ?? true,
      favorites: List<String>.from(m['favorites'] ?? []),
    );
  }
}