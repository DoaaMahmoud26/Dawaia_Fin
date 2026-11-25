import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/app_user.dart';
import 'favorites_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملفي الشخصي')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const SizedBox(height: 8),
        const Center(
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.lightGreen,
            child: Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Center(child: Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        Center(child: Text(user.email, style: const TextStyle(color: AppColors.textGrey))),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite, color: AppColors.primary),
            title: const Text('المفضلة'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => FavoritesScreen(uid: user.uid))),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
            title: const Text('الإعدادات'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
            onTap: AuthService.instance.signOut,
          ),
        ),
      ]),
    );
  }
}