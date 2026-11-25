import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_button.dart';
import 'package:provider/provider.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  final _focus = FocusNode();

  void _doSearch() {
    final q = _search.text.trim();
    if (q.isEmpty) return showSnack(context, 'اكتب اسم الدواء أولًا');
    Navigator.pushNamed(context, AppRoutes.searchResults, arguments: q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فين دوائي؟')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.lightGreen, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('دواؤك أقرب مما تتخيل',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('ابحث عن دوائك واعرف أقرب صيدلية توفره.',
                    style: TextStyle(color: AppColors.textGrey)),
              ]),
            ),
            const Icon(Icons.medication_liquid, size: 70, color: AppColors.primary),
          ]),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _doSearch(),
          decoration: const InputDecoration(
            hintText: 'ابحث عن اسم الدواء...',
            suffixIcon: Icon(Icons.search, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        AppButton(label: 'ابحث الآن', onPressed: _doSearch),
        Builder(builder: (context) {
          final history = context.watch<SearchProvider>().history;
          if (history.isEmpty) return const SizedBox();
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            Row(children: [
              const Text('عمليات البحث السابقة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () => context.read<SearchProvider>().clearHistory(),
                child: const Text('مسح'),
              ),
            ]),
            Wrap(spacing: 8, children: [
              for (final q in history)
                ActionChip(
                  avatar: const Icon(Icons.history, size: 16),
                  label: Text(q),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.searchResults, arguments: q),
                ),
            ]),
          ]);
        }),
        const SizedBox(height: 24),
        const Text('الخدمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _ServiceCard(
              icon: Icons.map_outlined,
              label: 'أقرب صيدليات',
              onTap: () => Navigator.pushNamed(context, AppRoutes.map),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ServiceCard(
              icon: Icons.medication_outlined,
              label: 'الدواء المتوفر',
              onTap: () => _focus.requestFocus(),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Row(children: [
            Icon(Icons.favorite, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Text('نصائح صحية: اشرب الماء بانتظام ولا تستخدم دواء بدون استشارة الصيدلي.'),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ServiceCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label),
        ]),
      ),
    );
  }
}