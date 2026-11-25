import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/app_user.dart';
import '../../../models/pharmacy.dart';
import '../pharmacy_details/pharmacy_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final String uid;
  const FavoritesScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصيدليات المفضلة')),
      body: StreamBuilder<AppUser?>(
        stream: FirestoreService.instance.streamUser(uid),
        builder: (context, snap) {
          final ids = snap.data?.favorites ?? [];
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (ids.isEmpty) return const Center(child: Text('لم تضف أي صيدلية للمفضلة'));
          return FutureBuilder<List<Pharmacy>>(
            future: FirestoreService.instance.getPharmaciesByIds(ids),
            builder: (context, ps) {
              if (!ps.hasData) return const Center(child: CircularProgressIndicator());
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final p in ps.data!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.storefront, color: AppColors.primary),
                          title: Text(p.name),
                          subtitle: Text(p.address),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.pharmacyDetails,
                              arguments: PharmacyDetailsArgs(p)),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}