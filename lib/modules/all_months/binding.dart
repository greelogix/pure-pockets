import 'package:get/get.dart';
import 'controller.dart';

class AllMonthsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllMonthsController>(
      () => AllMonthsController(),
    );
  }
}
