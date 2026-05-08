import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_model_profile_card.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/settings_controller.dart';

class ModelProfilesSection extends GetView<SettingsController> {
  const ModelProfilesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = controller.settingsService;

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
                      text: AppStrings.modelProfilesTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                    SizedBox(height: 6),
                    ReusableText.body(text: AppStrings.modelProfilesDescription),
                  ],
                ),
              ),
              ReusableButton(
                title: AppStrings.addModelProfileButton,
                icon: Icons.add_rounded,
                variant: ReusableButtonVariant.secondary,
                onPressed: controller.createModelProfile,
              ),
            ],
          ),
          SizedBox(height: AppSizes.xl.h),
          Obx(() {
            final profiles = settingsService.modelProfiles.toList(growable: false);
            final activeProfileId = settingsService.activeModelProfile.value.id;

            return LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth > 980.w;
                final cardWidth = useTwoColumns
                    ? (constraints.maxWidth - AppSizes.lg.w) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: AppSizes.lg.w,
                  runSpacing: AppSizes.lg.h,
                  children: [
                    for (final profile in profiles)
                      SizedBox(
                        width: cardWidth,
                        child: ReusableModelProfileCard(
                          profile: profile,
                          isActive: profile.id == activeProfileId,
                          onSelect: () => controller.selectModelProfile(profile.id),
                          onDelete: () => controller.deleteModelProfile(profile.id),
                        ),
                      ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
