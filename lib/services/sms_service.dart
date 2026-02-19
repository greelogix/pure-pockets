import 'package:get/get.dart';
import 'package:telephony/telephony.dart';

class SmsService extends GetxService {
  final Telephony telephony = Telephony.instance;

  Future<SmsService> init() async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted ?? false) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          _parseSms(message);
        },
        listenInBackground: false,
      );
    }
    return this;
  }

  void _parseSms(SmsMessage message) {
    String? body = message.body;
    if (body == null) return;

    // Basic Regex for Amount extraction (e.g., "Rs. 500", "$ 120", "debited with 45.00")
    RegExp amountRegExp = RegExp(r'(?:(?:RS|INR|USD|\$)\.?\s?)(\d+(?:\.\d{1,2})?)', caseSensitive: false);
    var match = amountRegExp.firstMatch(body);
    
    if (match != null) {
      double amount = double.parse(match.group(1)!);
      print("Detected transaction: $amount from SMS: $body");
      // TODO: Logic to notify controller or add to DB
    }
  }
}
