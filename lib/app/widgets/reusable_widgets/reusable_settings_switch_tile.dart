import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import 'reusable_text.dart';

class ReusableSettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const ReusableSettingsSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: AppSizes.normalAnimation),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(AppSizes.lg.w),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withValues(alpha: 0.08) : AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: 0.24) : AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: value ? AppColors.primary.withValues(alpha: 0.16) : AppColors.glassBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              ),
              child: Icon(
                icon,
                color: value ? AppColors.primaryHover : AppColors.textMuted,
                size: AppSizes.iconSm.sp,
              ),
            ),
            SizedBox(width: AppSizes.md.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                SizedBox(height: 4.h),
                ReusableText.body(
                  text: subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primaryHover,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
