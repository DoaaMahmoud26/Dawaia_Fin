import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _authSub = AuthService.instance.authState.listen(_onAuth);
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _userSub;

  AppUser? user;
  bool initializing = true;
  bool signedIn = false;

  void _onAuth(User? u) {
    _userSub?.cancel();
    signedIn = u != null;
    if (u == null) {
      user = null;
      initializing = false;
      notifyListeners();
      return;
    }
    _userSub = FirestoreService.instance.streamUser(u.uid).listen((a) {
      user = a;
      initializing = false;
      notifyListeners();
    }, onError: (_) {
      initializing = false;
      notifyListeners();
    });
  }

  /// ترجع رسالة الخطأ، أو null لو نجحت العملية
  Future<String?> signIn(String email, String password) async {
    try {
      await AuthService.instance.signIn(email, password);
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthService.message(e.code);
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
    String? pharmacyName,
    String? address,
    String? phone,
  }) async {
    try {
      await AuthService.instance.signUp(
        name: name, email: email, password: password, role: role,
        pharmacyName: pharmacyName, address: address, phone: phone,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return AuthService.message(e.code);
    }
  }

  Future<void> signOut() => AuthService.instance.signOut();

  // ---------- المفضلة ----------
  bool isFavorite(String pharmacyId) =>
      user?.favorites.contains(pharmacyId) ?? false;

  Future<void> toggleFavorite(String pharmacyId) {
    final u = user;
    if (u == null) return Future.value();
    return FirestoreService.instance
        .toggleFavorite(u.uid, pharmacyId, !isFavorite(pharmacyId));
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }
}