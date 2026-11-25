import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routes/app_router.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final err = await context
        .read<AuthProvider>()
        .signIn(_email.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) showSnack(context, err);
  }
  Future<void> _forgot() async {
    final c = TextEditingController(text: _email.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('استعادة كلمة المرور'),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'البريد الإلكتروني'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, c.text.trim()),
              child: const Text('إرسال')),
        ],
      ),
    );
    if (email == null || email.isEmpty || !mounted) return;
    final err = await context.read<AuthProvider>().sendPasswordReset(email);
    if (!mounted) return;
    if (err != null) {
      showSnack(context, err);
    } else {
      showSnack(context, 'تم إرسال رابط الاستعادة لبريدك', error: false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(children: [
                const Icon(Icons.medication_liquid, size: 90, color: AppColors.primary),
                const Text('فين دوائي؟',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const SizedBox(height: 8),
                const Text('سجّل دخولك للمتابعة'),
                const SizedBox(height: 28),
                AppTextField(
                    controller: _email, label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
                const SizedBox(height: 14),
                AppTextField(
                    controller: _pass, label: 'كلمة المرور',
                    icon: Icons.lock_outline, obscure: true),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _forgot,
                    child: const Text('نسيت كلمة المرور؟'),
                  ),
                ),
                const SizedBox(height: 22),
                AppButton(label: 'تسجيل الدخول', onPressed: _login, loading: _loading),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('ليس لديك حساب؟'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                    child: const Text('إنشاء حساب جديد'),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}