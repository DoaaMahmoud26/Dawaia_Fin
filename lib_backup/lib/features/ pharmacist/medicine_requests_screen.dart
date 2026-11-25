import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/helpers.dart';
import '../../models/med_request.dart';

class MedicineRequestsScreen extends StatelessWidget {
  final String pharmacyId;
  const MedicineRequestsScreen({super.key, required this.pharmacyId});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات المرضى')),
      body: StreamBuilder<List<MedRequest>>(
        stream: fs.streamPharmacyRequests(pharmacyId),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('لا توجد طلبات'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = list[i];
              final pending = r.status == 'pending';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.medicineName,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('${r.patientName} • ${timeAgo(r.createdAt)}',
                        style: const TextStyle(color: AppColors.textGrey)),
                    const SizedBox(height: 10),
                    if (pending)
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success, foregroundColor: Colors.white),
                            onPressed: () => fs.respondToRequest(r, true),
                            child: const Text('متوفر'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error, foregroundColor: Colors.white),
                            onPressed: () => fs.respondToRequest(r, false),
                            child: const Text('غير متوفر'),
                          ),
                        ),
                      ])
                    else
                      Text(
                        r.status == 'available' ? 'تم التأكيد: متوفر' : 'تم التأكيد: غير متوفر',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: r.status == 'available' ? AppColors.success : AppColors.error,
                        ),
                      ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}