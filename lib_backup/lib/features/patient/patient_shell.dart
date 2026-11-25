import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../models/app_user.dart';
import 'home/home_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';

class PatientShell extends StatefulWidget {
  final AppUser user;
  const PatientShell({super.key, required this.user});
  @override
  State<PatientShell> createState() => _PatientShellState();
}

class _PatientShellState extends State<PatientShell> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.init(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      NotificationsScreen(uid: widget.user.uid),
      ProfileScreen(user: widget.user),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'الإشعارات'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'الملف'),
        ],
      ),
    );
  }
}