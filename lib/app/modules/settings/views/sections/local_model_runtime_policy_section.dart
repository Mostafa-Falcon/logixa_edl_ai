import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_settings_switch_tile.dart';
import '../../../../widgets/reusable_widgets/reusable_status_badge.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/settings_controller.dart';

class LocalModelRuntimePolicySection extends GetView<SettingsController> {
  const LocalModelRuntimePolicySection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = controller.settingsService;

    return ReusableSurfaceCard(
      color: AppColors.surface,
      padding: EdgeInsets.all(AppSizes.xxl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ReusableText(
                        text: AppStrings.localModelSettingsTitle,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                      SizedBox(height: AppSizes.sm.h),
                      const ReusableText.body(
                        text: AppStrings.localModelSettingsDescription,
                      ),
                    ],
                  ),
                ),
                ReusableStatusBadge(
                  label: settingsService.localModelEnabled.value
                      ? AppStrings.localModelReady
                      : AppStrings.localModelOff,
                  color: settingsService.localModelEnabled.value
                      ? AppColors.runtimeRunning
                      : AppColors.runtimeOff,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.xxl.h),
          Obx(
            () => ReusableSettingsSwitchTile(
              title: AppStrings.localModelEnabledLabel,
              subtitle: AppStrings.localModelEnabledDescription,
              value: settingsService.localModelEnabled.value,
              icon: Icons.power_settings_new_rounded,
              onChanged: controller.setLocalModelEnabled,
            ),
          ),
          SizedBox(height: AppSizes.md.h),
          Obx(
            () => ReusableSettingsSwitchTile(
              title: AppStrings.autoStartOnMessageLabel,
              subtitle: AppStrings.autoStartOnMessageDescription,
              value: settingsService.autoStartOnMessage.value,
              icon: Icons.play_circle_outline_rounded,
              onChanged: controller.setAutoStartOnMessage,
            ),
          ),
          SizedBox(height: AppSizes.md.h),
          Obx(
            () => ReusableSettingsSwitchTile(
              title: AppStrings.allowBackgroundModelLabel,
              subtitle: AppStrings.allowBackgroundModelDescription,
              value: settingsService.allowBackgroundModel.value,
              icon: Icons.battery_saver_rounded,
              onChanged: controller.setAllowBackgroundModel,
            ),
          ),
        ],
      ),
    );
  }
}
