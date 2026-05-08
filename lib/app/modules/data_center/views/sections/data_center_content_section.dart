import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/data_center_controller.dart';
import 'data_center_conversations_section.dart';
import 'data_center_messages_section.dart';
import 'data_center_snapshot_section.dart';

class DataCenterContentSection extends GetView<DataCenterController> {
  const DataCenterContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.errorMessage.value;
      if (error != null) {
        return ReusableSurfaceCard(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.error,
                  size: 44.sp,
                ),
                SizedBox(height: AppSizes.md.h),
                const ReusableText(
                  text: AppStrings.dataCenterLoadFailed,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSizes.sm.h),
                ReusableText.body(
                  text: error.isEmpty
                      ? AppStrings.dataCenterEngineRequired
                      : error,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 340, child: DataCenterConversationsSection()),
          SizedBox(width: AppSizes.lg.w),
          const Expanded(child: DataCenterMessagesSection()),
          SizedBox(width: AppSizes.lg.w),
          const SizedBox(width: 360, child: DataCenterSnapshotSection()),
        ],
      );
    });
  }
}
