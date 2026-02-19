import 'package:get/get.dart';
import 'controller.dart';

class GroupSplitterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupSplitterController>(
      () => GroupSplitterController(),
    );
  }
}
