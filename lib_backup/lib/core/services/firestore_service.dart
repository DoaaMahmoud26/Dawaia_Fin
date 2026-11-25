import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_notification.dart';
import '../../models/app_user.dart';
import '../../models/med_request.dart';
import '../../models/medicine.dart';
import '../../models/pharmacy.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();
  final _db = FirebaseFirestore.instance;

  // ---------------- Users ----------------
  Future<AppUser?> getUser(String uid) async {
    final d = await _db.collection('users').doc(uid).get();
    return d.exists ? AppUser.fromDoc(d) : null;
  }

  Stream<AppUser?> streamUser(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((d) => d.exists ? AppUser.fromDoc(d) : null);

  Stream<List<AppUser>> streamUsers() => _db
      .collection('users')
      .snapshots()
      .map((s) => s.docs.map(AppUser.fromDoc).toList());

  Future<void> setUserActive(String uid, bool active) =>
      _db.collection('users').doc(uid).update({'isActive': active});

  Future<void> saveFcmToken(String uid, String token) =>
      _db.collection('users').doc(uid).update({'fcmToken': token});

  Future<void> toggleFavorite(String uid, String pharmacyId, bool add) =>
      _db.collection('users').doc(uid).update({
        'favorites': add
            ? FieldValue.arrayUnion([pharmacyId])
            : FieldValue.arrayRemove([pharmacyId]),
      });

  // ---------------- Pharmacies ----------------
  Stream<List<Pharmacy>> streamApprovedPharmacies() => _db
      .collection('pharmacies')
      .where('approved', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(Pharmacy.fromDoc).toList());

  Stream<List<Pharmacy>> streamAllPharmacies() => _db
      .collection('pharmacies')
      .snapshots()
      .map((s) => s.docs.map(Pharmacy.fromDoc).toList());

  Stream<Pharmacy?> streamPharmacy(String id) => _db
      .collection('pharmacies')
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Pharmacy.fromDoc(d) : null);

  Future<void> setPharmacyApproved(String id, bool approved) =>
      _db.collection('pharmacies').doc(id).update({'approved': approved});

  Future<void> updatePharmacy(String id, Map<String, dynamic> data) =>
      _db.collection('pharmacies').doc(id).update(data);

  Future<List<Pharmacy>> getPharmaciesByIds(List<String> ids) async {
    final out = <Pharmacy>[];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, min(i + 10, ids.length));
      final snap = await _db
          .collection('pharmacies')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      out.addAll(snap.docs.map(Pharmacy.fromDoc));
    }
    return out.where((p) => p.approved).toList();
  }

  // ---------------- Medicines ----------------
  Stream<List<Medicine>> streamMedicines(String pharmacyId) => _db
      .collection('medicines')
      .where('pharmacyId', isEqualTo: pharmacyId)
      .snapshots()
      .map((s) => s.docs.map(Medicine.fromDoc).toList());

  Future<void> saveMedicine(Medicine m) {
    final col = _db.collection('medicines');
    return m.id.isEmpty ? col.add(m.toMap()) : col.doc(m.id).set(m.toMap());
  }

  Future<void> setMedicineAvailable(String id, bool v) =>
      _db.collection('medicines').doc(id).update({'available': v});

  Future<void> deleteMedicine(String id) =>
      _db.collection('medicines').doc(id).delete();

  /// بحث بالبداية (prefix) في اسم الدواء، وبنفلتر المتوفر في الجهاز
  /// عشان منحتاجش Composite Index.
  Future<List<Medicine>> searchMedicines(String query) async {
    final q = query.trim().toLowerCase();
    final snap = await _db
        .collection('medicines')
        .where('nameLower', isGreaterThanOrEqualTo: q)
        .where('nameLower', isLessThan: '$q\uf8ff')
        .limit(50)
        .get();
    return snap.docs.map(Medicine.fromDoc).where((m) => m.available).toList();
  }

  // ---------------- Requests ----------------
  Future<void> createRequest({
    required String patientId,
    required String patientName,
    required Pharmacy pharmacy,
    required String medicineName,
  }) async {
    await _db.collection('requests').add({
      'patientId': patientId,
      'patientName': patientName,
      'pharmacyId': pharmacy.id,
      'pharmacyName': pharmacy.name,
      'medicineName': medicineName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await addNotification(
      userId: pharmacy.ownerId,
      title: 'طلب جديد',
      body: '$patientName يسأل عن توفر $medicineName',
      type: 'info',
    );
  }

  Stream<List<MedRequest>> streamPharmacyRequests(String pharmacyId) => _db
      .collection('requests')
      .where('pharmacyId', isEqualTo: pharmacyId)
      .snapshots()
      .map((s) {
    final list = s.docs.map(MedRequest.fromDoc).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });

  Future<void> respondToRequest(MedRequest r, bool available) async {
    await _db
        .collection('requests')
        .doc(r.id)
        .update({'status': available ? 'available' : 'unavailable'});
    await addNotification(
      userId: r.patientId,
      title: available ? 'تم تحديث توفر الدواء' : 'الدواء غير متوفر',
      body: available
          ? '${r.medicineName} متوفر في ${r.pharmacyName}'
          : '${r.medicineName} غير متوفر حاليًا في ${r.pharmacyName}',
      type: available ? 'success' : 'warning',
    );
  }

  // ---------------- Notifications ----------------
  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
  }) =>
      _db.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Stream<List<AppNotification>> streamNotifications(String uid) => _db
      .collection('notifications')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) {
    final list = s.docs.map(AppNotification.fromDoc).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  });

  // ---------------- Stats (Admin) ----------------
  Future<int> count(String collection, {String? field, Object? isEqualTo}) async {
    Query q = _db.collection(collection);
    if (field != null) q = q.where(field, isEqualTo: isEqualTo);
    final agg = await q.count().get();
    return agg.count ?? 0;
  }
}