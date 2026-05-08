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
import '../../controllers/data_center_controller.dart';

class DataCenterHeaderSection extends GetView<DataCenterController> {
  const DataCenterHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      padding: EdgeInsets.all(AppSizes.xl.w),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              Icons.hub_rounded,
              color: AppColors.primaryHover,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSizes.lg.w),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText.title(text: AppStrings.dataCenterPageTitle),
                SizedBox(height: 6),
                ReusableText.body(text: AppStrings.dataCenterPageSubtitle),
              ],
            ),
          ),
          Obx(() {
            final status = controller.engineClientService.engineStatus.value;
            final color = status.isOnline ? AppColors.success : AppColors.error;
            return ReusableStatusBadge(
              label: status.isOnline
                  ? AppStrings.engineOnline
                  : AppStrings.engineOffline,
              icon: status.isOnline
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: color,
            );
          }),
          SizedBox(width: AppSizes.md.w),
          Obx(() {
            return ReusableButton(
              title: AppStrings.dataCenterRefreshButton,
              icon: Icons.refresh_rounded,
              isLoading: controller.isLoading.value,
              onPressed: controller.refreshMemoryDashboard,
            );
          }),
        ],
      ),
    );
  }
}
