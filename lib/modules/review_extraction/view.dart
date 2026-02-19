import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'controller.dart';
import '../../core/theme/glass_card.dart';

class ReviewExtractionView extends GetView<ReviewExtractionController> {
  const ReviewExtractionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Review Receipt', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.blueGrey[900], size: 20.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Image Preview Section
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GetBuilder<ReviewExtractionController>(
                  builder: (_) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: Colors.white),
                        Image.file(
                          File(controller.receipt.imagePath),
                          fit: BoxFit.contain,
                        ),
                        if (controller.receipt.amountBoundingBox != null && controller.imageSize != null)
                          CustomPaint(
                            painter: BoundingBoxPainter(
                              controller.receipt.amountBoundingBox!,
                              controller.imageSize!,
                            ),
                          ),
                      ],
                    );
                  }
                ),
              ),
            ),
          ),
          
          // Edit Section
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
                    child: Text('Verify Details', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
                  ),
                  
                  GlassCard(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      children: [
                        // Amount Field
                        Obx(() => _buildTextField(
                          controller: controller.amountController,
                          label: 'Total Amount',
                          icon: Icons.payments_rounded,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          isBold: true,
                          errorText: controller.amountError.value,
                        )),
                        SizedBox(height: 2.5.h),
                        
                        // Description Field
                        Obx(() => _buildTextField(
                          controller: controller.descriptionController,
                          label: 'Merchant / Description',
                          icon: Icons.store_rounded,
                          errorText: controller.descriptionError.value,
                        )),
                        SizedBox(height: 2.5.h),
                        
                        // Category Dropdown
                        Obx(() => DropdownButtonFormField<String>(
                          value: controller.category.value,
                          decoration: _inputDecoration('Category', Icons.category_rounded),
                          icon: Icon(Icons.expand_more_rounded, color: Colors.blueGrey[400]),
                          items: controller.categories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: TextStyle(fontSize: 11.sp)),
                          )).toList(),
                          onChanged: (v) => v != null ? controller.category.value = v : null,
                        )),
                        SizedBox(height: 2.5.h),
                        
                        // Date Selection
                        Obx(() => InkWell(
                          onTap: () => _selectDateTime(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[200]!),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.calendar_today_rounded, color: Colors.blueAccent, size: 14.sp),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date & Time', style: TextStyle(fontSize: 8.sp, color: Colors.grey[600])),
                                      Text(
                                        DateFormat('MMM dd, yyyy  •  h:mm a').format(controller.selectedDate.value),
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.retake,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            side: BorderSide(color: Colors.red[200]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            foregroundColor: Colors.red[400],
                          ),
                          child: Text('Discard', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 7.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.indigoAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controller.confirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Confirm Details', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType, bool isBold = false, String? errorText}) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label, icon).copyWith(errorText: errorText),
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: isBold ? 14.sp : 11.sp, 
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600, 
        color: Colors.blueGrey[900]
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 9.sp),
      prefixIcon: Icon(icon, color: Colors.blueAccent.withOpacity(0.7), size: 16.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.blueAccent, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black87),
        ),
        child: child!,
      ),
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(controller.selectedDate.value),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black87),
          ),
          child: child!,
        ),
      );
      
      if (pickedTime != null) {
        controller.selectedDate.value = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }
}

class BoundingBoxPainter extends CustomPainter {
  final Rect boundingBox;
  final Size imageSize;

  BoundingBoxPainter(this.boundingBox, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width == 0 || imageSize.height == 0) return;

    double scaleX = size.width / imageSize.width;
    double scaleY = size.height / imageSize.height;
    double scale = scaleX < scaleY ? scaleX : scaleY;

    double currWidth = imageSize.width * scale;
    double currHeight = imageSize.height * scale;
    double dx = (size.width - currWidth) / 2;
    double dy = (size.height - currHeight) / 2;

    Rect scaledRect = Rect.fromLTRB(
      dx + boundingBox.left * scale,
      dy + boundingBox.top * scale,
      dx + boundingBox.right * scale,
      dy + boundingBox.bottom * scale,
    );

    final paintBg = Paint()
      ..color = Colors.blueAccent.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final paintBorder = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(RRect.fromRectAndRadius(scaledRect, const Radius.circular(4)), paintBg);
    canvas.drawRRect(RRect.fromRectAndRadius(scaledRect, const Radius.circular(4)), paintBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
