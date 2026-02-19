import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/database_service.dart';
import '../../data/models/user_profile.dart';

class OnboardingController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  final currentStep = 0.obs;
  final nameController = TextEditingController();
  final monthlyIncomeController = TextEditingController();
  final savingsTargetController = TextEditingController();
  final selectedCountry = 'India'.obs;

  // Comprehensive list of countries with their currencies
  final countries = {
    'Afghanistan': {'currency': 'AFN', 'symbol': '؋'},
    'Albania': {'currency': 'ALL', 'symbol': 'L'},
    'Algeria': {'currency': 'DZD', 'symbol': 'د.ج'},
    'Argentina': {'currency': 'ARS', 'symbol': '\$'},
    'Australia': {'currency': 'AUD', 'symbol': 'A\$'},
    'Austria': {'currency': 'EUR', 'symbol': '€'},
    'Bahrain': {'currency': 'BHD', 'symbol': 'ب.د'},
    'Bangladesh': {'currency': 'BDT', 'symbol': '৳'},
    'Belgium': {'currency': 'EUR', 'symbol': '€'},
    'Brazil': {'currency': 'BRL', 'symbol': 'R\$'},
    'Canada': {'currency': 'CAD', 'symbol': 'C\$'},
    'Chile': {'currency': 'CLP', 'symbol': '\$'},
    'China': {'currency': 'CNY', 'symbol': '¥'},
    'Colombia': {'currency': 'COP', 'symbol': '\$'},
    'Czech Republic': {'currency': 'CZK', 'symbol': 'Kč'},
    'Denmark': {'currency': 'DKK', 'symbol': 'kr'},
    'Egypt': {'currency': 'EGP', 'symbol': 'E£'},
    'Finland': {'currency': 'EUR', 'symbol': '€'},
    'France': {'currency': 'EUR', 'symbol': '€'},
    'Germany': {'currency': 'EUR', 'symbol': '€'},
    'Greece': {'currency': 'EUR', 'symbol': '€'},
    'Hong Kong': {'currency': 'HKD', 'symbol': 'HK\$'},
    'Hungary': {'currency': 'HUF', 'symbol': 'Ft'},
    'Iceland': {'currency': 'ISK', 'symbol': 'kr'},
    'India': {'currency': 'INR', 'symbol': '₹'},
    'Indonesia': {'currency': 'IDR', 'symbol': 'Rp'},
    'Iran': {'currency': 'IRR', 'symbol': '﷼'},
    'Iraq': {'currency': 'IQD', 'symbol': 'ع.د'},
    'Ireland': {'currency': 'EUR', 'symbol': '€'},
    'Israel': {'currency': 'ILS', 'symbol': '₪'},
    'Italy': {'currency': 'EUR', 'symbol': '€'},
    'Japan': {'currency': 'JPY', 'symbol': '¥'},
    'Jordan': {'currency': 'JOD', 'symbol': 'د.ا'},
    'Kenya': {'currency': 'KES', 'symbol': 'KSh'},
    'Kuwait': {'currency': 'KWD', 'symbol': 'د.ك'},
    'Malaysia': {'currency': 'MYR', 'symbol': 'RM'},
    'Mexico': {'currency': 'MXN', 'symbol': '\$'},
    'Morocco': {'currency': 'MAD', 'symbol': 'د.م.'},
    'Netherlands': {'currency': 'EUR', 'symbol': '€'},
    'New Zealand': {'currency': 'NZD', 'symbol': 'NZ\$'},
    'Nigeria': {'currency': 'NGN', 'symbol': '₦'},
    'Norway': {'currency': 'NOK', 'symbol': 'kr'},
    'Oman': {'currency': 'OMR', 'symbol': 'ر.ع.'},
    'Pakistan': {'currency': 'PKR', 'symbol': '₨'},
    'Peru': {'currency': 'PEN', 'symbol': 'S/.'},
    'Philippines': {'currency': 'PHP', 'symbol': '₱'},
    'Poland': {'currency': 'PLN', 'symbol': 'zł'},
    'Portugal': {'currency': 'EUR', 'symbol': '€'},
    'Qatar': {'currency': 'QAR', 'symbol': 'ر.ق'},
    'Romania': {'currency': 'RON', 'symbol': 'lei'},
    'Russia': {'currency': 'RUB', 'symbol': '₽'},
    'Saudi Arabia': {'currency': 'SAR', 'symbol': 'ر.س'},
    'Singapore': {'currency': 'SGD', 'symbol': 'S\$'},
    'South Africa': {'currency': 'ZAR', 'symbol': 'R'},
    'South Korea': {'currency': 'KRW', 'symbol': '₩'},
    'Spain': {'currency': 'EUR', 'symbol': '€'},
    'Sri Lanka': {'currency': 'LKR', 'symbol': 'Rs'},
    'Sweden': {'currency': 'SEK', 'symbol': 'kr'},
    'Switzerland': {'currency': 'CHF', 'symbol': 'CHF'},
    'Taiwan': {'currency': 'TWD', 'symbol': 'NT\$'},
    'Thailand': {'currency': 'THB', 'symbol': '฿'},
    'Turkey': {'currency': 'TRY', 'symbol': '₺'},
    'Ukraine': {'currency': 'UAH', 'symbol': '₴'},
    'United Arab Emirates': {'currency': 'AED', 'symbol': 'د.إ'},
    'United Kingdom': {'currency': 'GBP', 'symbol': '£'},
    'United States': {'currency': 'USD', 'symbol': '\$'},
    'Vietnam': {'currency': 'VND', 'symbol': '₫'},
  };

  final nameError = RxnString();
  final incomeError = RxnString();
  final savingsError = RxnString();

  String get selectedCurrency {
    return countries[selectedCountry.value]?['currency'] ?? 'INR';
  }

  void nextStep() {
    if (currentStep.value < 3) {
      if (_validateCurrentStep()) {
        currentStep.value++;
      }
    } else {
      if (_validateCurrentStep()) {
        _completeOnboarding();
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  bool _validateCurrentStep() {
    // Clear previous errors
    nameError.value = null;
    incomeError.value = null;
    savingsError.value = null;

    switch (currentStep.value) {
      case 0:
        if (nameController.text.trim().isEmpty) {
          nameError.value = 'Please enter your beautiful name';
          return false;
        }
        break;
      case 1:
        return true;
      case 2:
        final income = double.tryParse(monthlyIncomeController.text);
        if (monthlyIncomeController.text.trim().isEmpty || income == null || income <= 0) {
          incomeError.value = 'Please enter a valid monthly income';
          return false;
        }
        break;
      case 3:
        final savings = double.tryParse(savingsTargetController.text);
        final income = double.tryParse(monthlyIncomeController.text) ?? 0;
        if (savingsTargetController.text.trim().isEmpty || savings == null || savings <= 0) {
          savingsError.value = 'Please enter a valid savings target';
          return false;
        }
        if (savings > income) {
          savingsError.value = 'Savings target cannot exceed your income';
          return false;
        }
        break;
    }
    return true;
  }

  Future<void> _completeOnboarding() async {
    final profile = UserProfile(
      name: nameController.text.trim(),
      monthlyIncome: double.parse(monthlyIncomeController.text),
      savingsTarget: double.parse(savingsTargetController.text),
      country: selectedCountry.value,
      currency: selectedCurrency,
      onboardingCompleted: true,
    );

    await _db.saveUserProfile(profile);
    // Navigate to dashboard and pass the welcome flag
    Get.offAllNamed('/dashboard', arguments: {'showWelcome': true, 'name': profile.name});
  }

  @override
  void onClose() {
    nameController.dispose();
    monthlyIncomeController.dispose();
    savingsTargetController.dispose();
    super.onClose();
  }
}
