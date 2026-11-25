import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../database/local_db.dart';

import '../../models/pharmacy.dart';
import '../services/firestore_service.dart';

/// بيسمع صيدليات Firestore، وبيحفظها في SQLite، ولو النت قطع بيعرض النسخة المحلية
class PharmacyProvider extends ChangeNotifier {
  List<Pharmacy> pharmacies = [];
  bool fromCache = false;
  StreamSubscription<List<Pharmacy>>? _sub;

  /// تُنادى من ProxyProvider كل ما حالة الدخول تتغير
  void bind(bool signedIn) {
    if (signedIn && _sub == null) {
      _loadCache();
      _sub = FirestoreService.instance.streamApprovedPharmacies().listen(
            (list) {
          pharmacies = list;
          fromCache = false;
          notifyListeners();
          LocalDb.instance.cachePharmacies(list);
        },
        onError: (_) => _loadCache(),
      );
    } else if (!signedIn && _sub != null) {
      _sub!.cancel();
      _sub = null;
      pharmacies = [];
    }
  }

  Future<void> _loadCache() async {
    if (pharmacies.isNotEmpty) return;
    final cached = await LocalDb.instance.cachedPharmacies();
    if (cached.isNotEmpty && pharmacies.isEmpty) {
      pharmacies = cached;
      fromCache = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}