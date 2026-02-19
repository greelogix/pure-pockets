import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'controller.dart';
import '../../core/theme/glass_card.dart';

class TransactionEntryView extends GetView<TransactionEntryController> {
  const TransactionEntryView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Add Transaction', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey[900], size: 18.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // OCR Header
                  Padding(
                    padding: EdgeInsets.only(left: 2.w, bottom: 1.5.h),
                    child: Text('Scan Receipt', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[700])),
                  ),
                  GlassCard(
                    padding: EdgeInsets.all(5.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            onTap: () => controller.scanReceiptWithOcr(fromCamera: true),
                            icon: Icons.camera_alt_rounded,
                            label: 'Camera',
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: _buildActionButton(
                            onTap: () => controller.scanReceiptWithOcr(fromCamera: false),
                            icon: Icons.photo_library_rounded,
                            label: 'Gallery',
                            color: Colors.indigoAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Manual Entry Header
                  Padding(
                    padding: EdgeInsets.only(left: 2.w, bottom: 1.5.h),
                    child: Text('Transaction Details', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[700])),
                  ),
                  GlassCard(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      children: [
                        // Amount Field
                        Obx(() => _buildTextField(
                          controller: controller.amountController,
                          label: 'Amount',
                          prefix: controller.currencySymbol.value,
                          errorText: controller.amountError.value,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (v) => controller.amount.value = double.tryParse(v) ?? 0.0,
                        )),
                        SizedBox(height: 2.5.h),

                        // Merchant Field
                        Obx(() => _buildTextField(
                          controller: controller.merchantController,
                          label: 'Merchant / Description',
                          errorText: controller.merchantError.value,
                          onChanged: (v) => controller.merchant.value = v,
                        )),
                        SizedBox(height: 2.5.h),

                        // Category Dropdown
                        Obx(() => DropdownButtonFormField<String>(
                          value: controller.category.value,
                          decoration: _inputDecoration('Category'),
                          icon: Icon(Icons.expand_more_rounded, color: Colors.blueGrey[400]),
                          items: controller.categories.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat, style: TextStyle(fontSize: 11.sp)),
                          )).toList(),
                          onChanged: (v) => v != null ? controller.category.value = v : null,
                        )),
                        SizedBox(height: 2.5.h),

                        // Income/Expense Toggle
                        Obx(() => Container(
                          decoration: BoxDecoration(
                            color: (controller.isIncome.value ? Colors.green : Colors.red).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: (controller.isIncome.value ? Colors.green : Colors.red).withOpacity(0.1)),
                          ),
                          child: SwitchListTile(
                            title: Text(
                              controller.isIncome.value ? 'Income' : 'Expense',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp, color: controller.isIncome.value ? Colors.green[700] : Colors.red[700]),
                            ),
                            secondary: Icon(
                              controller.isIncome.value ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: controller.isIncome.value ? Colors.green : Colors.red,
                            ),
                            value: controller.isIncome.value,
                            onChanged: (v) => controller.isIncome.value = v,
                            activeColor: Colors.green,
                          ),
                        )),
                        SizedBox(height: 2.5.h),

                        // Date Selection
                        Obx(() => InkWell(
                          onTap: () => _selectDateTime(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(Icons.calendar_today_rounded, color: Colors.blueAccent, size: 16.sp),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date & Time', style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
                                      Text(
                                        DateFormat('MMM dd, yyyy  •  h:mm a').format(controller.selectedDate.value),
                                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
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

                  // Save Button
                  Container(
                    height: 7.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Colors.blueAccent, Colors.indigoAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: controller.saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Save Transaction', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            )),
    );
  }

  Widget _buildActionButton({required VoidCallback onTap, required IconData icon, required String label, required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 1.h),
            Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? prefix, String? errorText, TextInputType? keyboardType, Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label).copyWith(
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
        errorText: errorText,
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.2.h),
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
