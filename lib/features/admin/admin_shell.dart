import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import 'admin_dashboard_screen.dart';
import 'admin_profile_screen.dart';
import 'reports_screen.dart';

class AdminShell extends StatefulWidget {
  final AppUser user;
  const AdminShell({super.key, required this.user});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AdminDashboardScreen(),
      const ReportsScreen(),
      AdminProfileScreen(user: widget.user),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'التقارير'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'الملف'),
        ],
      ),
    );
  }
}