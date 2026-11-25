import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../models/app_user.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  String _role(String r) =>
      {'patient': 'مريض', 'pharmacist': 'صيدلي', 'admin': 'أدمن'}[r] ?? r;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: StreamBuilder<List<AppUser>>(
        stream: FirestoreService.instance.streamUsers(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final users = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = users[i];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.lightGreen,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(u.name),
                  subtitle: Text('${u.email}\n${_role(u.role)}'),
                  isThreeLine: true,
                  trailing: u.role == 'admin'
                      ? null
                      : Switch(
                    value: u.isActive,
                    activeColor: AppColors.success,
                    onChanged: (v) => FirestoreService.instance.setUserActive(u.uid, v),
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