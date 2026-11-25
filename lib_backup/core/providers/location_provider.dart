import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  Position? position;
  bool loading = false;

  Future<void> refresh() async {
    loading = true;
    position = await LocationService.currentPosition();
    loading = false;
    notifyListeners();
  }

  double? distanceTo(double lat, double lng) => position == null
      ? null
      : LocationService.distanceKm(
      position!.latitude, position!.longitude, lat, lng);
}