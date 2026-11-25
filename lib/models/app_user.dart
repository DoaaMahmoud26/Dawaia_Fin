import 'package:cloud_firestore/cloud_firestore.dart';


bool _toBool(dynamic v, {bool fallback = true}) {
  if (v is bool) return v;
  if (v is String) return v.trim().toLowerCase() == 'true';
  if (v is num) return v != 0;
  return fallback;
}

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
      name: (m['name'] ?? '').toString(),
      email: (m['email'] ?? '').toString(),
      role: (m['role'] ?? 'patient').toString().trim(),
      isActive: _toBool(m['isActive']),
      favorites: (m['favorites'] is List)
          ? List<String>.from((m['favorites'] as List).map((e) => e.toString()))
          : <String>[],
    );
  }
}