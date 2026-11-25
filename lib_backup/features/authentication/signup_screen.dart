import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/providers/auth_provider.dart';




class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _pharmacyName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  String _role = 'patient';
  bool _loading = false;

  Future<void> _signUp() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final err = await context.read<AuthProvider>().signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _pass.text,
        role: _role,
        pharmacyName: _pharmacyName.text.trim(),
        address: _address.text.trim(),
        phone: _phone.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (err != null) {
        showSnack(context, err);
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) showSnack(context, AuthService.message(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPharmacist = _role == 'pharmacist';
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.lightGreen,
              child: Icon(Icons.person, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'patient', label: Text('مريض'), icon: Icon(Icons.person)),
                ButtonSegment(value: 'pharmacist', label: Text('صيدلي'), icon: Icon(Icons.local_pharmacy)),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _name, label: 'الاسم الكامل', icon: Icons.person_outline),
            const SizedBox(height: 12),
            AppTextField(
                controller: _email, label: 'البريد الإلكتروني',
                icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            AppTextField(
              controller: _pass, label: 'كلمة المرور', icon: Icons.lock_outline, obscure: true,
              validator: (v) => (v == null || v.length < 6) ? '6 أحرف على الأقل' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _confirm, label: 'تأكيد كلمة المرور', icon: Icons.lock_outline, obscure: true,
              validator: (v) => v != _pass.text ? 'كلمتا المرور غير متطابقتين' : null,
            ),
            if (isPharmacist) ...[
              const SizedBox(height: 12),
              AppTextField(controller: _pharmacyName, label: 'اسم الصيدلية', icon: Icons.storefront),
              const SizedBox(height: 12),
              AppTextField(controller: _address, label: 'العنوان', icon: Icons.location_on_outlined),
              const SizedBox(height: 12),
              AppTextField(
                  controller: _phone, label: 'رقم الهاتف',
                  icon: Icons.phone_outlined, keyboard: TextInputType.phone),
              const SizedBox(height: 8),
              const Text('سيتم تحديد موقع الصيدلية من موقعك الحالي، وتحتاج لاعتماد الأدمن.',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
            const SizedBox(height: 22),
            AppButton(label: 'إنشاء الحساب', onPressed: _signUp, loading: _loading),
          ]),
        ),
      ),
    );
  }
}