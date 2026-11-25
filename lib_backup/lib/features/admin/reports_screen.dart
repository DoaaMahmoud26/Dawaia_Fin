import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<List<int>> _load() {
    final fs = FirestoreService.instance;
    return Future.wait([
      fs.count('users'),
      fs.count('users', field: 'role', isEqualTo: 'patient'),
      fs.count('pharmacies'),
      fs.count('pharmacies', field: 'approved', isEqualTo: true),
      fs.count('medicines'),
      fs.count('requests'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const labels = [
      'كل المستخدمين', 'المرضى', 'الصيدليات', 'صيدليات معتمدة', 'الأدوية', 'الطلبات'
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: FutureBuilder<List<int>>(
        future: _load(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final v = snap.data!;
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (var i = 0; i < labels.length; i++)
                Card(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${v[i]}',
                        style: const TextStyle(
                            fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text(labels[i]),
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }
}