import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logixa_edl_ai/app/constants/app_colors.dart';
import 'package:logixa_edl_ai/app/constants/app_sizes.dart';
import 'package:logixa_edl_ai/app/constants/app_strings.dart';
import 'package:logixa_edl_ai/app/modules/home/controllers/home_controller.dart';
import 'package:logixa_edl_ai/app/widgets/reusable_widgets/reusable_text.dart';
import 'package:logixa_edl_ai/app/widgets/reusable_widgets/reusable_workspace_item.dart';

class HomeRecentWorkspaces extends GetView<HomeController> {
  const HomeRecentWorkspaces({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ReusableText(
              text: AppStrings.recentWorkspaces,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            Obx(
              () => GestureDetector(
                onTap: controller.showAll.toggle,
                child: ReusableText(
                  text: controller.showAll.value
                      ? AppStrings.showLess
                      : AppStrings.showAll,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: controller.showAll.value
                      ? AppColors.warning
                      : AppColors.primaryHover,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.xl.h),
        Obx(() {
          final workspaces = controller.recentWorkspaces;

          if (workspaces.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: AppSizes.xxl.h),
              child: const Center(
                child: ReusableText.body(
                  text: AppStrings.noRecentWorkspaces,
                  color: AppColors.closeButtonHover,
                ),
              ),
            );
          }

          return Container(
            height: 370.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: AppSizes.borderThin),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.xl.w,
              vertical: AppSizes.md.h,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSizes.xxl.w,
                  right: AppSizes.xxl.w,
                  top: AppSizes.md.h,
                  bottom: AppSizes.md.h,
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: workspaces.isEmpty
                      ? 0
                      : workspaces.length.clamp(
                          0,
                          controller.showAll.value ? workspaces.length : 3,
                        ),
                  itemBuilder: (context, index) {
                    final workspace = workspaces[index];
                    return ReusableWorkspaceItem(
                      workspace: workspace,
                      onTap: () => controller.openRecentWorkspace(workspace),
                      onDelete: () =>
                          controller.confirmDeleteWorkspace(workspace),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
