import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/data_center_controller.dart';

class DataCenterOverviewSection extends GetView<DataCenterController> {
  const DataCenterOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.snapshot.value.status;
      final cards = [
        _StatCardData(
          title: AppStrings.memoryConversationsLabel,
          value: status.conversations.toString(),
          icon: Icons.forum_rounded,
          color: AppColors.primary,
        ),
        _StatCardData(
          title: AppStrings.memoryMessagesLabel,
          value: status.messages.toString(),
          icon: Icons.message_rounded,
          color: AppColors.secondary,
        ),
        _StatCardData(
          title: AppStrings.memoryItemsLabel,
          value: status.memoryItems.toString(),
          icon: Icons.dataset_rounded,
          color: AppColors.accent,
        ),
        _StatCardData(
          title: AppStrings.memoryExpertsLabel,
          value: status.experts.toString(),
          icon: Icons.psychology_rounded,
          color: AppColors.success,
        ),
        _StatCardData(
          title: AppStrings.memoryWorkspaceSessionsLabel,
          value: status.workspaceSessions.toString(),
          icon: Icons.workspaces_rounded,
          color: AppColors.warning,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ReusableText(
            text: AppStrings.memoryOverviewTitle,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: AppSizes.md.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth =
                  (constraints.maxWidth - (AppSizes.md.w * 4)) / 5;
              return Wrap(
                spacing: AppSizes.md.w,
                runSpacing: AppSizes.md.h,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: cardWidth < 180.w ? 180.w : cardWidth,
                        child: _MemoryStatCard(data: card),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      );
    });
  }
}

class _MemoryStatCard extends StatelessWidget {
  final _StatCardData data;

  const _MemoryStatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      padding: EdgeInsets.all(AppSizes.lg.w),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              border: Border.all(color: data.color.withValues(alpha: 0.28)),
            ),
            child: Icon(data.icon, color: data.color, size: 22.sp),
          ),
          SizedBox(width: AppSizes.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: data.title,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMuted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizes.xs.h),
                ReusableText(
                  text: data.value,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
