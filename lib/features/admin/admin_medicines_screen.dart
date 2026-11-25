import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../models/medicine.dart';
import '../../models/pharmacy.dart';

class AdminMedicinesScreen extends StatefulWidget {
  const AdminMedicinesScreen({super.key});
  @override
  State<AdminMedicinesScreen> createState() => _AdminMedicinesScreenState();
}

class _AdminMedicinesScreenState extends State<AdminMedicinesScreen> {
  final _search = TextEditingController();
  String _q = '';

  Future<void> _confirmDelete(Medicine m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الدواء'),
        content: Text('هل تريد حذف "${m.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) await FirestoreService.instance.deleteMedicine(m.id);
  }

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الأدوية')),
      body: StreamBuilder<List<Pharmacy>>(
        stream: fs.streamAllPharmacies(),
        builder: (context, phSnap) {
          final names = {for (final p in phSnap.data ?? <Pharmacy>[]) p.id: p.name};
          return StreamBuilder<List<Medicine>>(
            stream: fs.streamAllMedicines(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('حدث خطأ:\n${snap.error}', textAlign: TextAlign.center),
                ));
              }
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final all = snap.data!;
              final list = all
                  .where((m) => m.name.toLowerCase().contains(_q.toLowerCase()))
                  .toList();
              return Column(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _q = v.trim()),
                    decoration: const InputDecoration(
                      hintText: 'ابحث باسم الدواء...',
                      suffixIcon: Icon(Icons.search, color: AppColors.primary),
                    ),
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('لا توجد أدوية'))
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final m = list[i];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.lightGreen,
                            child: Icon(Icons.medication, color: AppColors.primary),
                          ),
                          title: Text(m.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${names[m.pharmacyId] ?? 'صيدلية غير معروفة'}\n'
                                  '${m.price.toStringAsFixed(0)} ج.م • الكمية: ${m.quantity}'),
                          isThreeLine: true,
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            Switch(
                              value: m.available,
                              activeColor: AppColors.success,
                              onChanged: (v) => fs.setMedicineAvailable(m.id, v),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _confirmDelete(m),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ]);
            },
          );
        },
      ),
    );
  }
}