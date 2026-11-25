import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../models/pharmacy.dart';

class PharmaciesManagementScreen extends StatelessWidget {
  const PharmaciesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الصيدليات')),
      body: StreamBuilder<List<Pharmacy>>(
        stream: FirestoreService.instance.streamAllPharmacies(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!..sort((a, b) => a.approved ? 1 : -1); // المعلّقة أولًا
          if (list.isEmpty) return const Center(child: Text('لا توجد صيدليات'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = list[i];
              return Card(
                child: ListTile(
                  leading: Icon(
                    p.approved ? Icons.verified : Icons.hourglass_top,
                    color: p.approved ? AppColors.success : AppColors.warning,
                  ),
                  title: Text(p.name),
                  subtitle: Text('${p.address}\n${p.phone}'),
                  isThreeLine: true,
                  trailing: p.approved
                      ? TextButton(
                    onPressed: () => FirestoreService.instance.setPharmacyApproved(p.id, false),
                    child: const Text('إيقاف', style: TextStyle(color: AppColors.error)),
                  )
                      : ElevatedButton(
                    onPressed: () => FirestoreService.instance.setPharmacyApproved(p.id, true),
                    child: const Text('اعتماد'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}