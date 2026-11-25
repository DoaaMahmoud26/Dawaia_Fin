import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'location_service.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authState => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role, // patient | pharmacist
    String? pharmacyName,
    String? address,
    String? phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;

    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'role': role,
      'isActive': true,
      'favorites': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (role == 'pharmacist') {
      final pos = await LocationService.currentPosition();
      await _db.collection('pharmacies').doc(uid).set({
        'ownerId': uid,
        'name': pharmacyName ?? name,
        'address': address ?? '',
        'phone': phone ?? '',
        'lat': pos?.latitude ?? 30.0444,
        'lng': pos?.longitude ?? 31.2357,
        'rating': 0,
        'approved': false, // لازم الأدمن يعتمدها
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() => _auth.signOut();

  static String message(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'البريد أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة (6 أحرف على الأقل)';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }
}