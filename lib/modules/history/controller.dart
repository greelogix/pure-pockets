import 'package:get/get.dart';
import 'dart:io';
import 'dart:async';
import '../../data/models/transaction.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

import '../dashboard/controller.dart';

class HistoryController extends GetxController {
  final DatabaseService _dbService = Get.find<DatabaseService>();
  
  // Observable list of transactions
  final RxList<Transaction> transactions = <Transaction>[].obs;
  
  // Grouped transactions: Map<DateString, List<Transaction>>
  final RxMap<String, List<Transaction>> groupedTransactions = <String, List<Transaction>>{}.obs;

  StreamSubscription? _boxSubscription;

  // Filter for specific month if passed from Dashboard
  final Rx<DateTime?> filterMonth = Rx<DateTime?>(null);
  final currencySymbol = '₹'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserCurrency();
    
    // Check for month filter argument
    if (Get.arguments is DateTime) {
      filterMonth.value = Get.arguments;
    }

    loadTransactions();
    
    // Listen for database changes to auto-refresh
    _boxSubscription = _dbService.transactionBox.watch().listen((event) {
      loadTransactions();
    });
  }
  
  @override
  void onClose() {
    _boxSubscription?.cancel();
    super.onClose();
  }

  void loadTransactions() {
    var list = _dbService.transactionBox.values.toList();
    
    // Apply month filter if present
    if (filterMonth.value != null) {
      list = list.where((tx) {
        return tx.date.year == filterMonth.value!.year &&
               tx.date.month == filterMonth.value!.month;
      }).toList();
    }

    transactions.assignAll(list);
    // Sort by date descending
    transactions.sort((a, b) => b.date.compareTo(a.date));
    _groupTransactions();
  }

  void _groupTransactions() {
    final Map<String, List<Transaction>> groups = {};
    
    for (var tx in transactions) {
      String key = _getDateKey(tx.date);
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(tx);
    }
    
    groupedTransactions.assignAll(groups);
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  void deleteTransaction(Transaction transaction) {
    if (transaction.receiptPath != null) {
      try {
        final file = File(transaction.receiptPath!); // Assuming dart:io is imported or needs to be
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print("Error deleting receipt file: $e");
      }
    }
    
    transaction.delete();
    loadTransactions(); // Refresh list
    
    // Also update Dashboard
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.loadTransactions();
    } catch (_) {}
  }

  void _loadUserCurrency() {
    final userProfile = _dbService.getUserProfile();
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
