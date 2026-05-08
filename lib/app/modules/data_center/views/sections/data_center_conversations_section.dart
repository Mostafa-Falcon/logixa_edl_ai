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

class DataCenterConversationsSection extends GetView<DataCenterController> {
  const DataCenterConversationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      padding: EdgeInsets.all(AppSizes.lg.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: ReusableText(
                  text: AppStrings.memoryConversationsTitle,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(() {
                return ReusableStatusBadge(
                  label: controller.snapshot.value.conversations.length
                      .toString(),
                  icon: Icons.forum_rounded,
                  color: AppColors.primary,
                );
              }),
            ],
          ),
          SizedBox(height: AppSizes.lg.h),
          Expanded(
            child: Obx(() {
              final conversations = controller.snapshot.value.conversations;
              if (conversations.isEmpty) {
                return const Center(
                  child: ReusableText.body(
                    text: AppStrings.memoryNoConversations,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSizes.sm.h),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final isSelected = controller.isConversationSelected(
                    conversation.id,
                  );

                  return _ConversationTile(
                    title: conversation.title,
                    subtitle: controller.compactPath(
                      conversation.workspacePath,
                    ),
                    time: controller.formatEpoch(conversation.updatedAt),
                    isSelected: isSelected,
                    onTap: () => controller.selectConversation(conversation.id),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppSizes.md.w),
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.14)
          : AppColors.surface,
      border: Border.all(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.55)
            : AppColors.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ReusableText(
                  text: title,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSizes.sm.w),
              ReusableText(
                text: time,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: AppSizes.xs.h),
          ReusableText(
            text: subtitle,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
