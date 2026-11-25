import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/pharmacy_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/pharmacy.dart';
import '../pharmacy_details/pharmacy_details_screen.dart';

class MapScreen extends StatefulWidget {
  final Pharmacy? focus;
  const MapScreen({super.key, this.focus});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Pharmacy? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.focus;
    context.read<LocationProvider>().refresh();
  }

  Future<void> _goToMe() async {
    final pos = context.read<LocationProvider>().position;
    if (pos == null) {
      showSnack(context, 'تعذر تحديد موقعك، فعّل GPS وصلاحية الموقع');
      return;
    }
    final c = await _controller.future;
    c.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15));
  }

  @override
  Widget build(BuildContext context) {
    final pharmacies = context.watch<PharmacyProvider>();
    final loc = context.watch<LocationProvider>();

    final center = widget.focus != null
        ? LatLng(widget.focus!.lat, widget.focus!.lng)
        : const LatLng(30.0444, 31.2357);

    final markers = <Marker>{
      for (final p in pharmacies.pharmacies)
        Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.lat, p.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _selected?.id == p.id
                ? BitmapDescriptor.hueRed
                : BitmapDescriptor.hueGreen,
          ),
          onTap: () => setState(() => _selected = p),
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('موقع الصيدليات')),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: center, zoom: 13),
          markers: markers,
          myLocationEnabled: loc.position != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (c) {
            if (!_controller.isCompleted) _controller.complete(c);
          },
          onTap: (_) => setState(() => _selected = null),
        ),
        if (pharmacies.fromCache)
          Positioned(
            top: 8, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.warning, borderRadius: BorderRadius.circular(10)),
              child: const Text('تعرض بيانات محفوظة (بدون إنترنت)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        Positioned(
          left: 16,
          bottom: _selected == null ? 24 : 130,
          child: FloatingActionButton.small(
            backgroundColor: Colors.white,
            onPressed: _goToMe,
            child: const Icon(Icons.my_location, color: AppColors.primary),
          ),
        ),
        if (_selected != null)
          Positioned(
            left: 16, right: 16, bottom: 24,
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.storefront, color: AppColors.primary),
                ),
                title: Text(_selected!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_selected!.address),
                trailing: Text(
                  formatDistance(loc.distanceTo(_selected!.lat, _selected!.lng)),
                  style: const TextStyle(color: AppColors.primary),
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.pharmacyDetails,
                  arguments: PharmacyDetailsArgs(_selected!),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}