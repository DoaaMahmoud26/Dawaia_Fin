import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_router.dart';
import '../../core/services/firestore_service.dart';
import '../../models/medicine.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final fs = FirestoreService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('مخزون الأدوية')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.editMedicine),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: fs.streamMedicines(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('لا توجد أدوية، أضف أول دواء'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final m = list[i];
              return Dismissible(
                key: ValueKey(m.id),
                direction: DismissDirection.startToEnd,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: AppColors.error, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => fs.deleteMedicine(m.id),
                child: Card(
                  child: ListTile(
                    title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${m.price.toStringAsFixed(0)} ج.م • الكمية: ${m.quantity}'),
                    leading: IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.info),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.editMedicine, arguments: m),
                    ),
                    trailing: Switch(
                      value: m.available,
                      activeColor: AppColors.success,
                      onChanged: (v) => fs.setMedicineAvailable(m.id, v),
                    ),
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