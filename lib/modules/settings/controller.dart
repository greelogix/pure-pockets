import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../services/reminder_service.dart';

class SettingsController extends GetxController {
  final RxBool smartRemindersEnabled = true.obs;
  late Box _settingsBox;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = await Hive.openBox('settings_box');
    smartRemindersEnabled.value = _settingsBox.get('smart_reminders_enabled', defaultValue: true);
  }

  Future<void> toggleSmartReminders(bool value) async {
    print('Toggling reminders to: $value');
    smartRemindersEnabled.value = value;
    await _settingsBox.put('smart_reminders_enabled', value);
    
    try {
      final reminderService = Get.find<ReminderService>();
      print('ReminderService found: $reminderService');
      if (value) {
        await reminderService.scheduleDailyReminders();
        print('Scheduled daily reminders');
        Get.snackbar('Reminders Enabled', 'Daily reminders scheduled for 2:00 PM and 9:00 PM', snackPosition: SnackPosition.BOTTOM);
      } else {
        await reminderService.cancelAllReminders();
        print('Cancelled all reminders');
        Get.snackbar('Reminders Disabled', 'All reminders cancelled', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Error accessing ReminderService: $e');
    }
  }

  // Future<void> sendTestNotification() async {
  //   final reminderService = Get.find<ReminderService>();
  //   await reminderService.showTestNotification();
  //   Get.snackbar('Test Sent', 'Check your notification tray!', snackPosition: SnackPosition.BOTTOM);
  // }
  //
  // Future<void> scheduleTestReminder() async {
  //   final reminderService = Get.find<ReminderService>();
  //   await reminderService.scheduleTestReminderInOneMinute();
  //   Get.snackbar('Scheduled', 'Wait 1 minute for the notification...', snackPosition: SnackPosition.BOTTOM);
  // }
}
