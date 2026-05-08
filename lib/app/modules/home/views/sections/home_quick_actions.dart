import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_action_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/home_controller.dart';

class HomeQuickActions extends GetView<HomeController> {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ReusableText(
          text: AppStrings.quickActions,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        SizedBox(height: AppSizes.xl.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: AppSizes.lg.w,
            mainAxisSpacing: AppSizes.lg.h,
            childAspectRatio: 1.75,
          ),
          itemCount: controller.quickActions.length,
          itemBuilder: (context, index) {
            final action = controller.quickActions[index];

            return ReusableActionCard(
              action: action,
              onTap: () => controller.handleQuickAction(action.type),
            );
          },
        ),
      ],
    );
  }
}
