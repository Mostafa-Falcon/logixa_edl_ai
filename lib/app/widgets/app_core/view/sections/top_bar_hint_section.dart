import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../reusable_widgets/reusable_text.dart';

class TopBarHintSection extends StatelessWidget {
  const TopBarHintSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.md.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull.r),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_command_key_rounded,
            size: 13.sp,
            color: AppColors.textMuted,
          ),
          SizedBox(width: 6.w),
          ReusableText(
            text: AppStrings.commandHint,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            textScaler: TextScaler.noScaling,
          ),
        ],
      ),
    );
  }
}
