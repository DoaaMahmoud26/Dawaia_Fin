import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../models/pharmacy.dart';

class LocalDb {
  LocalDb._();
  static final instance = LocalDb._();
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'fin_dawaie.db');
    return openDatabase(path, version: 1, onCreate: (d, v) async {
      await d.execute('''
        CREATE TABLE search_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT UNIQUE NOT NULL,
          created_at INTEGER NOT NULL
        )''');
      await d.execute('''
        CREATE TABLE pharmacies_cache(
          id TEXT PRIMARY KEY,
          owner_id TEXT, name TEXT, address TEXT, phone TEXT,
          lat REAL, lng REAL, rating REAL
        )''');
    });
  }

  // ---------- سجل البحث ----------
  Future<void> addSearch(String q) async {
    final d = await db;
    await d.insert(
      'search_history',
      {'query': q, 'created_at': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> history({int limit = 8}) async {
    final d = await db;
    final rows = await d.query('search_history',
        orderBy: 'created_at DESC', limit: limit);
    return rows.map((r) => r['query'] as String).toList();
  }

  Future<void> clearHistory() async {
    final d = await db;
    await d.delete('search_history');
  }

  // ---------- كاش الصيدليات ----------
  Future<void> cachePharmacies(List<Pharmacy> list) async {
    final d = await db;
    final batch = d.batch();
    batch.delete('pharmacies_cache');
    for (final p in list) {
      batch.insert('pharmacies_cache', {
        'id': p.id,
        'owner_id': p.ownerId,
        'name': p.name,
        'address': p.address,
        'phone': p.phone,
        'lat': p.lat,
        'lng': p.lng,
        'rating': p.rating,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Pharmacy>> cachedPharmacies() async {
    final d = await db;
    final rows = await d.query('pharmacies_cache');
    return rows
        .map((r) => Pharmacy(
      id: r['id'] as String,
      ownerId: r['owner_id'] as String? ?? '',
      name: r['name'] as String? ?? '',
      address: r['address'] as String? ?? '',
      phone: r['phone'] as String? ?? '',
      lat: (r['lat'] as num).toDouble(),
      lng: (r['lng'] as num).toDouble(),
      rating: (r['rating'] as num?)?.toDouble() ?? 0,
      approved: true,
    ))
        .toList();
  }
}