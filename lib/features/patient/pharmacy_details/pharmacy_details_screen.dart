import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/pharmacy.dart';
import 'package:fin_dawaie/core/providers/auth_provider.dart';


class PharmacyDetailsArgs {
  final Pharmacy pharmacy;
  final String? medicineName; // لو جاي من نتائج البحث
  PharmacyDetailsArgs(this.pharmacy, {this.medicineName});
}

class PharmacyDetailsScreen extends StatelessWidget {
  final PharmacyDetailsArgs args;
  const PharmacyDetailsScreen({super.key, required this.args});

  Pharmacy get p => args.pharmacy;

  Future<void> _requestAvailability(BuildContext context) async {
    var name = args.medicineName;
    if (name == null) {
      final c = TextEditingController();
      name = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('اسم الدواء'),
          content: TextField(controller: c, decoration: const InputDecoration(hintText: 'مثال: Paracetamol')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            TextButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('إرسال')),
          ],
        ),
      );
    }
    if (name == null || name.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    final appUser = await FirestoreService.instance.getUser(user.uid);
    await FirestoreService.instance.createRequest(
      patientId: user.uid,
      patientName: appUser?.name ?? '',
      pharmacy: p,
      medicineName: name,
    );
    if (context.mounted) showSnack(context, 'تم إرسال الطلب للصيدلية', error: false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الصيدلية'),
        actions: [
          Consumer<AuthProvider>(
            builder: (_, auth, __) {
              final fav = auth.isFavorite(p.id);
              return IconButton(
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border),
                onPressed: () => auth.toggleFavorite(p.id),
              );
            },
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
              color: AppColors.lightGreen, borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.storefront, size: 80, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: Text(p.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const Icon(Icons.verified, color: AppColors.success),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.star, color: AppColors.warning, size: 20),
          const SizedBox(width: 4),
          Text(p.rating.toStringAsFixed(1)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 20),
          const SizedBox(width: 6),
          Expanded(child: Text(p.address)),
        ]),
        const SizedBox(height: 16),
        if (args.medicineName != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.lightGreen, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text('يتوفر لديك هذا الدواء: ${args.medicineName}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
        const SizedBox(height: 20),
        AppButton(
          label: 'اطلب تأكيد توافر الدواء',
          icon: Icons.notifications_active,
          onPressed: () => _requestAvailability(context),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'اتصال',
          icon: Icons.phone,
          onPressed: () => launchUrl(Uri.parse('tel:${p.phone}')),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'عرض على الخريطة',
          icon: Icons.map,
          light: true,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.map, arguments: p),
        ),
        const SizedBox(height: 10),
        AppButton(
          label: 'اتجاهات',
          icon: Icons.directions,
          light: true,
          onPressed: () => launchUrl(
            Uri.parse(
                'https://www.google.com/maps/dir/?api=1&destination=${p.lat},${p.lng}'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ]),
    );
  }
}