import 'package:get/get.dart';
import '../../services/database_service.dart';
import '../../services/sms_service.dart';
import '../../services/ocr_service.dart';
import '../../services/reminder_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startApp();
  }

  Future<void> _startApp() async {
    final startTime = DateTime.now();

    // 1. Initialize Services
    await Get.putAsync(() => DatabaseService().init());
    await Get.putAsync(() => SmsService().init());
    await Get.putAsync(() => OcrService().init());
    
    // 2. Initialize Reminder Service
    await Get.putAsync(() => ReminderService().init());


    // 3. Logic to determine next route
    final DatabaseService db = Get.find<DatabaseService>();
    final userProfile = db.getUserProfile();
    final nextRoute = userProfile?.onboardingCompleted == true 
        ? Routes.DASHBOARD 
        : Routes.ONBOARDING;

    // 4. Ensure minimum 2.5s delay for animation
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 2500) {
      await Future.delayed(Duration(milliseconds: 2500 - elapsed.inMilliseconds));
    }

    // 5. Navigate with smooth transition
    Get.offNamed(nextRoute);
  }
}
