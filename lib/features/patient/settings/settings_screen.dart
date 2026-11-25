import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/helpers.dart';


class SettingsScreen extends StatefulWidget {
  final bool showLocation;
  const SettingsScreen({super.key, this.showLocation = true});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notif = true;

  @override
  void initState() {
    super.initState();
    NotificationService.isEnabled().then((v) {
      if (mounted) setState(() => _notif = v);
    });
  }

  Future<void> _toggleNotif(bool v) async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    setState(() => _notif = v);
    try {
      await NotificationService.setEnabled(uid, v);
    } catch (_) {
      if (!mounted) return;
      setState(() => _notif = !v);
      showSnack(context, 'تعذر تغيير الإعداد');
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().signOut();
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (widget.showLocation) ...[
          const SizedBox(height: 10),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.location_on_outlined, color: AppColors.primary),
              title: const Text('الموقع الجغرافي'),
              subtitle: const Text('استخدام GPS لتحديد موقعك'),
              value: loc.useGps,
              activeColor: AppColors.primary,
              onChanged: (v) => context.read<LocationProvider>().setUseGps(v),
            ),
          ),
          if (loc.hasManual) ...[
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.edit_location_alt, color: AppColors.info),
                title: const Text('موقعك محدد يدويًا'),
                subtitle: const Text('اضغط لإلغاء الموقع اليدوي'),
                trailing: const Icon(Icons.close),
                onTap: () {
                  context.read<LocationProvider>().clearManual();
                  showSnack(context, 'تم إلغاء الموقع اليدوي', error: false);
                },
              ),
            ),
          ],
        ],
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: const Text('اللغة العربية'),
            trailing: const Icon(Icons.check, color: AppColors.success),
            onTap: () => showSnack(context, 'التطبيق متاح بالعربية حاليًا', error: false),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.primary),
            title: const Text('مساعدة ودعم'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('مساعدة ودعم'),
                content: const Text(
                    'لأي استفسار أو مشكلة تواصل معنا على:\nsupport@findawaie.com'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('حسنًا')),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const Text('عن التطبيق'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'فين دوائي؟',
              applicationVersion: '1.0.0',
              children: const [Text('دواؤك أقرب مما تتخيل')],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
            onTap: _logout,
          ),
        ),
      ]),
    );
  }
}