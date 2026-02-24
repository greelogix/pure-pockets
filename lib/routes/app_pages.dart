import 'package:get/get.dart';
import '../modules/splash/binding.dart';
import '../modules/splash/view.dart';
import '../modules/onboarding/binding.dart';
import '../modules/onboarding/view.dart';
import '../modules/dashboard/binding.dart';
import '../modules/dashboard/view.dart';
import '../modules/transaction_entry/binding.dart';
import '../modules/transaction_entry/view.dart';
import '../modules/review_extraction/binding.dart';
import '../modules/review_extraction/view.dart';
import '../modules/history/binding.dart';
import '../modules/history/view.dart';
import '../modules/analytics/binding.dart';
import '../modules/analytics/view.dart';
import '../modules/all_months/binding.dart';
import '../modules/all_months/view.dart';
import '../modules/settings/binding.dart';
import '../modules/settings/view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.TRANSACTION_ENTRY,
      page: () => const TransactionEntryView(),
      binding: TransactionEntryBinding(),
    ),
    GetPage(
      name: Routes.REVIEW_EXTRACTION,
      page: () => const ReviewExtractionView(),
      binding: ReviewExtractionBinding(),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.ANALYTICS,
      page: () => const AnalyticsView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: Routes.ALL_MONTHS,
      page: () => const AllMonthsView(),
      binding: AllMonthsBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
