import 'package:get/get.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/models/transaction.dart';
import '../../services/database_service.dart';

class AnalyticsController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxList<Transaction> todayTransactions = <Transaction>[].obs;
  final RxList<Transaction> weeklyTransactions = <Transaction>[].obs;
  final RxList<Transaction> monthlyTransactions = <Transaction>[].obs;

  final RxInt currentTab = 0.obs; // 0: Today, 1: Week, 2: Month
  final RxInt selectedMonthOffset = 0.obs; // 0 = Current month
  final isTransactionListExpanded = false.obs;
  final currencySymbol = '₹'.obs;
  
  StreamSubscription? _boxSubscription;

  @override
  void onInit() {
    super.onInit();
    _loadUserCurrency();
    loadTransactions();
    
    // Listen for database changes to auto-refresh
    _boxSubscription = _db.transactionBox.watch().listen((event) {
      loadTransactions();
    });
  }
  
  @override
  void onClose() {
    _boxSubscription?.cancel();
    super.onClose();
  }
  
  void onTabChanged(int index) {
    currentTab.value = index;
    isTransactionListExpanded.value = false;
  }

  void loadTransactions() {
    transactions.assignAll(_db.transactionBox.values.toList());
    _filterTransactions();
  }

  void _filterTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Today
    final todayList = transactions.where((tx) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      return txDate.isAtSameMomentAs(today);
    }).toList();
    todayList.sort((a, b) => b.date.compareTo(a.date));
    todayTransactions.assignAll(todayList);

    // Week
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));
    
    final weekList = transactions.where((tx) {
      return tx.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && 
             tx.date.isBefore(endOfWeek.add(const Duration(seconds: 1)));
    }).toList();
    weekList.sort((a, b) => b.date.compareTo(a.date));
    weeklyTransactions.assignAll(weekList);

    // Month (Interactive)
    final targetMonth = DateTime(now.year, now.month + selectedMonthOffset.value);
    final monthList = transactions.where((tx) {
      return tx.date.year == targetMonth.year && tx.date.month == targetMonth.month;
    }).toList();
    monthList.sort((a, b) => b.date.compareTo(a.date));
    monthlyTransactions.assignAll(monthList);
  }

  void nextMonth() {
    if (selectedMonthOffset.value < 0) {
      selectedMonthOffset.value++;
      _filterTransactions();
    }
  }

  void prevMonth() {
    selectedMonthOffset.value--;
    _filterTransactions();
  }
  
  String get currentMonthName {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month + selectedMonthOffset.value);
    return DateFormat('MMMM yyyy').format(target);
  }

  // --- Stats Helpers ---

  List<Transaction> get currentList {
    switch (currentTab.value) {
      case 0: return todayTransactions;
      case 1: return weeklyTransactions;
      case 2: return monthlyTransactions;
      default: return [];
    }
  }

  double getTotalSpent() {
    return currentList
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  Transaction? getTopExpense() {
    final expenses = currentList.where((tx) => !tx.isIncome).toList();
    if (expenses.isEmpty) return null;
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    return expenses.first;
  }

  List<PieChartSectionData> getCategoryBreakdown() {
    final expenses = currentList.where((tx) => !tx.isIncome).toList();
    if (expenses.isEmpty) return [];

    final Map<String, double> categoryTotals = {};
    double total = 0;

    for (var tx in expenses) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
      total += tx.amount;
    }

    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.amber, Colors.teal, Colors.indigo
    ];

    int colorIndex = 0;
    return categoryTotals.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
  
  // Helper to get legend data
  Map<String, Color> getCategoryColors() {
    final expenses = currentList.where((tx) => !tx.isIncome).toList();
    final Map<String, double> categoryTotals = {};
     for (var tx in expenses) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
    }
    
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, 
      Colors.purple, Colors.amber, Colors.teal, Colors.indigo
    ];
    
    final Map<String, Color> map = {};
    int index = 0;
    for (var cat in categoryTotals.keys) {
      map[cat] = colors[index % colors.length];
      index++;
    }
    return map;
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
}
