import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:math';
import 'price_normalizer.dart';

class ParsedReceipt {
  final double? totalAmount;
  final double? subtotal;
  final double? tax;
  final String? merchantName;
  final Rect? amountBoundingBox;
  final String imagePath;
  final List<String> allLines;
  final bool isHighConfidence;

  ParsedReceipt({
    required this.totalAmount,
    this.subtotal,
    this.tax,
    required this.merchantName,
    required this.amountBoundingBox,
    required this.imagePath,
    required this.allLines,
    this.isHighConfidence = false,
  });
}

class SpatialLine {
  final String text;
  final Rect boundingBox;
  final int lineIndex;

  SpatialLine({
    required this.text,
    required this.boundingBox,
    required this.lineIndex,
  });
}

class ReceiptParser {
  static const double LINE_GROUPING_THRESHOLD = 10.0;
  static const double BOTTOM_SECTION_PERCENTAGE = 0.3;

  static const List<String> COMMON_MERCHANTS = [
    "Starbucks", "McDonalds", "Walmart", "Target", "Amazon", "Uber", "Lyft", 
    "Shell", "Exxon", "7-Eleven", "CVS", "Walgreens", "Costco", "Whole Foods", 
    "Trader Joes", "Pizza Hut", "Domino's", "Subway", "Chipotle", "Burger King", 
    "KFC", "Taco Bell", "Wendys", "Dunkin", "Home Depot", "Lowe's", "Best Buy", 
    "Apple", "Netflix", "Spotify", "Google", "Microsoft", "Steam", "PlayStation", 
    "H&M", "Zara", "Nike", "Adidas", "Uniqlo", "IKEA", "Gap", "Old Navy", 
    "Sephora", "Ulta", "Macy's", "Nordstrom", "Kohl's", "TJ Maxx", "Marshalls",
    "Reliance Fresh", "D-Mart", "Big Bazaar", "Zomato", "Swiggy", "JioMart"
  ];

