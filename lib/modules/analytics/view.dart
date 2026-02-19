import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sizer/sizer.dart';
import 'controller.dart';
import '../../core/theme/glass_card.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Analytics', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Selector
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Obx(() => Container(
              width: double.infinity,
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: CupertinoSegmentedControl<int>(
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Today')),
                  1: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Week')),
                  2: Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Month')),
                },
                onValueChanged: controller.onTabChanged,
                groupValue: controller.currentTab.value,
                borderColor: Colors.transparent,
                selectedColor: Colors.blueAccent,
                unselectedColor: Colors.white,
                pressedColor: Colors.blueAccent.withOpacity(0.1),
              ),
            )),
          ),

          // Monthly Navigation (Only visible for Month tab)
          Obx(() {
            if (controller.currentTab.value == 2) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: controller.prevMonth,
                    ),
                    Text(
                      controller.currentMonthName,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded),
                      onPressed: controller.selectedMonthOffset.value < 0 
                          ? controller.nextMonth 
                          : null,
                      color: controller.selectedMonthOffset.value < 0 ? Colors.black87 : Colors.grey[300],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Main Content
          Expanded(
            child: Obx(() {
               final totalSpent = controller.getTotalSpent();
               
               return SingleChildScrollView(
                 padding: EdgeInsets.all(4.w),
                 child: Column(
                   children: [
                     // Total Spent Card
                     SizedBox(
                       width: double.infinity,
                       child: GlassCard(
                         gradient: [Colors.indigoAccent, Colors.blueAccent],
                         padding: EdgeInsets.all(6.w),
                         child: Column(
                           children: [
                             Text(
                               'Total Spent',
                               style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                             ),
                             SizedBox(height: 0.5.h),
                             FittedBox(
                               child: Text(
                                 '${controller.currencySymbol.value} ${totalSpent.toStringAsFixed(2)}',
                                 style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ),
                     SizedBox(height: 3.h),

                     // Chart Section
                     if (totalSpent > 0) ...[
                       Padding(
                         padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
                         child: Align(
                           alignment: Alignment.centerLeft,
                           child: Text('Category Breakdown', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                         ),
                       ),
                       GlassCard(
                         child: Column(
                           children: [
                             SizedBox(
                               height: 25.h,
                               child: PieChart(
                                 PieChartData(
                                   sections: controller.getCategoryBreakdown(),
                                   centerSpaceRadius: 10.w,
                                   sectionsSpace: 4,
                                 ),
                               ),
                             ),
                             SizedBox(height: 3.h),
                             // Legend
                             Wrap(
                               spacing: 4.w,
                               runSpacing: 1.h,
                               alignment: WrapAlignment.center,
                               children: controller.getCategoryColors().entries.map((entry) {
                                 return Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Container(
                                       width: 10,
                                       height: 10,
                                       decoration: BoxDecoration(color: entry.value, shape: BoxShape.circle),
                                     ),
                                     SizedBox(width: 2.w),
                                     Text(entry.key, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w500)),
                                   ],
                                 );
                               }).toList(),
                             ),
                           ],
                         ),
                       ),
                       SizedBox(height: 3.h),
                     ],

                     // Top Expense
                     if (controller.getTopExpense() != null) ...[
                       Padding(
                         padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
                         child: Align(
                           alignment: Alignment.centerLeft,
                           child: Text('Highest Spending', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                         ),
                       ),
                       GlassCard(
                         padding: EdgeInsets.all(4.w),
                         child: Row(
                           children: [
                             Container(
                               padding: EdgeInsets.all(2.5.w),
                               decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                               child: Icon(Icons.arrow_upward_rounded, color: Colors.red, size: 16.sp),
                             ),
                             SizedBox(width: 4.w),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text(controller.getTopExpense()!.merchant, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp), overflow: TextOverflow.ellipsis),
                                   Text(controller.getTopExpense()!.category, style: TextStyle(color: Colors.grey, fontSize: 9.sp)),
                                 ],
                               ),
                             ),
                             Text(
                               '${controller.currencySymbol.value} ${controller.getTopExpense()!.amount.toStringAsFixed(0)}',
                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.red),
                             ),
                           ],
                         ),
                       ),
                       SizedBox(height: 3.h),
                     ],
                     
                     if (totalSpent == 0)
                       Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Column(
                            children: [
                              Icon(Icons.analytics_outlined, size: 40.sp, color: Colors.grey[300]),
                              SizedBox(height: 2.h),
                              Text('No expenses for this period', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                            ],
                          ),
                       ),

                     // Transaction List
                     if (controller.currentList.isNotEmpty) ...[
                       Padding(
                         padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 1.h),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text('Transactions', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                             if (controller.currentList.length > 3)
                               TextButton(
                                 onPressed: () => controller.isTransactionListExpanded.toggle(),
                                 child: Text(controller.isTransactionListExpanded.value ? 'Show Less' : 'View All', style: TextStyle(fontSize: 10.sp)),
                               ),
                           ],
                         ),
                       ),
                       GlassCard(
                         padding: EdgeInsets.zero,
                         child: ListView.separated(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           itemCount: controller.isTransactionListExpanded.value 
                               ? controller.currentList.length 
                               : (controller.currentList.length > 3 ? 3 : controller.currentList.length),
                           separatorBuilder: (ctx, i) => Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                           itemBuilder: (context, index) {
                             final tx = controller.currentList[index];
                             return ListTile(
                               contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                               leading: Container(
                                 padding: EdgeInsets.all(2.w),
                                 decoration: BoxDecoration(
                                   color: (tx.isIncome ? Colors.green : Colors.red).withOpacity(0.1),
                                   shape: BoxShape.circle,
                                 ),
                                 child: Icon(
                                   tx.isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                                   color: tx.isIncome ? Colors.green : Colors.red,
                                   size: 14.sp,
                                 ),
                               ),
                               title: Text(tx.merchant, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp), overflow: TextOverflow.ellipsis),
                               subtitle: Text(tx.category, style: TextStyle(color: Colors.grey, fontSize: 8.sp)),
                               trailing: Text(
                                 '${tx.isIncome ? '+' : '-'} ${controller.currencySymbol.value} ${tx.amount.toStringAsFixed(2)}',
                                 style: TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 11.sp,
                                   color: tx.isIncome ? Colors.green : Colors.red,
                                 ),
                               ),
                             );
                           },
                         ),
                       ),
                       SizedBox(height: 4.h),
                     ],
                   ],
                 ),
               );
            }),
          ),
        ],
      ),
    );
  }
}
