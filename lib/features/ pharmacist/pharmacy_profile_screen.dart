import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/app_user.dart';
import '../../models/pharmacy.dart';

class PharmacyProfileScreen extends StatelessWidget {
  final AppUser user;
  const PharmacyProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملف الصيدلية')),
      body: StreamBuilder<Pharmacy?>(
        stream: FirestoreService.instance.streamPharmacy(user.uid),
        builder: (context, snap) {
          final p = snap.data;
          if (p == null) return const Center(child: CircularProgressIndicator());
          return _Form(pharmacy: p);
        },
      ),
    );
  }
}

class _Form extends StatefulWidget {
  final Pharmacy pharmacy;
  const _Form({required this.pharmacy});
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final _name = TextEditingController(text: widget.pharmacy.name);
  late final _address = TextEditingController(text: widget.pharmacy.address);
  late final _phone = TextEditingController(text: widget.pharmacy.phone);

  Future<void> _save() async {
    await FirestoreService.instance.updatePharmacy(widget.pharmacy.id, {
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'phone': _phone.text.trim(),
    });
    if (mounted) showSnack(context, 'تم الحفظ', error: false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      AppTextField(controller: _name, label: 'اسم الصيدلية', icon: Icons.storefront),
      const SizedBox(height: 12),
      AppTextField(controller: _address, label: 'العنوان', icon: Icons.location_on_outlined),
      const SizedBox(height: 12),
      AppTextField(controller: _phone, label: 'الهاتف', icon: Icons.phone, keyboard: TextInputType.phone),
      const SizedBox(height: 20),
      AppButton(label: 'حفظ التعديلات', onPressed: _save),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: AuthService.instance.signOut,
        icon: const Icon(Icons.logout),
        label: const Text('تسجيل الخروج'),
      ),
    ]);
  }
}