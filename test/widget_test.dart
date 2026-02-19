import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:money_buddy/routes/app_pages.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Initial route is Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
