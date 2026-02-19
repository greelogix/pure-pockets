import 'package:get/get.dart';
import 'controller.dart';

class ReviewExtractionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewExtractionController>(
      () => ReviewExtractionController(),
    );
  }
}
