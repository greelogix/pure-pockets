import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/database_service.dart';
import 'services/sms_service.dart';
import 'services/ocr_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          title: "Pure Pockets",
          initialRoute: Routes.SPLASH,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueAccent,
          ),
        );
      },
    ),
  );
}
