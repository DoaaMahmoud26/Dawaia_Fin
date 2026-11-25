import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id, title, body, type; // success | warning | info
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
  });

  factory AppNotification.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return AppNotification(
      id: d.id,
      title: m['title'] ?? '',
      body: m['body'] ?? '',
      type: m['type'] ?? 'info',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}