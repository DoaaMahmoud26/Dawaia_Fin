import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/search_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../pharmacy_details/pharmacy_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});
  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = context.read<LocationProvider>();
      final search = context.read<SearchProvider>();
      if (loc.position == null) await loc.refresh();
      await search.search(widget.query, loc.position);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SearchProvider>();
    final list = sp.results;

    return Scaffold(
      appBar: AppBar(title: const Text('نتائج البحث')),
      body: sp.loading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
          ? Center(child: Text('لا توجد صيدليات توفر "${widget.query}" حاليًا'))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          if (i == 0) {
            return Text('تم العثور على ${list.length} صيدلية',
                style: const TextStyle(color: AppColors.textGrey));
          }
          final r = list[i - 1];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.storefront, color: AppColors.primary),
              ),
              title: Text(r.pharmacy.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  '${r.medicine.name} • ${r.medicine.price.toStringAsFixed(0)} ج.م\n${formatDistance(r.distanceKm)}'),
              isThreeLine: true,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('متوفر',
                    style: TextStyle(
                        color: AppColors.success, fontWeight: FontWeight.bold)),
              ),
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.pharmacyDetails,
                arguments: PharmacyDetailsArgs(r.pharmacy,
                    medicineName: r.medicine.name),
              ),
            ),
          );
        },
      ),
    );
  }
}