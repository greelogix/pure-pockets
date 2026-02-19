import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date and Time Regex Tests', () {
    test('Extracts Date correctly', () {
      final dateRegex = RegExp(r'(\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4})');
      
      expect(dateRegex.firstMatch('Date: 12/25/2023')!.group(1), '12/25/2023');
      expect(dateRegex.firstMatch('01-01-24')!.group(1), '01-01-24');
      expect(dateRegex.firstMatch('Invoice Date 5.10.2023')!.group(1), '5.10.2023');
    });

    test('Extracts Time correctly', () {
      final timeRegex = RegExp(r'((?:[01]?\d|2[0-3]):[0-5]\d(?:\s?[AaPp][Mm])?)');
      
      expect(timeRegex.firstMatch('Time: 14:30')!.group(1), '14:30');
      expect(timeRegex.firstMatch('At 2:30 PM')!.group(1), '2:30 PM');
      expect(timeRegex.firstMatch('09:45am')!.group(1), '09:45am');
    });
  });
}
