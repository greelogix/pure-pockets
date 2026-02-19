import 'package:get/get.dart';
import 'controller.dart';

class TransactionEntryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionEntryController>(
      () => TransactionEntryController(),
    );
  }
}
