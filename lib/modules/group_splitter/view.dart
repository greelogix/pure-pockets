import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class GroupSplitterView extends GetView<GroupSplitterController> {
  const GroupSplitterView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Splitter'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'GroupSplitterView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
