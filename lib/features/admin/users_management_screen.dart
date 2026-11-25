import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../models/app_user.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});
  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  String _q = '';

  String _role(String r) =>
      {'patient': 'مريض', 'pharmacist': 'صيدلي', 'admin': 'أدمن'}[r] ?? r;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين')),
      body: StreamBuilder<List<AppUser>>(
        stream: FirestoreService.instance.streamUsers(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('حدث خطأ:\n${snap.error}', textAlign: TextAlign.center),
            ));
          }
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final users = snap.data!
              .where((u) =>
          u.name.toLowerCase().contains(_q.toLowerCase()) ||
              u.email.toLowerCase().contains(_q.toLowerCase()))
              .toList();
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _q = v.trim()),
                decoration: const InputDecoration(
                  hintText: 'ابحث بالاسم أو البريد...',
                  suffixIcon: Icon(Icons.search, color: AppColors.primary),
                ),
              ),
            ),
            Expanded(
              child: users.isEmpty
                  ? const Center(child: Text('لا يوجد مستخدمون'))
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        onChanged: (v) =>
                            FirestoreService.instance.setUserActive(u.uid, v),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]);
        },
      ),
    );
  }
}