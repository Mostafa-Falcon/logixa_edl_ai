import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_status_badge.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/settings_controller.dart';

class RuntimeModelRouterSection extends GetView<SettingsController> {
  const RuntimeModelRouterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      color: AppColors.panel,
      padding: EdgeInsets.all(AppSizes.xxl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: AppStrings.runtimeRouterTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    SizedBox(height: 6),
                    ReusableText.body(
                      text: AppStrings.runtimeRouterDescription,
                    ),
                  ],
                ),
              ),
              Obx(() {
                final activeMode = controller.activeRuntimeRouterMode;
                return ReusableStatusBadge(
                  label:
                      activeMode == SettingsController.runtimeRouterQualityMode
                      ? AppStrings.runtimeRouterQualityActiveBadge
                      : AppStrings.runtimeRouterFastActiveBadge,
                  color:
                      activeMode == SettingsController.runtimeRouterQualityMode
                      ? AppColors.accentSoft
                      : AppColors.runtimeRunning,
                  icon:
                      activeMode == SettingsController.runtimeRouterQualityMode
                      ? Icons.psychology_alt_rounded
                      : Icons.flash_on_rounded,
                );
              }),
            ],
          ),
          SizedBox(height: AppSizes.lg.h),
          const ReusableText.body(text: AppStrings.runtimeRouterGuardNote),
          SizedBox(height: AppSizes.xl.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth > 860.w;
              final cardWidth = useTwoColumns
                  ? (constraints.maxWidth - AppSizes.lg.w) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: AppSizes.lg.w,
                runSpacing: AppSizes.lg.h,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _RuntimeRouterModeCard(
                      title: AppStrings.runtimeRouterFastTitle,
                      subtitle: AppStrings.runtimeRouterFastDescription,
                      profileLabelBuilder: () =>
                          controller.fastRuntimeProfileLabel,
                      isAvailableBuilder: () =>
                          controller.hasFastRuntimeProfile,
                      isActiveBuilder: () =>
                          controller.activeRuntimeRouterMode ==
                          SettingsController.runtimeRouterFastMode,
                      icon: Icons.flash_on_rounded,
                      onPressed: () => controller.selectRuntimeRouterMode(
                        SettingsController.runtimeRouterFastMode,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _RuntimeRouterModeCard(
                      title: AppStrings.runtimeRouterQualityTitle,
                      subtitle: AppStrings.runtimeRouterQualityDescription,
                      profileLabelBuilder: () =>
                          controller.qualityRuntimeProfileLabel,
                      isAvailableBuilder: () =>
                          controller.hasQualityRuntimeProfile,
                      isActiveBuilder: () =>
                          controller.activeRuntimeRouterMode ==
                          SettingsController.runtimeRouterQualityMode,
                      icon: Icons.psychology_alt_rounded,
                      onPressed: () => controller.selectRuntimeRouterMode(
                        SettingsController.runtimeRouterQualityMode,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RuntimeRouterModeCard extends GetView<SettingsController> {
  final String title;
  final String subtitle;
  final String Function() profileLabelBuilder;
  final bool Function() isAvailableBuilder;
  final bool Function() isActiveBuilder;
  final IconData icon;
  final VoidCallback onPressed;

  const _RuntimeRouterModeCard({
    required this.title,
    required this.subtitle,
    required this.profileLabelBuilder,
    required this.isAvailableBuilder,
    required this.isActiveBuilder,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = isActiveBuilder();
      final isAvailable = isAvailableBuilder();

      return Container(
        padding: EdgeInsets.all(AppSizes.xl.w),
        decoration: BoxDecoration(
          color: isActive ? AppColors.glassBackgroundStrong : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 22.w,
                  color: isActive
                      ? AppColors.primaryHover
                      : AppColors.textMuted,
                ),
                SizedBox(width: AppSizes.sm.w),
                Expanded(
                  child: ReusableText(
                    text: title,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ReusableStatusBadge(
                  label: isActive
                      ? AppStrings.runtimeRouterActiveLabel
                      : isAvailable
                      ? AppStrings.runtimeRouterAvailableLabel
                      : AppStrings.runtimeRouterMissingLabel,
                  color: isActive
                      ? AppColors.runtimeRunning
                      : isAvailable
                      ? AppColors.info
                      : AppColors.warning,
                ),
              ],
            ),
            SizedBox(height: AppSizes.md.h),
            ReusableText.body(text: subtitle),
            SizedBox(height: AppSizes.md.h),
            ReusableText(
              text:
                  '${AppStrings.runtimeRouterLinkedProfilePrefix} ${profileLabelBuilder()}',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.lg.h),
            ReusableButton(
              title: isActive
                  ? AppStrings.runtimeRouterCurrentButton
                  : AppStrings.runtimeRouterSelectButton,
              icon: isActive ? Icons.check_rounded : Icons.swap_horiz_rounded,
              variant: isActive
                  ? ReusableButtonVariant.secondary
                  : ReusableButtonVariant.primary,
              onPressed: isActive ? null : onPressed,
              isLoading: controller.isSaving.value,
              expanded: true,
            ),
          ],
        ),
      );
    });
  }
}
