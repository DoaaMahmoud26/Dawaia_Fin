import 'package:cloud_firestore/cloud_firestore.dart';

class MedRequest {
  final String id, patientId, patientName, pharmacyId, pharmacyName, medicineName;
  final String status; // pending | available | unavailable
  final DateTime createdAt;

  MedRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.medicineName,
    required this.status,
    required this.createdAt,
  });

  factory MedRequest.fromDoc(DocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return MedRequest(
      id: d.id,
      patientId: m['patientId'] ?? '',
      patientName: m['patientName'] ?? '',
      pharmacyId: m['pharmacyId'] ?? '',
      pharmacyName: m['pharmacyName'] ?? '',
      medicineName: m['medicineName'] ?? '',
      status: m['status'] ?? 'pending',
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}