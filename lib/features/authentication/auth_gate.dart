import 'package:flutter/material.dart';
import '../../core/providers/auth_provider.dart';

import '../admin/admin_shell.dart';
import '../patient/patient_shell.dart';
import 'package:provider/provider.dart';
import '../pharmacist/pharmacist_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.initializing) return const _Loader();
    if (!auth.signedIn) return const LoginScreen();

    final user = auth.user;
    if (user == null) return const _Loader();

    if (!user.isActive) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.block, size: 64),
            const SizedBox(height: 12),
            const Text('تم إيقاف حسابك، تواصل مع الإدارة'),
            TextButton(onPressed: auth.signOut, child: const Text('تسجيل الخروج')),
          ]),
        ),
      );
    }

    switch (user.role) {
      case 'pharmacist':
        return PharmacistShell(user: user);
      case 'admin':
        return AdminShell(user: user);
      default:
        return PatientShell(user: user);
    }
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}