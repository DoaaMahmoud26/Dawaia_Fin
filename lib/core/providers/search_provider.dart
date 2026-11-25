import 'package:flutter/foundation.dart';
import '../../database/local_db.dart';
import '../../models/search_result.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

class SearchProvider extends ChangeNotifier {
  List<SearchResult> results = [];
  List<String> history = [];
  bool loading = false;

  Future<void> loadHistory() async {
    history = await LocalDb.instance.history();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await LocalDb.instance.clearHistory();
    history = [];
    notifyListeners();
  }

  Future<void> search(String query, double? myLat, double? myLng) async {
    loading = true;
    results = [];
    notifyListeners();
    try {
      await LocalDb.instance.addSearch(query);
      final fs = FirestoreService.instance;
      final meds = await fs.searchMedicines(query);
      if (meds.isNotEmpty) {
        final ids = meds.map((m) => m.pharmacyId).toSet().toList();
        final pharmacies = {
          for (final p in await fs.getPharmaciesByIds(ids)) p.id: p
        };
        final list = <SearchResult>[];
        for (final m in meds) {
          final p = pharmacies[m.pharmacyId];
          if (p == null) continue;
          final d = (myLat == null || myLng == null)
              ? null
              : LocationService.distanceKm(myLat, myLng, p.lat, p.lng);
          list.add(SearchResult(m, p, d));
        }
        list.sort((a, b) =>
            (a.distanceKm ?? 9999).compareTo(b.distanceKm ?? 9999));
        results = list;
      }
    } finally {
      loading = false;
      notifyListeners();
      loadHistory();
    }
  }
}