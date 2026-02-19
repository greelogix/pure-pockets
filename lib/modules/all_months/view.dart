import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'controller.dart';
import '../../routes/app_routes.dart';
import '../dashboard/controller.dart';
import '../../core/theme/glass_card.dart';

class AllMonthsView extends GetView<AllMonthsController> {
  const AllMonthsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Global Overview', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.monthSummaries.isEmpty) {
          return Center(child: Text('No transaction history found.', style: TextStyle(fontSize: 12.sp)));
        }

        return Column(
          children: [
            // Total Balance Card
            Padding(
              padding: EdgeInsets.all(4.w),
              child: _buildGlobalBalanceCard(),
            ),
            
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 1.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Monthly Summaries',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                itemCount: controller.monthSummaries.length,
                separatorBuilder: (ctx, i) => SizedBox(height: 1.5.h),
                itemBuilder: (context, index) {
                  final summary = controller.monthSummaries[index];
                  return _buildMonthItem(summary);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildGlobalBalanceCard() {
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        gradient: [Colors.blueAccent, Colors.indigoAccent],
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            Text(
              'Total Cumulative Balance',
              style: TextStyle(fontSize: 10.sp, color: Colors.white70),
            ),
            SizedBox(height: 0.5.h),
            FittedBox(
              child: Text(
                '${controller.currencySymbol.value} ${controller.totalBalance.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthItem(MonthSummary summary) {
    final isPositive = summary.net >= 0;
    
    return InkWell(
      onTap: () {
        try {
          final dash = Get.find<DashboardController>();
          dash.changeMonth(summary.month);
          Get.back();
        } catch (e) {
          Get.offAllNamed(Routes.DASHBOARD);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isPositive ? Colors.green : Colors.red,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(summary.month),
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 0.2.h),
                  Text(
                    'Net: ${controller.currencySymbol.value} ${summary.net.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+ ${controller.currencySymbol.value} ${summary.income.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 9.sp, color: Colors.green, fontWeight: FontWeight.bold),
                ),
                Text(
                  '- ${controller.currencySymbol.value} ${summary.expense.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 9.sp, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(width: 2.w),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 18.sp),
          ],
        ),
      ),
    );
  }
}
