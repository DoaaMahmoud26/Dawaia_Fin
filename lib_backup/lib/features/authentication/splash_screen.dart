import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacementNamed(
        context, seen ? AppRoutes.authGate : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.lightGreen, Colors.white, AppColors.secondary],
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.medication_liquid, size: 110, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text('فين دوائي؟',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(height: 8),
          const Text('دواؤك أقرب مما تتخيل',
              style: TextStyle(fontSize: 18, color: AppColors.primary)),
          const SizedBox(height: 40),
          const CircularProgressIndicator(color: AppColors.primary),
        ]),
      ),
    );
  }
}