import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'controller.dart';
import '../../core/theme/glass_card.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
            ),
            SizedBox(height: 1.5.h),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Obx(() => SwitchListTile(
                    title: Text('Daily Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.sp)),
                    subtitle: Text('Get notified at 2:00 PM and 9:00 PM to record your expenses.', style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
                    value: controller.smartRemindersEnabled.value,
                    onChanged: controller.toggleSmartReminders,
                    activeColor: Colors.blueAccent,
                  )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Text(
                      'Consistency is key! Daily reminders help you stay on track with your monthly savings goal.',
                      style: TextStyle(fontSize: 8.5.sp, color: Colors.blueAccent, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 1.5.h),
            // GlassCard(
            //   padding: EdgeInsets.zero,
            //   child: ListTile(
            //     leading: const Icon(Icons.notifications_active, color: Colors.blueAccent),
            //     title: Text('Test Notification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.sp)),
            //     subtitle: Text('Send a test notification immediately', style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
            //     onTap: controller.sendTestNotification,
            //   ),
            // ),
            // SizedBox(height: 1.5.h),
            // GlassCard(
            //   padding: EdgeInsets.zero,
            //   child: ListTile(
            //     leading: const Icon(Icons.access_alarm, color: Colors.orangeAccent),
            //     title: Text('Schedule (1 min)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.sp)),
            //     subtitle: Text('Test scheduled notification in 1 minute', style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
            //     onTap: controller.scheduleTestReminder,
            //   ),
            // ),
            SizedBox(height: 4.h), // Bottom padding
            SizedBox(height: 4.h), // Bottom padding
          ],
        ),
      ),
    );
  }
}
