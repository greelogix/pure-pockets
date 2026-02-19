import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/receipt_parser.dart';
import 'package:intl/intl.dart';

class ReviewExtractionController extends GetxController {
  final ParsedReceipt receipt = Get.arguments as ParsedReceipt;

  late final TextEditingController amountController;
  late final TextEditingController descriptionController;
  
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final category = 'General'.obs;
  
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
  
  // For bounding box calculation
  Size? imageSize;

  final amountError = RxnString();
  final descriptionError = RxnString();

  @override
  void onInit() {
    super.onInit();
    amountController = TextEditingController(text: receipt.totalAmount?.toString() ?? '');
    descriptionController = TextEditingController(text: receipt.merchantName ?? '');
    _extractDateAndTime();
    _loadImageDimensions();
  }

  void _extractDateAndTime() {
    DateTime foundDate = DateTime.now();
    DateTime? parsedDate;
    TimeOfDay? parsedTime;

    // Regex for Date: 1-2 digits, separator, 1-2 digits, separator, 2-4 digits
    final dateRegex = RegExp(r'(\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4})');
    
    // Regex for Time: 0-23:00-59 with optional AM/PM
    final timeRegex = RegExp(r'((?:[01]?\d|2[0-3]):[0-5]\d(?:\s?[AaPp][Mm])?)');

    for (String line in receipt.allLines) {
      // Look for date
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null) {
        DateTime? dt = _tryParseDate(dateMatch.group(1)!.replaceAll(RegExp(r'[-.]'), '/'));
        if (dt != null) {
          // If we find a better (more recent/valid) date, keep it
          if (parsedDate == null || 
              (dt.difference(DateTime.now()).abs() < parsedDate.difference(DateTime.now()).abs())) {
            parsedDate = dt;
          }
        }
      }

      // Look for time
      if (parsedTime == null) {
        final timeMatch = timeRegex.firstMatch(line);
        if (timeMatch != null) {
          try {
             String timeStr = timeMatch.group(1)!;
             parsedTime = _tryParseTime(timeStr);
          } catch (e) {
            print('Time parse error: $e');
          }
        }
      }
    }

    if (parsedDate != null) {
      foundDate = DateTime(
        parsedDate.year, 
        parsedDate.month, 
        parsedDate.day,
        parsedTime?.hour ?? 0,
        parsedTime?.minute ?? 0
      );
    }
    
    selectedDate.value = foundDate;
  }
  
  DateTime? _tryParseDate(String dateStr) {
     List<String> formats = [
       'MM/dd/yyyy', 'MM/dd/yy', 
       'dd/MM/yyyy', 'dd/MM/yy',
       'yyyy/MM/dd'
     ];
     
     final now = DateTime.now();
     DateTime? bestMatch;

     for (var fmt in formats) {
       try {
         DateTime dt = DateFormat(fmt).parse(dateStr);
         
         // Basic sanity check: year should be between 2020 and 2030 (adjustable)
         // And it shouldn't be much later than 'today'
         if (dt.year >= 2020 && dt.year <= 2030) {
            // Keep the one closest to now if we find multiple
            if (bestMatch == null || 
                (dt.difference(now).abs() < bestMatch.difference(now).abs())) {
              bestMatch = dt;
            }
         }
       } catch (_) {}
     }
     return bestMatch;
  }

  TimeOfDay? _tryParseTime(String timeStr) {
      try {
        // Try with AM/PM
        DateTime dt = DateFormat.jm().parse(timeStr); 
        return TimeOfDay.fromDateTime(dt);
      } catch (_) {
        try {
          // Try 24 hour HH:mm
          DateTime dt = DateFormat("HH:mm").parse(timeStr); 
          return TimeOfDay.fromDateTime(dt);
        } catch (_) {
          return null;
        }
      }
  }

  void _loadImageDimensions() async {
    final file = File(receipt.imagePath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      imageSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      update(); // Trigger rebuild to show bounding box
    }
  }

  void confirm() {
    amountError.value = null;
    descriptionError.value = null;

    final amount = double.tryParse(amountController.text) ?? 0.0;
    final description = descriptionController.text.trim();

    bool hasError = false;
    if (amount <= 0) {
      amountError.value = 'Please enter a valid amount';
      hasError = true;
    }
    if (description.isEmpty) {
      descriptionError.value = 'Please enter merchant/description';
      hasError = true;
    }

    if (hasError) return;

    Get.back(result: {
      'amount': amount,
      'description': description,
      'category': category.value,
      'date': selectedDate.value,
    });
  }

  void retake() {
    Get.back(result: null);
  }

  @override
  void onClose() {
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
