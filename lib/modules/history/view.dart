import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'dart:ui';
import 'dart:io';
import 'controller.dart';
import '../../data/models/transaction.dart';
import '../../core/theme/glass_card.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final title = controller.filterMonth.value != null 
              ? 'History: ${DateFormat('MMMM yyyy').format(controller.filterMonth.value!)}'
              : 'Transaction History';
          return Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87));
        }),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.groupedTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 40.sp, color: Colors.grey[300]),
                SizedBox(height: 2.h),
                Text('No transactions found', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          itemCount: controller.groupedTransactions.keys.length,
          itemBuilder: (context, index) {
            String dateKey = controller.groupedTransactions.keys.elementAt(index);
            List<Transaction> transactions = controller.groupedTransactions[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 1.5.h),
                  child: Text(
                    dateKey,
                    style: TextStyle(
                      fontSize: 11.sp, 
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[400],
                    ),
                  ),
                ),
                ...transactions.map((tx) => Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h),
                    child: GlassCard(
                      padding: EdgeInsets.zero,
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                        leading: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: (tx.isIncome ? Colors.green : Colors.red).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            tx.isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                            color: tx.isIncome ? Colors.green : Colors.red,
                            size: 16.sp,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                tx.merchant,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${tx.isIncome ? '+' : '-'} ${controller.currencySymbol.value} ${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: tx.isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(tx.category, style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
                        children: [
                           if (tx.receiptPath != null)
                             Padding(
                               padding: EdgeInsets.all(4.w),
                               child: GestureDetector(
                                 onTap: () => _viewImage(tx.receiptPath!),
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(16),
                                   child: Image.file(
                                     File(tx.receiptPath!),
                                     height: 25.h,
                                     width: double.infinity,
                                     fit: BoxFit.cover,
                                     errorBuilder: (context, error, stackTrace) => _imageError(),
                                   ),
                                 ),
                               ),
                             ),
                           Padding(
                             padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                 TextButton.icon(
                                   onPressed: () => _confirmDelete(tx),
                                   icon: Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: 16.sp),
                                   label: Text('Delete', style: TextStyle(color: Colors.red[400], fontSize: 11.sp)),
                                 ),
                               ],
                             ),
                           )
                        ],
                      ),
                    ),
                  ),
                )).toList(),
                SizedBox(height: 1.h),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _imageError() {
    return Container(
      height: 12.h,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: Center(child: Text('Receipt image not found', style: TextStyle(fontSize: 10.sp, color: Colors.grey))),
    );
  }

  void _viewImage(String path) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(File(path), fit: BoxFit.contain, width: double.infinity, height: double.infinity),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
      useSafeArea: false,
    );
  }

  void _confirmDelete(Transaction tx) {
    Get.defaultDialog(
      title: 'Delete Transaction',
      middleText: 'Remove this entry forever?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteTransaction(tx);
        Get.back();
      }
    );
  }
}
