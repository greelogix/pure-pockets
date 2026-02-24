import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:upgrader/upgrader.dart';
import '../../core/theme/glass_card.dart';
import 'controller.dart';
import '../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.language_rounded, size: 20.sp,color: Color(0xFF00008b)),
            onPressed: () => Get.toNamed(Routes.ALL_MONTHS),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 5.h,
              ),
              Text('Pure ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.blue,
                      letterSpacing: 0.5)),
              Text('Pockets',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Color(0xFF00008b),
                      letterSpacing: 0.5)),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.insights_rounded, size: 20.sp,color: Colors.blue),
              onPressed: () => Get.toNamed(Routes.ANALYTICS),
            ),
            IconButton(
              icon: Icon(Icons.settings_rounded, size: 20.sp,color: Colors.blue,),
              onPressed: () => Get.toNamed(Routes.SETTINGS),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: Obx(() => Column(
          children: [
            _buildMonthNavigator(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    StaggeredGridTile.count(
                      crossAxisCellCount: 4,
                      mainAxisCellCount: 2,
                      child: _buildBalanceCard(),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: _buildChartCard(),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 1,
                      child: _buildQuickScanCard(),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 1,
                      child: _buildSavingsGoalCard(context),
                    ),
                    StaggeredGridTile.count(
                      crossAxisCellCount: 4,
                      mainAxisCellCount: 4.2,
                      child: _buildRecentTransactionsCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return GlassCard(
      gradient: [Colors.blueAccent, Colors.indigoAccent],
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance',
                style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w500),
              ),
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white30, size: 18.sp),
            ],
          ),
          SizedBox(height: 0.2.h),
          FittedBox(
            child: Text(
              '${controller.currencySymbol.value} ${controller.balance.value.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white, fontSize: 26.sp, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              _buildSimpleStat('Income', controller.totalIncome.value, Colors.greenAccent),
              SizedBox(width: 4.w),
              _buildSimpleStat('Expenses', controller.totalExpense.value, Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 8.sp)),
        Text(
          '${controller.currencySymbol.value} ${value.toStringAsFixed(0)}',
          style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Obx(() {
                if (controller.totalExpense.value == 0) {
                  return Center(child: Icon(Icons.pie_chart_outline_rounded, color: Colors.grey[300], size: 40.sp));
                }
                return PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: controller.totalIncome.value,
                        color: Colors.green,
                        radius: 8.w,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: controller.totalExpense.value,
                        color: Colors.red,
                        radius: 8.w,
                        showTitle: false,
                      ),
                    ],
                    sectionsSpace: 4,
                    centerSpaceRadius: 6.w,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickScanCard() {
    return InkWell(
      onTap: () => Get.toNamed(Routes.TRANSACTION_ENTRY),
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.camera_alt_rounded, color: Colors.blueAccent, size: 20.sp),
            ),
            SizedBox(width: 3.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                Text('Transaction', style: TextStyle(color: Colors.grey, fontSize: 9.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsGoalCard(BuildContext context) {
    return InkWell(
      onTap: () => _showGoalEditDialog(context),
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Obx(() {
          final progress = controller.savingsProgress.value;
          final target = controller.savingsTarget.value;
          final current = controller.balance.value > 0 ? controller.balance.value : 0.0;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp)),
                  Icon(Icons.edit_rounded, size: 10.sp, color: Colors.grey),
                ],
              ),
              SizedBox(height: 0.5.h),
              Expanded(
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 10.w,
                          height: 10.w,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(fontSize: 7.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text(
                            '${controller.currencySymbol.value} ${current.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'of ${controller.currencySymbol.value} ${target.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey, fontSize: 7.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showGoalEditDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController(
      text: controller.savingsTarget.value.toStringAsFixed(0),
    );
    String? errorText;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: EdgeInsets.all(6.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Update Monthly Goal',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Savings Target',
                      prefixText: '${controller.currencySymbol.value} ',
                      errorText: errorText,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setDialogState(() => errorText = null);
                      }
                    },
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(width: 2.w),
                      ElevatedButton(
                        onPressed: () {
                          final newValue = double.tryParse(textController.text);
                          if (newValue != null && newValue >= 0) {
                            controller.updateSavingsTarget(newValue);
                            Get.back(); // Close edit dialog
                            
                            Get.dialog(
                              Dialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                child: Padding(
                                  padding: EdgeInsets.all(6.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4.w),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 30.sp),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Goal Updated',
                                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'Your monthly savings target has been updated.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 3.h),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () => Get.back(),
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('Great!'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            setDialogState(() {
                              errorText = 'Please enter a valid number';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                TextButton(
                  onPressed: () => Get.toNamed(Routes.HISTORY, arguments: controller.selectedMonth.value),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('View All', style: TextStyle(fontSize: 10.sp, color: Colors.blueAccent)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.filteredTransactions.isEmpty) {
                return Center(child: Text('No transactions yet', style: TextStyle(color: Colors.grey, fontSize: 10.sp)));
              }
              final list = controller.filteredTransactions.take(5).toList();
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                itemBuilder: (context, index) {
                  final tx = list[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: (tx.isIncome ? Colors.green : Colors.red).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            tx.isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                            color: tx.isIncome ? Colors.green : Colors.red,
                            size: 12.sp,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tx.merchant, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp), overflow: TextOverflow.ellipsis),
                              Text(tx.category, style: TextStyle(color: Colors.grey, fontSize: 8.sp)),
                            ],
                          ),
                        ),
                        Text(
                          '${controller.currencySymbol.value} ${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            color: tx.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, size: 20.sp),
            onPressed: () => controller.previousMonth(),
          ),
          InkWell(
            onTap: () async {
              final selected = await showMonthPicker(
                context: context,
                initialDate: controller.selectedMonth.value,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (selected != null) {
                controller.changeMonth(selected);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Obx(() => Text(
                DateFormat('MMMM yyyy').format(controller.selectedMonth.value),
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              )),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, size: 20.sp),
            onPressed: controller.isNextDisabled ? null : () => controller.nextMonth(),
          ),
        ],
      ),
    );
  }

  static void showQuickActionPopup() {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "Hey Buddy! 💸",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Log your latest spend?",
                  style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey[600]),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: _BentoTile(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        color: Colors.blueAccent,
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.TRANSACTION_ENTRY, arguments: {'autoOpenCamera': true});
                        },
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: _BentoTile(
                        icon: Icons.edit_note_rounded,
                        label: 'Manual',
                        color: Colors.indigoAccent,
                        onTap: () {
                          Get.back();
                          Get.toNamed(Routes.TRANSACTION_ENTRY);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Maybe Later",
                    style: TextStyle(fontSize: 10.sp, color: Colors.blueGrey[400], fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _BentoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BentoTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 16.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28.sp),
            ),
            SizedBox(height: 1.5.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
