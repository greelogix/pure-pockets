import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final List<Color>? gradient;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Border? border;

  const GlassCard({
    Key? key,
    required this.child,
    this.color,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(0.8),
            gradient: gradient != null
                ? LinearGradient(
                    colors: gradient!.map((c) => c.withOpacity(0.9)).toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(borderRadius ?? 24),
            border: border ?? Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(4.w),
            child: child,
          ),
        ),
      ),
    );
  }
}
