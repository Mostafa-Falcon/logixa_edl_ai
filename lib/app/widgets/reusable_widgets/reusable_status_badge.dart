import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import 'reusable_text.dart';

class ReusableStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const ReusableStatusBadge({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13.sp),
            SizedBox(width: 6.w),
          ] else ...[
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
          ],
          ReusableText(
            text: label,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ],
      ),
    );
  }
}
