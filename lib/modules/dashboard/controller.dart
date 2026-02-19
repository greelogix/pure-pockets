import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_buddy/modules/dashboard/view.dart';
import '../../routes/app_routes.dart';
import '../../services/database_service.dart';
import '../../data/models/transaction.dart';
import '../../data/models/user_profile.dart';

class DashboardController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();
  
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final balance = 0.0.obs;
  final currencySymbol = '₹'.obs;
  
  final transactions = <Transaction>[].obs;
  final filteredTransactions = <Transaction>[].obs;
  final selectedMonth = DateTime.now().obs;
  final weeklyTrendPoints = <FlSpot>[].obs;
  
  final savingsTarget = 0.0.obs;
  final savingsProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserCurrency();
    loadTransactions();
  }

  void _loadUserCurrency() {
    final userProfile = _db.getUserProfile();
    if (userProfile != null) {
      final currencyMap = {
        'INR': '₹', 'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥',
        'AUD': 'A\$', 'CAD': 'C\$', 'CNY': '¥', 'BRL': 'R\$', 'CHF': 'CHF',
        'HKD': 'HK\$', 'SGD': 'S\$', 'NZD': 'NZ\$', 'KRW': '₩', 'MXN': '\$',
        'ZAR': 'R', 'THB': '฿', 'PHP': '₱', 'IDR': 'Rp', 'MYR': 'RM',
        'TRY': '₺', 'RUB': '₽', 'PLN': 'zł', 'SEK': 'kr', 'NOK': 'kr',
        'DKK': 'kr', 'CZK': 'Kč', 'HUF': 'Ft', 'ILS': '₪', 'AED': 'د.إ',
        'SAR': 'ر.س', 'QAR': 'ر.ق', 'KWD': 'د.ك', 'BHD': 'ب.د', 'OMR': 'ر.ع.',
        'EGP': 'E£', 'NGN': '₦', 'PKR': '₨', 'LKR': 'Rs', 'BDT': '৳',
        'VND': '₫', 'TWD': 'NT\$', 'UAH': '₴', 'RON': 'lei', 'ISK': 'kr',
      };
      currencySymbol.value = currencyMap[userProfile.currency] ?? '₹';
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadTransactions();
    _checkWelcome();
    
    // Trigger Quick Action Popup on fresh launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQuickActionPopup();
    });
  }

  void _showQuickActionPopup() {
    // Only show if we're not currently showing the onboarding welcome dialog
    final args = Get.arguments;
    if (args != null && args is Map && args['showWelcome'] == true) return;

    // Use a static flag to ensure it only shows once per process lifetime
    if (_hasShownQuickActions) return;
    _hasShownQuickActions = true;

    // The View will call showQuickActionBottomSheet
    // We can bridge this or just let the View handle the trigger via a controller method
    if (Get.currentRoute == Routes.DASHBOARD || Get.currentRoute == '/') {
       DashboardView.showQuickActionPopup();
    }
  }

  static bool _hasShownQuickActions = false;

  void _checkWelcome() {
    // Check if we came from onboarding
    final args = Get.arguments;
    if (args != null && args is Map && args['showWelcome'] == true) {
      final name = args['name'] ?? 'User';
      
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome, $name!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your financial journey starts now. We\'ve set up your profile and are ready to help you save more!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Let\'s Start!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      });
    }
  }

  @override
  void onResume() {
    loadTransactions();
  }

  void loadTransactions() {
    transactions.value = _db.transactionBox.values.toList();
    _filterByMonth();
    _calculateWeeklyTrend();
  }

  void _filterByMonth() {
    final list = transactions.where((tx) {
      return tx.date.year == selectedMonth.value.year &&
             tx.date.month == selectedMonth.value.month;
    }).toList();
    
    // Sort by date descending so recent ones are at the top
    list.sort((a, b) => b.date.compareTo(a.date));
    filteredTransactions.value = list;
    _calculateTotals();
  }

  void _calculateTotals() {
    double income = 0.0;
    double expense = 0.0;

    final userProfile = _db.getUserProfile();
    if (userProfile != null) {
      income += userProfile.monthlyIncome;
    }

    for (var transaction in filteredTransactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    balance.value = income - expense;

    if (userProfile != null) {
      final monthKey = DateFormat('yyyy-MM').format(selectedMonth.value);
      final monthlyTarget = _db.monthlyGoalsBox.get(monthKey);
      
      savingsTarget.value = monthlyTarget ?? userProfile.savingsTarget;
      
      if (savingsTarget.value > 0) {
        // Savings progress is based on the remaining balance (income - expense)
        // toward the savings target.
        double progress = balance.value / savingsTarget.value;
        savingsProgress.value = progress.clamp(0.0, 1.0);
      } else {
        savingsProgress.value = 0.0;
      }
    }
  }

  void _calculateWeeklyTrend() {
    // We'll show the last 7 days of spending
    List<FlSpot> points = [];
    DateTime now = DateTime.now();
    
    // If we're looking at a past month, use the last day of that month as the end point
    DateTime endPoint = (selectedMonth.value.year == now.year && selectedMonth.value.month == now.month)
        ? now
        : DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0);

    for (int i = 6; i >= 0; i--) {
      DateTime date = endPoint.subtract(Duration(days: i));
      double dailyTotal = transactions
          .where((tx) => !tx.isIncome && 
                         tx.date.year == date.year && 
                         tx.date.month == date.month && 
                         tx.date.day == date.day)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      
      points.add(FlSpot((6 - i).toDouble(), dailyTotal));
    }
    
    weeklyTrendPoints.value = points;
  }

  void changeMonth(DateTime newMonth) {
    selectedMonth.value = newMonth;
    _filterByMonth();
    _calculateWeeklyTrend();
  }

  void previousMonth() {
    changeMonth(DateTime(selectedMonth.value.year, selectedMonth.value.month - 1));
  }

  void nextMonth() {
    final next = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1);
    final now = DateTime.now();
    if (next.isAfter(DateTime(now.year, now.month))) return;
    
    changeMonth(next);
  }

  bool get isNextDisabled {
    final now = DateTime.now();
    return selectedMonth.value.year >= now.year && selectedMonth.value.month >= now.month;
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _db.transactionBox.add(transaction);
    // Explicitly set the dashboard to the transaction's month for immediate feedback
    selectedMonth.value = DateTime(transaction.date.year, transaction.date.month);
    loadTransactions();
  }

  Future<void> updateSavingsTarget(double newTarget) async {
    final monthKey = DateFormat('yyyy-MM').format(selectedMonth.value);
    await _db.monthlyGoalsBox.put(monthKey, newTarget);
    _calculateTotals();
  }
}

