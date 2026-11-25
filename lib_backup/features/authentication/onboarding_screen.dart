import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_router.dart';
import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  static const _pages = [
    (Icons.search, 'ابحث عن دوائك', 'اكتب اسم الدواء وشوف أقرب صيدلية متوفر عندها'),
    (Icons.map, 'اعرف المسافة', 'شوف الصيدليات على الخريطة والمسافة بينك وبينها'),
    (Icons.notifications_active, 'تأكيد فوري', 'اطلب من الصيدلية تأكيد توافر الدواء وهيوصلك إشعار'),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.authGate);
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: _finish, child: const Text('تخطي')),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final p = _pages[i];
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: AppColors.lightGreen,
                      child: Icon(p.$1, size: 80, color: AppColors.primary),
                    ),
                    const SizedBox(height: 32),
                    Text(p.$2,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Text(p.$3, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: AppColors.textGrey)),
                  ]),
                );
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < _pages.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                width: i == _page ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(24),
            child: AppButton(
              label: last ? 'ابدأ الآن' : 'التالي',
              onPressed: () => last
                  ? _finish()
                  : _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            ),
          ),
        ]),
      ),
    );
  }
}