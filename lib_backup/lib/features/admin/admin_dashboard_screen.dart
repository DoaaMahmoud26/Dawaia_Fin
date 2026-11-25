import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_router.dart';
import '../../core/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.storefront, 'إدارة الصيدليات', AppRoutes.adminPharmacies),
      (Icons.people, 'إدارة المستخدمين', AppRoutes.adminUsers),
      (Icons.bar_chart, 'عرض التقارير', AppRoutes.adminReports),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: AuthService.instance.signOut)],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        children: [
          for (final it in items)
            InkWell(
              onTap: () => Navigator.pushNamed(context, it.$3),
              borderRadius: BorderRadius.circular(16),
              child: Card(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(it.$1, size: 40, color: AppColors.primary),
                  const SizedBox(height: 10),
                  Text(it.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}