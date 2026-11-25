import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<int>> _future = _load();

  Future<List<int>> _load() {
    final fs = FirestoreService.instance;
    return Future.wait([
      fs.count('users'),
      fs.count('users', field: 'role', isEqualTo: 'patient'),
      fs.count('users', field: 'role', isEqualTo: 'pharmacist'),
      fs.count('pharmacies'),
      fs.count('pharmacies', field: 'approved', isEqualTo: true),
      fs.count('medicines'),
      fs.count('requests'),
      fs.count('requests', field: 'status', isEqualTo: 'pending'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.people, 'كل المستخدمين'),
      (Icons.person, 'المرضى'),
      (Icons.local_pharmacy, 'الصيادلة'),
      (Icons.storefront, 'الصيدليات'),
      (Icons.verified, 'صيدليات معتمدة'),
      (Icons.medication, 'الأدوية'),
      (Icons.list_alt, 'كل الطلبات'),
      (Icons.hourglass_top, 'طلبات معلّقة'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: _future,
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('حدث خطأ:\n${snap.error}', textAlign: TextAlign.center),
            ));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final v = snap.data!;
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (var i = 0; i < items.length; i++)
                Card(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(items[i].$1, color: AppColors.secondary, size: 28),
                    const SizedBox(height: 6),
                    Text('${v[i]}',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text(items[i].$2),
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }
}