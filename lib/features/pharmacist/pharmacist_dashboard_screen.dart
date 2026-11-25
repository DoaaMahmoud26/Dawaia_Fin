import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_router.dart';
import '../../core/services/firestore_service.dart';
import '../../models/app_user.dart';
import '../../models/med_request.dart';
import '../../models/medicine.dart';
import '../../models/pharmacy.dart';

class PharmacistDashboardScreen extends StatelessWidget {
  final AppUser user;
  const PharmacistDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الصيدلي')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        StreamBuilder<Pharmacy?>(
          stream: fs.streamPharmacy(user.uid),
          builder: (_, s) {
            if (s.data != null && !s.data!.approved) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('صيدليتك قيد المراجعة من الإدارة، ولن تظهر للمرضى إلا بعد الاعتماد.'),
              );
            }
            return const SizedBox();
          },
        ),
        Text('مرحبًا ${user.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('إدارة الأدوية المتوفرة', style: TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 16),
        StreamBuilder<List<Medicine>>(
          stream: fs.streamMedicines(user.uid),
          builder: (_, ms) {
            final meds = ms.data ?? [];
            return StreamBuilder<List<MedRequest>>(
              stream: fs.streamPharmacyRequests(user.uid),
              builder: (_, rs) {
                final reqs = rs.data ?? [];
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _Stat(Icons.medication, 'الأدوية المتوفرة',
                        meds.where((m) => m.available).length, AppColors.primary),
                    _Stat(Icons.notifications_active, 'الطلبات الجديدة',
                        reqs.where((r) => r.status == 'pending').length, AppColors.warning),
                    _Stat(Icons.check_circle, 'تم تأكيدها',
                        reqs.where((r) => r.status == 'available').length, AppColors.success),
                    _Stat(Icons.remove_circle, 'أدوية منتهية',
                        meds.where((m) => !m.available).length, AppColors.error),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.inventory_2, color: AppColors.primary),
            title: const Text('مخزون الأدوية'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.pushNamed(context, AppRoutes.inventory),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.add_circle, color: AppColors.primary),
            title: const Text('إضافة دواء جديد'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.pushNamed(context, AppRoutes.editMedicine),
          ),
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  const _Stat(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 13)),
      ]),
    );
  }
}