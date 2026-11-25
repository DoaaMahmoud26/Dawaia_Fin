import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../models/app_user.dart';
import 'medicine_requests_screen.dart';
import 'pharmacist_dashboard_screen.dart';
import 'pharmacy_profile_screen.dart';

class PharmacistShell extends StatefulWidget {
  final AppUser user;
  const PharmacistShell({super.key, required this.user});
  @override
  State<PharmacistShell> createState() => _PharmacistShellState();
}

class _PharmacistShellState extends State<PharmacistShell> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.init(widget.user.uid); // استقبال إشعارات طلبات المرضى
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      PharmacistDashboardScreen(user: widget.user),
      MedicineRequestsScreen(pharmacyId: widget.user.uid),
      PharmacyProfileScreen(user: widget.user),
    ];
    return Scaffold(
      body: IndexedStack(index: _i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'الطلبات'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'الصيدلية'),
        ],
      ),
    );
  }
}