import 'package:get/get.dart';
import '../../data/models/transaction.dart';
import '../../services/database_service.dart';

class MonthSummary {
  final DateTime month;
  final double income;
  final double expense;

  MonthSummary({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}

class AllMonthsController extends GetxController {
  final DatabaseService _db = Get.find<DatabaseService>();

  final RxList<Transaction> allTransactions = <Transaction>[].obs;
  final RxList<MonthSummary> monthSummaries = <MonthSummary>[].obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxString currencySymbol = '₹'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserCurrency();
    loadData();
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

  void loadData() {
    allTransactions.assignAll(_db.transactionBox.values.toList());
    _calculateGlobalStats();
  }

  void _calculateGlobalStats() {
    double globalIncome = 0;
    double globalExpense = 0;

    // We need to account for the base monthly income. 
    // Since this is a global overview, how do we handle "Monthly Income"?
    // Typically, we'd multiply it by the number of months that have transactions.
    // Or just show transaction-based net. Let's include the base income for each month that has data.

    final Map<String, List<Transaction>> grouped = {};
    for (var tx in allTransactions) {
      final key = '${tx.date.year}-${tx.date.month}';
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(tx);
    }

    final userProfile = _db.getUserProfile();
    final baseMonthlyIncome = userProfile?.monthlyIncome ?? 0;

    final List<MonthSummary> summaries = [];
    double totalNet = 0;

    // Get all months from the grouped keys
    final keys = grouped.keys.toList();
    // Sort keys descending
    keys.sort((a, b) {
       final splitA = a.split('-');
       final splitB = b.split('-');
       final dateA = DateTime(int.parse(splitA[0]), int.parse(splitA[1]));
       final dateB = DateTime(int.parse(splitB[0]), int.parse(splitB[1]));
       return dateB.compareTo(dateA);
    });

    for (var key in keys) {
      final txs = grouped[key]!;
      double mIncome = baseMonthlyIncome;
      double mExpense = 0;

      for (var tx in txs) {
        if (tx.isIncome) mIncome += tx.amount;
        else mExpense += tx.amount;
      }

      final monthParts = key.split('-');
      summaries.add(MonthSummary(
        month: DateTime(int.parse(monthParts[0]), int.parse(monthParts[1])),
        income: mIncome,
        expense: mExpense,
      ));
      
      totalNet += (mIncome - mExpense);
    }

    monthSummaries.assignAll(summaries);
    totalBalance.value = totalNet;
  }
}
