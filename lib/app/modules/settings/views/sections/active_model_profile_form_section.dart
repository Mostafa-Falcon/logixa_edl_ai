import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_settings_switch_tile.dart';
import '../../../../widgets/reusable_widgets/reusable_settings_text_field.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/settings_controller.dart';

class ActiveModelProfileFormSection extends GetView<SettingsController> {
  const ActiveModelProfileFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = controller.settingsService;

    return ReusableSurfaceCard(
      color: AppColors.panel,
      padding: EdgeInsets.all(AppSizes.xxl.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReusableText(
            text: AppStrings.activeModelProfileTitle,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          SizedBox(height: AppSizes.sm.h),
          const ReusableText.body(text: AppStrings.activeModelProfileDescription),
          SizedBox(height: AppSizes.xl.h),
          ReusableSettingsTextField(
            label: AppStrings.modelNameLabel,
            hint: AppStrings.modelNameHint,
            controller: controller.modelNameController,
          ),
          SizedBox(height: AppSizes.md.h),
          ReusableSettingsTextField(
            label: AppStrings.modelPathLabel,
            hint: AppStrings.modelPathHint,
            controller: controller.modelPathController,
            readOnly: true,
            suffix: Obx(
              () => ReusableButton(
                title: AppStrings.chooseModelFileButton,
                icon: Icons.folder_open_rounded,
                isLoading: controller.isPickingModel.value,
                variant: ReusableButtonVariant.secondary,
                onPressed: controller.pickLocalModelFile,
              ),
            ),
          ),
          SizedBox(height: AppSizes.xl.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final useTwoColumns = constraints.maxWidth > 760.w;
              final fields = [
                ReusableSettingsTextField(
                  label: AppStrings.contextSizeLabel,
                  hint: '2048',
                  controller: controller.contextSizeController,
                  keyboardType: TextInputType.number,
                ),
                ReusableSettingsTextField(
                  label: AppStrings.threadsLabel,
                  hint: '4',
                  controller: controller.threadsController,
                  keyboardType: TextInputType.number,
                ),
                ReusableSettingsTextField(
                  label: AppStrings.batchSizeLabel,
                  hint: '256',
                  controller: controller.batchSizeController,
                  keyboardType: TextInputType.number,
                ),
                ReusableSettingsTextField(
                  label: AppStrings.maxTokensLabel,
                  hint: '512',
                  controller: controller.maxTokensController,
                  keyboardType: TextInputType.number,
                ),
                ReusableSettingsTextField(
                  label: AppStrings.temperatureLabel,
                  hint: '1.0',
                  controller: controller.temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                ReusableSettingsTextField(
                  label: AppStrings.topPLabel,
                  hint: '0.95',
                  controller: controller.topPController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                ReusableSettingsTextField(
                  label: AppStrings.topKLabel,
                  hint: '64',
                  controller: controller.topKController,
                  keyboardType: TextInputType.number,
                ),
                ReusableSettingsTextField(
                  label: AppStrings.repeatPenaltyLabel,
                  hint: '1.10',
                  controller: controller.repeatPenaltyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                ReusableSettingsTextField(
                  label: AppStrings.presencePenaltyLabel,
                  hint: '0.10',
                  controller: controller.presencePenaltyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                ReusableSettingsTextField(
                  label: AppStrings.modelRoleLabel,
                  hint: 'fast / quality / coding',
                  controller: controller.modelRoleController,
                ),
                ReusableSettingsTextField(
                  label: AppStrings.loadPolicyLabel,
                  hint: 'on_demand',
                  controller: controller.loadPolicyController,
                ),
                ReusableSettingsTextField(
                  label: AppStrings.ramPolicyLabel,
                  hint: 'conservative',
                  controller: controller.ramPolicyController,
                ),
              ];

              if (!useTwoColumns) {
                return Column(
                  children: [
                    for (final field in fields) ...[
                      field,
                      SizedBox(height: AppSizes.md.h),
                    ],
                  ],
                );
              }

              return Wrap(
                spacing: AppSizes.lg.w,
                runSpacing: AppSizes.md.h,
                children: [
                  for (final field in fields)
                    SizedBox(
                      width: (constraints.maxWidth - AppSizes.lg.w) / 2,
                      child: field,
                    ),
                ],
              );
            },
          ),
          SizedBox(height: AppSizes.md.h),
          ReusableSettingsTextField(
            label: AppStrings.promptTemplateLabel,
            hint: AppStrings.promptTemplateHint,
            controller: controller.promptTemplateController,
            maxLines: 4,
          ),
          SizedBox(height: AppSizes.xl.h),
          Obx(
            () => ReusableSettingsSwitchTile(
              title: AppStrings.keepModelLoadedLabel,
              subtitle: AppStrings.keepModelLoadedDescription,
              value: settingsService.activeModelProfile.value.keepModelLoaded,
              icon: Icons.memory_rounded,
              onChanged: controller.setKeepModelLoaded,
            ),
          ),
          SizedBox(height: AppSizes.md.h),
          Obx(
            () => ReusableSettingsSwitchTile(
              title: AppStrings.unloadAfterResponseLabel,
              subtitle: AppStrings.unloadAfterResponseDescription,
              value: settingsService.activeModelProfile.value.unloadAfterResponse,
              icon: Icons.power_off_rounded,
              onChanged: controller.setUnloadAfterResponse,
            ),
          ),
          SizedBox(height: AppSizes.xxl.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(
                () => ReusableButton(
                  title: AppStrings.saveSettingsButton,
                  icon: Icons.save_rounded,
                  isLoading: controller.isSaving.value,
                  onPressed: () => controller.saveLocalModelSettings(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
