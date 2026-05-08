import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_settings_text_field.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/settings_controller.dart';

class SystemPromptSettingsSection extends GetView<SettingsController> {
  const SystemPromptSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      color: AppColors.panel,
      padding: EdgeInsets.all(AppSizes.xxl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.primaryHover,
                  size: AppSizes.iconMd.sp,
                ),
              ),
              SizedBox(width: AppSizes.md.w),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: AppStrings.systemPromptTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    SizedBox(height: 6),
                    ReusableText.body(text: AppStrings.systemPromptDescription),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.xl.h),
          ReusableSettingsTextField(
            label: AppStrings.systemPromptLabel,
            hint: AppStrings.systemPromptHint,
            controller: controller.systemPromptController,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: AppSizes.lg.h),
          Wrap(
            spacing: AppSizes.md.w,
            runSpacing: AppSizes.md.h,
            alignment: WrapAlignment.end,
            children: [
              ReusableButton(
                title: AppStrings.resetSystemPromptButton,
                icon: Icons.restart_alt_rounded,
                variant: ReusableButtonVariant.secondary,
                onPressed: controller.resetSystemPrompt,
              ),
              Obx(
                () => ReusableButton(
                  title: AppStrings.saveSystemPromptButton,
                  icon: Icons.save_as_rounded,
                  isLoading: controller.isSaving.value,
                  onPressed: () => controller.saveSystemPrompt(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
