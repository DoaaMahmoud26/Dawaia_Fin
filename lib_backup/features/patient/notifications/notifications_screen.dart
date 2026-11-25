import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/app_notification.dart';

class NotificationsScreen extends StatelessWidget {
  final String uid;
  const NotificationsScreen({super.key, required this.uid});

  (IconData, Color) _style(String type) {
    switch (type) {
      case 'success':
        return (Icons.check_circle, AppColors.success);
      case 'warning':
        return (Icons.notifications, AppColors.warning);
      default:
        return (Icons.info, AppColors.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: StreamBuilder<List<AppNotification>>(
        stream: FirestoreService.instance.streamNotifications(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('لا توجد إشعارات'));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = list[i];
              final s = _style(n.type);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s.$2.withOpacity(0.15),
                    child: Icon(s.$1, color: s.$2),
                  ),
                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${n.body}\n${timeAgo(n.createdAt)}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}