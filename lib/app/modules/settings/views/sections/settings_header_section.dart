import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';

class SettingsHeaderSection extends StatelessWidget {
  const SettingsHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      color: AppColors.card,
      padding: EdgeInsets.all(AppSizes.xxl.w),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppColors.textOnPrimary,
              size: AppSizes.iconLg.sp,
            ),
          ),
          SizedBox(width: AppSizes.lg.w),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText.title(text: AppStrings.settingsPageTitle),
                ReusableText.body(text: AppStrings.settingsPageSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
