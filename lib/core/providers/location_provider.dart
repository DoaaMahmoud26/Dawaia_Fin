import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider() {
    _ready = _loadPrefs();
  }

  late final Future<void> _ready;

  Position? position;          // موقع الـ GPS
  double? manualLat, manualLng; // الموقع اللي حدده المستخدم بالماركر
  bool useGps = true;
  bool loading = false;

  /// الموقع الفعّال: اليدوي له الأولوية، ثم GPS
  double? get lat => manualLat ?? position?.latitude;
  double? get lng => manualLng ?? position?.longitude;
  bool get hasManual => manualLat != null && manualLng != null;
  bool get hasLocation => lat != null && lng != null;

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    useGps = p.getBool('use_gps') ?? true;
    manualLat = p.getDouble('manual_lat');
    manualLng = p.getDouble('manual_lng');
    notifyListeners();
  }

  Future<void> refresh() async {
    await _ready;
    if (!useGps) {
      position = null;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    position = await LocationService.currentPosition();
    loading = false;
    notifyListeners();
  }

  Future<void> setUseGps(bool v) async {
    await _ready;
    useGps = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool('use_gps', v);
    if (v) {
      await refresh();
    } else {
      position = null;
      notifyListeners();
    }
  }

  Future<void> setManual(double lat, double lng) async {
    manualLat = lat;
    manualLng = lng;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setDouble('manual_lat', lat);
    await p.setDouble('manual_lng', lng);
  }

  Future<void> clearManual() async {
    manualLat = null;
    manualLng = null;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.remove('manual_lat');
    await p.remove('manual_lng');
  }

  double? distanceTo(double pLat, double pLng) => (lat == null || lng == null)
      ? null
      : LocationService.distanceKm(lat!, lng!, pLat, pLng);
}