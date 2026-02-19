import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'controller.dart';
import '../../core/theme/glass_card.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -10.h,
            right: -10.w,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: -20.w,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigoAccent.withOpacity(0.03),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(6.w),
              child: Column(
                children: [
                  // Progress Header
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (controller.currentStep.value + 1) / 4,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                            minHeight: 0.8.h,
                          ),
                        )),
                      ),
                      SizedBox(width: 4.w),
                      Obx(() => Text(
                        '${controller.currentStep.value + 1}/4',
                        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[300]),
                      )),
                    ],
                  ),
                  
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Obx(() => _buildStepContent(context)),
                      ),
                    ),
                  ),

                  // Navigation Buttons
                  Obx(() => Row(
                    children: [
                      if (controller.currentStep.value > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controller.previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              side: BorderSide(color: Colors.blueGrey[100]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text('Back', style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey[600], fontWeight: FontWeight.w600)),
                          ),
                        ),
                      if (controller.currentStep.value > 0) SizedBox(width: 4.w),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 7.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.indigoAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.blueAccent.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controller.nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: Text(
                              controller.currentStep.value == 3 ? 'Get Started' : 'Continue',
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (controller.currentStep.value) {
      case 0:
        return _buildStep(
          icon: Icons.waving_hand_rounded,
          color: Colors.blueAccent,
          title: "Welcome! 👋",
          subtitle: "How should we call you? Your comfort matters.",
          input: Obx(() => _buildTextField(
            controller: controller.nameController,
            label: 'Your Name',
            icon: Icons.person_rounded,
            errorText: controller.nameError.value,
            textCapitalization: TextCapitalization.words,
          )),
        );
      case 1:
        return _buildStep(
          icon: Icons.language_rounded,
          color: Colors.indigoAccent,
          title: "Where are you?",
          subtitle: "We'll tailor your currency automatically.",
          input: Obx(() => DropdownButtonFormField<String>(
            value: controller.selectedCountry.value,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(20),
            icon: Icon(Icons.expand_more_rounded, color: Colors.blueGrey[400]),
            style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey[900], fontWeight: FontWeight.w600),
            decoration: _inputDecoration('Select Country', Icons.public_rounded),
            items: controller.countries.keys.map((country) {
              final data = controller.countries[country]!;
              return DropdownMenuItem(
                value: country,
                child: Text('$country (${data['symbol']})'),
              );
            }).toList(),
            onChanged: (v) => v != null ? controller.selectedCountry.value = v : null,
          )),
        );
      case 2:
        return _buildStep(
          icon: Icons.payments_rounded,
          color: Colors.green,
          title: "Monthly Income",
          subtitle: "Tracking your base income helps us calculate your health.",
          input: Obx(() => _buildTextField(
            controller: controller.monthlyIncomeController,
            label: 'Monthly Income',
            icon: Icons.account_balance_wallet_rounded,
            prefix: controller.countries[controller.selectedCountry.value]!['symbol'],
            errorText: controller.incomeError.value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          )),
        );
      case 3:
        return _buildStep(
          icon: Icons.auto_graph_rounded,
          color: Colors.amber,
          title: "Savings Target",
          subtitle: "Stay motivated by setting a realistic goal.",
          input: Obx(() => _buildTextField(
            controller: controller.savingsTargetController,
            label: 'Monthly Goal',
            icon: Icons.savings_rounded,
            prefix: controller.countries[controller.selectedCountry.value]!['symbol'],
            errorText: controller.savingsError.value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          )),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required Widget input,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 45.sp, color: color),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900], letterSpacing: -0.5),
        ),
        SizedBox(height: 1.5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: Colors.blueGrey[400], height: 1.4),
          ),
        ),
        SizedBox(height: 6.h),
        GlassCard(
          padding: EdgeInsets.all(6.w),
          child: input,
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    String? errorText,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon, errorText: errorText).copyWith(
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 9.sp, color: Colors.blueGrey[300], fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, size: 16.sp, color: Colors.blueAccent.withOpacity(0.5)),
      errorText: errorText,
      errorStyle: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.blueGrey[50]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.blueGrey[50]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }
}
