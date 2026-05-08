import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_status_badge.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/data_center_controller.dart';

class DataCenterSnapshotSection extends GetView<DataCenterController> {
  const DataCenterSnapshotSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      padding: EdgeInsets.all(AppSizes.lg.w),
      child: Obx(() {
        final snapshot = controller.snapshot.value;
        final profile = snapshot.selectedModelProfile;

        return ListView(
          children: [
            const ReusableText(
              text: AppStrings.memorySnapshotTitle,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: AppSizes.md.h),
            _InfoBlock(
              icon: Icons.model_training_rounded,
              title: AppStrings.memorySelectedProfileLabel,
              value: profile.profileId == null
                  ? AppStrings.memoryProfileSnapshotEmpty
                  : profile.displayName,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.sm.h),
            _InfoBlock(
              icon: Icons.storage_rounded,
              title: AppStrings.memoryDbPathLabel,
              value: controller.compactPath(snapshot.status.dbPath),
              color: AppColors.secondary,
            ),
            SizedBox(height: AppSizes.lg.h),
            const ReusableText(
              text: AppStrings.memorySideDataTitle,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: AppSizes.md.h),
            _CountLine(
              label: AppStrings.memoryItemsLabel,
              count: snapshot.memoryItems.length,
              emptyText: AppStrings.memoryNoMemoryItems,
              color: AppColors.accent,
            ),
            SizedBox(height: AppSizes.sm.h),
            _CountLine(
              label: AppStrings.memoryExpertsLabel,
              count: snapshot.experts.length,
              emptyText: AppStrings.memoryNoExperts,
              color: AppColors.success,
            ),
            SizedBox(height: AppSizes.sm.h),
            _CountLine(
              label: AppStrings.memoryWorkspaceSessionsLabel,
              count: snapshot.workspaceSessions.length,
              emptyText: AppStrings.memoryNoWorkspaceSessions,
              color: AppColors.warning,
            ),
            SizedBox(height: AppSizes.lg.h),
            ...snapshot.memoryItems.take(4).map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm.h),
                child: _InfoBlock(
                  icon: Icons.bookmark_rounded,
                  title: item.key,
                  value: controller.compactText(item.value, maxChars: 96),
                  color: AppColors.accent,
                ),
              );
            }),
            ...snapshot.experts.take(4).map((expert) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm.h),
                child: _InfoBlock(
                  icon: Icons.psychology_rounded,
                  title: expert.name,
                  value: controller.compactText(
                    expert.systemPrompt,
                    maxChars: 96,
                  ),
                  color: AppColors.success,
                ),
              );
            }),
            ...snapshot.workspaceSessions.take(4).map((session) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm.h),
                child: _InfoBlock(
                  icon: Icons.folder_copy_rounded,
                  title: session.workspaceName ?? 'Workspace',
                  value: controller.compactPath(session.workspacePath),
                  color: AppColors.warning,
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md.w),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: AppSizes.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: title,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizes.xs.h),
                ReusableText(
                  text: value,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  maxLines: 3,
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

class _CountLine extends StatelessWidget {
  final String label;
  final int count;
  final String emptyText;
  final Color color;

  const _CountLine({
    required this.label,
    required this.count,
    required this.emptyText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReusableStatusBadge(label: count.toString(), color: color),
        SizedBox(width: AppSizes.sm.w),
        Expanded(
          child: ReusableText(
            text: count == 0 ? emptyText : label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
