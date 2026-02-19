import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/ocr_service.dart';
import '../../services/database_service.dart';
import '../../data/models/transaction.dart';
import '../../routes/app_routes.dart';
import '../dashboard/controller.dart';

class TransactionEntryController extends GetxController {
  final OcrService _ocrService = Get.find<OcrService>();
  final DatabaseService _db = Get.find<DatabaseService>();

  final amount = 0.0.obs;
  final category = 'General'.obs;
  final merchant = ''.obs;
  final isIncome = false.obs;
  final isLoading = false.obs;
  final currencySymbol = '₹'.obs;
  final selectedDate = DateTime.now().obs;

  // TextEditingController for amount field
  late final TextEditingController amountController;
  late final TextEditingController merchantController;

  final amountError = RxnString();
  final merchantError = RxnString();

  final categories = [
    'General',
    'Food',
    'Travel',
    'Shopping',
    'Entertainment',
    'Bills',
    'Salary',
    'Investment',
  ];

  @override
  void onInit() {
    super.onInit();
    amountController = TextEditingController();
    merchantController = TextEditingController();
    _loadUserCurrency();

    // Check for auto-open camera argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null && Get.arguments is Map && Get.arguments['autoOpenCamera'] == true) {
        scanReceiptWithOcr(fromCamera: true);
      }
    });
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
        'AFN': '؋', 'ALL': 'L', 'DZD': 'د.ج', 'ARS': '\$', 'CLP': '\$',
        'COP': '\$', 'JOD': 'د.ا', 'KES': 'KSh', 'MAD': 'د.م.', 'PEN': 'S/.',
        'IRR': '﷼', 'IQD': 'ع.د',
      };
      currencySymbol.value = currencyMap[userProfile.currency] ?? '₹';
    }
  }

  Future<void> scanReceiptWithOcr({bool fromCamera = true}) async {
    isLoading.value = true;
    final parsedReceipt = await _ocrService.scanReceipt(fromCamera: fromCamera);
    isLoading.value = false;

    if (parsedReceipt != null && parsedReceipt.totalAmount != null) {
      // Navigate to review screen
      final result = await Get.toNamed(Routes.REVIEW_EXTRACTION, arguments: parsedReceipt);

      if (result != null && result is Map) {
        double confirmedAmount = result['amount'];
        String confirmedDescription = result['description'] ?? '';
        String confirmedCategory = result['category'] ?? 'General';
        DateTime confirmedDate = result['date'] ?? DateTime.now();
        
        // Save image to sandbox
        String? savedReceiptPath = await _ocrService.saveToSandbox(parsedReceipt.imagePath);

        // Direct Save Logic
        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: confirmedAmount,
          category: confirmedCategory,
          merchant: confirmedDescription.isEmpty ? 'Unknown' : confirmedDescription,
          date: confirmedDate,
          isIncome: false,
          receiptPath: savedReceiptPath,
        );

        // Use DashboardController to add for better refresh/month switching
        try {
          final dashboardController = Get.find<DashboardController>();
          await dashboardController.addTransaction(transaction);
        } catch (e) {
          await _db.transactionBox.add(transaction);
        }

        Get.back(); // Close Transaction Entry screen
        _showSuccessPopup('Receipt Saved!');
      }
    } else {
      amountError.value = 'Detection failed. Please enter manually.';
    }
  }

  Future<void> saveTransaction() async {
    // Clear errors
    amountError.value = null;
    merchantError.value = null;

    bool hasError = false;
    if (amount.value <= 0) {
      amountError.value = 'Please enter a valid amount';
      hasError = true;
    }
    if (merchant.value.trim().isEmpty) {
      merchantError.value = 'Please enter merchant or description';
      hasError = true;
    }

    if (hasError) return;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount.value,
      category: category.value,
      merchant: merchant.value,
      date: selectedDate.value,
      isIncome: isIncome.value,
    );

    // Use DashboardController to add for better refresh/month switching
    try {
      final dashboardController = Get.find<DashboardController>();
      await dashboardController.addTransaction(transaction);
    } catch (e) {
      await _db.transactionBox.add(transaction);
    }
    
    Get.back();
    _showSuccessPopup('Transaction Added');
  }

  void _showSuccessPopup(String title) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black12,
      useSafeArea: true,
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Get.isDialogOpen ?? false) Get.back();
    });
  }

  @override
  void onClose() {
    amountController.dispose();
    merchantController.dispose();
    super.onClose();
  }
}
