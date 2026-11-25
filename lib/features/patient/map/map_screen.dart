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
  bool _picking = false; // وضع تحديد الموقع
  LatLng? _temp;         // الماركر المؤقت قبل التأكيد

  @override
  void initState() {
    super.initState();
    _selected = widget.focus;
    context.read<LocationProvider>().refresh();
  }

  Future<void> _goToMe() async {
    final loc = context.read<LocationProvider>();
    if (!loc.hasLocation) {
      showSnack(context, 'حدد موقعك بالماركر أو فعّل GPS وصلاحية الموقع');
      return;
    }
    final c = await _controller.future;
    c.animateCamera(CameraUpdate.newLatLngZoom(LatLng(loc.lat!, loc.lng!), 15));
  }

  void _startPicking() {
    final loc = context.read<LocationProvider>();
    setState(() {
      _picking = true;
      _selected = null;
      _temp = loc.hasLocation ? LatLng(loc.lat!, loc.lng!) : null;
    });
  }

  void _cancelPicking() => setState(() {
    _picking = false;
    _temp = null;
  });

  Future<void> _confirm() async {
    final t = _temp;
    if (t == null) return;
    await context.read<LocationProvider>().setManual(t.latitude, t.longitude);
    if (!mounted) return;
    setState(() {
      _picking = false;
      _temp = null;
    });
    showSnack(context, 'تم حفظ موقعك', error: false);
  }

  @override
  Widget build(BuildContext context) {
    final pharmacies = context.watch<PharmacyProvider>();
    final loc = context.watch<LocationProvider>();

    final center = widget.focus != null
        ? LatLng(widget.focus!.lat, widget.focus!.lng)
        : (loc.hasLocation
        ? LatLng(loc.lat!, loc.lng!)
        : const LatLng(30.0444, 31.2357));

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
          onTap: () {
            if (_picking) return;
            setState(() => _selected = p);
          },
        ),
      // موقعي المحفوظ (يدوي)
      if (loc.hasManual && !_picking)
        Marker(
          markerId: const MarkerId('me_manual'),
          position: LatLng(loc.manualLat!, loc.manualLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'موقعي'),
        ),
      // الماركر المؤقت أثناء التحديد (قابل للسحب)
      if (_picking && _temp != null)
        Marker(
          markerId: const MarkerId('picking'),
          position: _temp!,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onDragEnd: (p) => setState(() => _temp = p),
        ),
    };

    final fabBottom = _picking ? 150.0 : (_selected == null ? 24.0 : 130.0);

    return Scaffold(
      appBar: AppBar(title: const Text('موقع الصيدليات')),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: center, zoom: 13),
          markers: markers,
          myLocationEnabled: loc.useGps && loc.position != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (c) {
            if (!_controller.isCompleted) _controller.complete(c);
          },
          onTap: (pos) {
            if (_picking) {
              setState(() => _temp = pos);
            } else {
              setState(() => _selected = null);
            }
          },
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
        // أزرار جانبية
        Positioned(
          left: 16,
          bottom: fabBottom,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (!_picking)
              FloatingActionButton.small(
                heroTag: 'pick',
                backgroundColor: Colors.white,
                tooltip: 'حدد موقعي',
                onPressed: _startPicking,
                child: const Icon(Icons.edit_location_alt, color: AppColors.info),
              ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'me',
              backgroundColor: Colors.white,
              tooltip: 'موقعي',
              onPressed: _goToMe,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ]),
        ),
        // لوحة التأكيد أثناء التحديد
        if (_picking)
          Positioned(
            left: 16, right: 16, bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    _temp == null
                        ? 'اضغط على الخريطة لتحديد موقعك'
                        : 'اسحب الماركر لضبط موقعك ثم اضغط تأكيد',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white),
                        onPressed: _temp == null ? null : _confirm,
                        child: const Text('تأكيد'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                          onPressed: _cancelPicking, child: const Text('إلغاء')),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        // كارت الصيدلية المختارة
        if (_selected != null && !_picking)
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