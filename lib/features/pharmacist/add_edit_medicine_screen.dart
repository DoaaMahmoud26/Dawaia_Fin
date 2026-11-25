import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/medicine.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddEditMedicineScreen({super.key, this.medicine});
  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.medicine?.name);
  late final _price = TextEditingController(text: widget.medicine?.price.toString());
  late final _qty = TextEditingController(text: widget.medicine?.quantity.toString());
  late bool _available = widget.medicine?.available ?? true;
  bool _loading = false;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirestoreService.instance.saveMedicine(Medicine(
        id: widget.medicine?.id ?? '',
        pharmacyId: FirebaseAuth.instance.currentUser!.uid,
        name: _name.text.trim(),
        price: double.tryParse(_price.text) ?? 0,
        quantity: int.tryParse(_qty.text) ?? 0,
        available: _available,
      ));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) showSnack(context, 'تعذر الحفظ');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.medicine == null ? 'إضافة دواء' : 'تعديل دواء')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(children: [
            AppTextField(controller: _name, label: 'اسم الدواء', icon: Icons.medication),
            const SizedBox(height: 12),
            AppTextField(controller: _price, label: 'السعر', icon: Icons.payments, keyboard: TextInputType.number),
            const SizedBox(height: 12),
            AppTextField(controller: _qty, label: 'الكمية', icon: Icons.numbers, keyboard: TextInputType.number),
            SwitchListTile(
              value: _available,
              onChanged: (v) => setState(() => _available = v),
              title: const Text('متوفر'),
            ),
            const SizedBox(height: 12),
            AppButton(label: 'حفظ', onPressed: _save, loading: _loading),
          ]),
        ),
      ),
    );
  }
}