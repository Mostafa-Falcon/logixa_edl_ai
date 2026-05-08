import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class ReusableSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final double? radius;
  final VoidCallback? onTap;

  const ReusableSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.border,
    this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding ?? EdgeInsets.all(AppSizes.lg.w),
      decoration: BoxDecoration(
        color: gradient == null ? color ?? AppColors.card : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular((radius ?? AppSizes.radiusLg).r),
        border: border ?? Border.all(color: AppColors.border, width: AppSizes.borderThin),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: content),
    );
  }
}
