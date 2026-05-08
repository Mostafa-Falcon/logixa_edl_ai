import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';

class ChatHeaderSection extends StatelessWidget {
  const ChatHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      padding: EdgeInsets.all(AppSizes.xl.w),
      gradient: AppColors.panelGradient,
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: AppColors.primaryHover,
              size: AppSizes.iconMd.sp,
            ),
          ),
          SizedBox(width: AppSizes.md.w),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText.title(text: AppStrings.chatPageTitle),
                ReusableText.body(text: AppStrings.chatPageSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
