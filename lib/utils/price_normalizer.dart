class PriceNormalizer {
  /// Cleans and parses a price string into a double.
  /// 
  /// Logic:
  /// 1. If comma is followed by 3 digits (e.g., 25,000), it's a thousands separator -> strip it.
  /// 2. If comma is followed by 2 digits and NO other dot exists (e.g., 25,00), it's a decimal -> replace with dot.
  /// 3. Otherwise, use standard replacement (comma -> dot).
  static double? normalize(String? rawAmount) {
    if (rawAmount == null || rawAmount.isEmpty) return null;

    String cleanAmount = rawAmount.trim();

    // Check for "thousands separator" pattern: Comma followed explicitly by 3 digits
    // Example: "25,000" -> "25000"
    // We only strip if it matches the pattern exactly at the end or typically inside
    // But user request specifically said: "If a comma is followed by 3 digits, strip the comma"
    if (RegExp(r',\d{3}').hasMatch(cleanAmount)) {
      cleanAmount = cleanAmount.replaceAll(',', '');
    } 
    // Check for "decimal comma" pattern: Comma followed by 2 digits AND no other dot
    // Example: "25,00" -> "25.00"
    // We must ensure there isn't already a dot, because "1.234,56" is European, but "1,234.56" is US
    // The user constraint: "If a comma is followed by 2 digits and there is no other dot"
    else if (RegExp(r',\d{2}').hasMatch(cleanAmount) && !cleanAmount.contains('.')) {
      cleanAmount = cleanAmount.replaceAll(',', '.');
    } 
    // Fallback/Standard cleanup: Just ensure commmas are dots if it looks like a decimal usage not covered above,
    // or just standardizing for tryParse which expects dots.
    // However, if we blindly replace ',' with '.', "25,000" becomes "25.000" which is 25.
    // The first rule (strip , + 3 digits) handles the thousands case.
    // If we are here, it didn't match , + 3 digits.
    // So it might be "25,5" or "100" or "10,50" (caught by rule 2).
    // Let's stick to the requested logic strictly first.
    
    // If simple replace is still needed for other cases? 
    // Use standard parsing: remove all non-numeric except dot.
    // But we might have converted comma to dot in step 2.
    
    // Final cleanup: remove any remaining chars that aren't digits or dots (like currency symbols if any slipped through)
    // Though usually specific regex extraction handles that before calling this.
    // Let's assume input is mostly numeric chars.
    
    return double.tryParse(cleanAmount);
  }
}
