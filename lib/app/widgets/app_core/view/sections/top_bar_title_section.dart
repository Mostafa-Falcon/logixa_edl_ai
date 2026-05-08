import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../reusable_widgets/reusable_status_badge.dart';
import '../../../reusable_widgets/reusable_text.dart';
import '../../controller/top_bar_controller.dart';

class TopBarTitleSection extends GetView<TopBarController> {
  const TopBarTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _TopBarLogo(),
        SizedBox(width: AppSizes.md.w),
        const _TopBarTitleBlock(),
        SizedBox(width: AppSizes.md.w),
        Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: AppSizes.normalAnimation),
            child: ReusableStatusBadge(
              key: ValueKey(controller.isLocalModelEnabled.value),
              label: controller.isLocalModelEnabled.value
                  ? AppStrings.localModelReady
                  : AppStrings.localModelOff,
              color: controller.isLocalModelEnabled.value
                  ? AppColors.runtimeRunning
                  : AppColors.runtimeOff,
            ),
          ),
        ),
        SizedBox(width: AppSizes.md.w),
        Obx(() {
          final label = controller.engineStatusLabel;
          final color = controller.engineStatusColor;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: AppSizes.normalAnimation),
            child: ReusableStatusBadge(
              key: ValueKey(label),
              label: label,
              color: color,
              icon: Icons.router_rounded,
            ),
          );
        }),
      ],
    );
  }
}

class _TopBarLogo extends StatelessWidget {
  const _TopBarLogo();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.32),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome_motion_rounded,
          color: Colors.white,
          size: AppSizes.iconSm.sp,
        ),
      ),
    );
  }
}

class _TopBarTitleBlock extends StatelessWidget {
  const _TopBarTitleBlock();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 300.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableText(
            text: AppStrings.topBarTitle,
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.noScaling,
          ),
          SizedBox(height: 2.h),
          ReusableText(
            text: AppStrings.topBarSubtitle,
            fontSize: 9.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.noScaling,
          ),
        ],
      ),
    );
  }
}
