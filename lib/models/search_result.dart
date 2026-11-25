import 'medicine.dart';
import 'pharmacy.dart';

class SearchResult {
  final Medicine medicine;
  final Pharmacy pharmacy;
  final double? distanceKm;
  SearchResult(this.medicine, this.pharmacy, this.distanceKm);
}