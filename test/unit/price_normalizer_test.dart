import 'package:flutter_test/flutter_test.dart';
import 'package:money_buddy/utils/price_normalizer.dart';

void main() {
  group('PriceNormalizer Tests', () {
    test('Correctly parses thousands with comma', () {
      expect(PriceNormalizer.normalize('25,000'), 25000.0);
      expect(PriceNormalizer.normalize('1,000'), 1000.0);
    });

    test('Correctly parses decimals with comma', () {
      expect(PriceNormalizer.normalize('25,00'), 25.0);
      expect(PriceNormalizer.normalize('10,50'), 10.5);
    });

    test('Correctly parses mixed formats', () {
      expect(PriceNormalizer.normalize('1,234.56'), 1234.56);
      expect(PriceNormalizer.normalize('100'), 100.0);
    });

    test('Handles null and empty', () {
      expect(PriceNormalizer.normalize(null), null);
      expect(PriceNormalizer.normalize(''), null);
    });

    test('Handles invalid inputs gracefully', () {
      expect(PriceNormalizer.normalize('abc'), null);
      expect(PriceNormalizer.normalize('12,34,56'), null); // ambiguous, standard double.tryParse logic applies (likely null or partial)
      // Actually standard double.tryParse('12,34,56') is null.
      // Our logic: rule 1 doesn't match (end with 3 digits?). Regex `,\d{3}` matches `12,34,56`? No.
      // Wait `,\d{3}` matches `,345` inside. `12,345,678` matches.
      // `12,34,56` -> no match for `,\d{3}` (only 2 digits).
      // Rule 2: `,\d{2}` matches `,34` or `,56`. AND no dot.
      // matches `12,34,56`. Replaceall `,` with `.`.
      // `12.34.56`. double.tryParse returns null. Correct.
    });
  });
}