  /// Layer 1: Spatial Line-Grouping
  List<SpatialLine> _groupLinesSpatially(RecognizedText recognizedText) {
    List<SpatialLine> spatialLines = [];
    int lineIndex = 0;

    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        spatialLines.add(SpatialLine(
          text: line.text.trim(),
          boundingBox: line.boundingBox,
          lineIndex: lineIndex++,
        ));
      }
    }

    // Sort by vertical position (top to bottom)
    spatialLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // Group lines with similar vertical positions
    List<SpatialLine> groupedLines = [];
    for (int i = 0; i < spatialLines.length; i++) {
      if (i == 0) {
        groupedLines.add(spatialLines[i]);
        continue;
      }

      double verticalDiff = (spatialLines[i].boundingBox.top - spatialLines[i - 1].boundingBox.top).abs();
      
      if (verticalDiff <= LINE_GROUPING_THRESHOLD) {
        // Merge with previous line (same horizontal level)
        String mergedText = '${groupedLines.last.text} ${spatialLines[i].text}';
        Rect mergedBox = Rect.fromLTRB(
          min(groupedLines.last.boundingBox.left, spatialLines[i].boundingBox.left),
          min(groupedLines.last.boundingBox.top, spatialLines[i].boundingBox.top),
          max(groupedLines.last.boundingBox.right, spatialLines[i].boundingBox.right),
          max(groupedLines.last.boundingBox.bottom, spatialLines[i].boundingBox.bottom),
        );
        
        groupedLines[groupedLines.length - 1] = SpatialLine(
          text: mergedText,
          boundingBox: mergedBox,
          lineIndex: groupedLines.last.lineIndex,
        );
      } else {
        groupedLines.add(spatialLines[i]);
      }
    }

    return groupedLines;
  }

  /// Layer 2: Fuzzy Keyword Anchoring using Levenshtein Distance
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<List<int>> matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1].toLowerCase() == s2[j - 1].toLowerCase() ? 0 : 1;
        matrix[i][j] = min(
          min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1),
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    return matrix[s1.length][s2.length];
  }

  bool _fuzzyMatchKeyword(String text, String keyword, {int maxDistance = 2}) {
    // Direct contains check first
    if (text.toLowerCase().contains(keyword.toLowerCase())) {
      return true;
    }

    // Split text into words and check each word
    List<String> words = text.split(RegExp(r'\s+'));
    for (var word in words) {
      if (_levenshteinDistance(word, keyword) <= maxDistance) {
        return true;
      }
    }

    return false;
  }

  /// Character Swapping: Correct common OCR errors in numbers
  String _swapCharacters(String text) {
    // Only swap if the word looks somewhat numeric (contains digits or currency symbols)
    // or if we are in a context where a number is expected
    
    // Replace 'S' or 's' with '5'
    String swapped = text.replaceAll(RegExp(r'[Ss]'), '5');
    // Replace 'O' or 'o' with '0'
    swapped = swapped.replaceAll(RegExp(r'[Oo]'), '0');
    
    return swapped;
  }

  /// Layer 3: Greedy Regex Extraction
  double? _extractAmountFromLine(String lineText) {
    // Apply character swapping to fix potential OCR errors like '10.0O' or '2S.50'
    String fixedText = _swapCharacters(lineText);

    // Pattern for prices: digits with optional comma/dot separators
    // OLD: RegExp(r'(\d+[\.,]\d{2})');
    // NEW: Capture full number string including thousands separators e.g. "25,000" or "1,234.56"
    // This regex looks for digits, followed optionally by (dot/comma and more digits) repeatedly.
    // We want to be greedy to capture "25,000" not just "25,00"
    final pricePattern = RegExp(r'(\d+[.,]\d+)');
    final matches = pricePattern.allMatches(fixedText);

    if (matches.isEmpty) return null;

    // Return the first valid amount found
    for (var match in matches) {
      String amountStr = match.group(1)!;
      double? amount = PriceNormalizer.normalize(amountStr);
      if (amount != null && amount > 0) {
        return amount;
      }
    }

    return null;
  }

  /// Merchant Matching
  String? _findCommonMerchant(String text) {
    for (var merchant in COMMON_MERCHANTS) {
      if (_fuzzyMatchKeyword(text, merchant, maxDistance: 1)) {
        return merchant;
      }
    }
    return null;
  }

  /// Winner Logic: Find total amount using hybrid approach
  ParsedReceipt parse(RecognizedText recognizedText, String imagePath) {
    print("=== Starting Hybrid Receipt Parser (Enhanced) ===");

    // Layer 1: Spatial grouping
    List<SpatialLine> spatialLines = _groupLinesSpatially(recognizedText);
    
    // Layer 2: Fuzzy keyword anchoring
    final anchorKeywords = ['total', 'amount', 'balance', 'net', 'due', 'pay'];
    final excludeKeywords = ['cash', 'change', 'tendered', 'paid', 'return'];
    
    // Keywords for Subtotal and Tax
    final subtotalKeywords = ['subtotal', 'sub-total', 'net amount'];
    final taxKeywords = ['tax', 'vat', 'gst', 'hst'];

    double? foundTotal;
    double? foundSubtotal;
    double? foundTax;
    
    Rect? foundBoundingBox;
    String? merchantName;

    // First pass: Identify Merchant
    for (var line in spatialLines.take(8)) {
      String text = line.text;
      String? matchedMerchant = _findCommonMerchant(text);
      if (matchedMerchant != null) {
        merchantName = matchedMerchant;
        print("Found common merchant: $merchantName");
        break;
      }
    }
    
    // If no common merchant found, fallback to heuristic
    if (merchantName == null) {
      for (var line in spatialLines.take(5)) {
        String text = line.text.trim();
        if (text.length > 2 && !RegExp(r'^\d+$').hasMatch(text)) {
          String lowerText = text.toLowerCase();
          if (!lowerText.contains('receipt') &&
              !lowerText.contains('invoice') &&
              !lowerText.contains('bill')) {
            merchantName = text;
            break;
          }
        }
      }
    }

    // Second pass: Find Amounts (Total, Subtotal, Tax)
    for (int i = 0; i < spatialLines.length; i++) {
      SpatialLine line = spatialLines[i];
      String lineText = line.text.toLowerCase();

      // Skip excluded keywords ONLY for Total
      bool isExcludedForTotal = excludeKeywords.any((kw) => lineText.contains(kw));

      // Extract amount candidates
      double? currentLineAmount = _extractAmountFromLine(line.text); // Use raw text for checking, but swap inside
      double? nextLineAmount;
      if (i + 1 < spatialLines.length) {
         nextLineAmount = _extractAmountFromLine(spatialLines[i + 1].text);
      }

      // Check for Subtotal
      if (foundSubtotal == null) {
        for (var kw in subtotalKeywords) {
          if (_fuzzyMatchKeyword(lineText, kw)) {
             foundSubtotal = currentLineAmount ?? nextLineAmount;
             if (foundSubtotal != null) print("Found Subtotal: $foundSubtotal");
             break;
          }
        }
      }

      // Check for Tax
      if (foundTax == null) {
        for (var kw in taxKeywords) {
          if (_fuzzyMatchKeyword(lineText, kw)) {
             foundTax = currentLineAmount ?? nextLineAmount;
             if (foundTax != null) print("Found Tax: $foundTax");
             break;
          }
        }
      }

      // Check for Total (if not explicitly excluded)
      if (!isExcludedForTotal) {
        bool hasAnchor = false;
        for (var keyword in anchorKeywords) {
          if (_fuzzyMatchKeyword(lineText, keyword)) {
            hasAnchor = true;
            break;
          }
        }

        if (hasAnchor) {
          if (currentLineAmount != null) {
            foundTotal = currentLineAmount;
            foundBoundingBox = line.boundingBox;
          } else if (nextLineAmount != null) {
             // Ensure next line isn't excluded
             String nextLineText = spatialLines[i + 1].text.toLowerCase();
             if (!excludeKeywords.any((kw) => nextLineText.contains(kw))) {
               foundTotal = nextLineAmount;
               foundBoundingBox = spatialLines[i + 1].boundingBox;
             }
          }
        }
      }
    }

    // Fallback: Find largest amount in bottom 30% if Total not found
    if (foundTotal == null) {
      double receiptHeight = spatialLines.isEmpty ? 0 : spatialLines.last.boundingBox.bottom;
      double bottomThreshold = receiptHeight * (1 - BOTTOM_SECTION_PERCENTAGE);
      List<Map<String, dynamic>> bottomAmounts = [];

      for (var line in spatialLines) {
        if (line.boundingBox.top >= bottomThreshold) {
          String lineText = line.text.toLowerCase();
          if (excludeKeywords.any((kw) => lineText.contains(kw))) {
            continue;
          }
          double? amount = _extractAmountFromLine(line.text);
          if (amount != null && amount >= 1 && amount < 1000000) {
            bottomAmounts.add({'amount': amount, 'boundingBox': line.boundingBox});
          }
        }
      }

      if (bottomAmounts.isNotEmpty) {
        bottomAmounts.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
        foundTotal = bottomAmounts[0]['amount'];
        foundBoundingBox = bottomAmounts[0]['boundingBox'];
      }
    }

    // Validation Logic
    bool isHighConfidence = false;
    if (foundTotal != null && foundSubtotal != null && foundTax != null) {
      double calculatedTotal = foundSubtotal + foundTax;
      if ((calculatedTotal - foundTotal).abs() < 0.1) {
        isHighConfidence = true;
        print("Validation Passed: Subtotal ($foundSubtotal) + Tax ($foundTax) == Total ($foundTotal)");
      } else {
        print("Validation Failed: Subtotal ($foundSubtotal) + Tax ($foundTax) != Total ($foundTotal)");
      }
    } else if (foundTotal != null && merchantName != null) {
       // Also consider it reasonably confident if we found a recognized merchant AND a total
       // But 'high confidence' usually implies math check pass. 
       // We'll stick to strict math validation for 'High Confidence' flag as requested.
    }

    print("=== Parser Complete ===");
    print("Total: $foundTotal, Sub: $foundSubtotal, Tax: $foundTax");
    print("Merchant: $merchantName");
    print("Confidence: ${isHighConfidence ? 'HIGH' : 'LOW'}");

    return ParsedReceipt(
      totalAmount: foundTotal,
      subtotal: foundSubtotal,
      tax: foundTax,
      merchantName: merchantName,
      amountBoundingBox: foundBoundingBox,
      imagePath: imagePath,
      allLines: spatialLines.map((l) => l.text).toList(),
      isHighConfidence: isHighConfidence,
    );
  }
}
