import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_button.dart';
import '../../../models/search_result.dart';
import '../pharmacy_details/pharmacy_details_screen.dart';

class MedicineDetailsScreen extends StatelessWidget {
  final SearchResult result;
  const MedicineDetailsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final m = result.medicine;
    final p = result.pharmacy;
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الدواء')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.medication, size: 70, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(m.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(20)),
            child: Text(m.available ? 'متوفر' : 'غير متوفر',
                style: TextStyle(
                    color: m.available ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 16),
        Card(
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.payments, color: AppColors.primary),
              title: const Text('السعر'),
              trailing: Text('${m.price.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.inventory_2, color: AppColors.primary),
              title: const Text('الكمية المتاحة'),
              trailing: Text('${m.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.storefront, color: AppColors.primary),
              title: const Text('الصيدلية'),
              subtitle: Text(p.address),
              trailing: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.near_me, color: AppColors.primary),
              title: const Text('المسافة'),
              trailing: Text(formatDistance(result.distanceKm)),
            ),
          ]),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'تفاصيل الصيدلية وطلب التأكيد',
          icon: Icons.storefront,
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.pharmacyDetails,
            arguments: PharmacyDetailsArgs(p, medicineName: m.name),
          ),
        ),
      ]),
    );
  }
}
