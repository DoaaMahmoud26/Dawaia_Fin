import 'package:flutter/material.dart';

import '../../features/ pharmacist/add_edit_medicine_screen.dart';
import '../../features/ pharmacist/inventory_screen.dart';
import '../../features/admin/pharmacies_management_screen.dart';
import '../../features/admin/reports_screen.dart';
import '../../features/admin/users_management_screen.dart';
import '../../features/authentication/auth_gate.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/onboarding_screen.dart';
import '../../features/authentication/signup_screen.dart';
import '../../features/authentication/splash_screen.dart';
import '../../features/patient/map/map_screen.dart';
import '../../features/patient/pharmacy_details/pharmacy_details_screen.dart';
import '../../features/patient/search/search_results_screen.dart';
import '../../models/medicine.dart';
import '../../models/pharmacy.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const authGate = '/gate';
  static const login = '/login';
  static const signup = '/signup';
  static const searchResults = '/search';
  static const pharmacyDetails = '/pharmacy';
  static const map = '/map';
  static const inventory = '/inventory';
  static const editMedicine = '/edit-medicine';
  static const adminUsers = '/admin/users';
  static const adminPharmacies = '/admin/pharmacies';
  static const adminReports = '/admin/reports';
}

class AppRouter {
  static Route<dynamic> generate(RouteSettings s) {
    Widget page;
    switch (s.name) {
      case AppRoutes.splash:
        page = const SplashScreen();
        break;
      case AppRoutes.onboarding:
        page = const OnboardingScreen();
        break;
      case AppRoutes.authGate:
        page = const AuthGate();
        break;
      case AppRoutes.login:
        page = const LoginScreen();
        break;
      case AppRoutes.signup:
        page = const SignUpScreen();
        break;
      case AppRoutes.searchResults:
        page = SearchResultsScreen(query: s.arguments as String);
        break;
      case AppRoutes.pharmacyDetails:
        page = PharmacyDetailsScreen(args: s.arguments as PharmacyDetailsArgs);
        break;
      case AppRoutes.map:
        page = MapScreen(focus: s.arguments as Pharmacy?);
        break;
      case AppRoutes.inventory:
        page = const InventoryScreen();
        break;
      case AppRoutes.editMedicine:
        page = AddEditMedicineScreen(medicine: s.arguments as Medicine?);
        break;
      case AppRoutes.adminUsers:
        page = const UsersManagementScreen();
        break;
      case AppRoutes.adminPharmacies:
        page = const PharmaciesManagementScreen();
        break;
      case AppRoutes.adminReports:
        page = const ReportsScreen();
        break;
      default:
        page = const AuthGate();
    }
    return MaterialPageRoute(builder: (_) => page, settings: s);
  }
}