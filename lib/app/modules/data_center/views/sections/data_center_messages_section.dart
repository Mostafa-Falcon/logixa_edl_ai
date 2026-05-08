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

class DataCenterMessagesSection extends GetView<DataCenterController> {
  const DataCenterMessagesSection({super.key});

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
                  text: AppStrings.memoryMessagesTitle,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(() {
                return ReusableStatusBadge(
                  label: controller.snapshot.value.messages.length.toString(),
                  icon: Icons.message_rounded,
                  color: AppColors.secondary,
                );
              }),
            ],
          ),
          SizedBox(height: AppSizes.lg.h),
          Expanded(
            child: Obx(() {
              final messages = controller.snapshot.value.messages;
              if (messages.isEmpty) {
                return const Center(
                  child: ReusableText.body(
                    text: AppStrings.memoryNoMessages,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return ListView.separated(
                itemCount: messages.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSizes.sm.h),
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message.role.toLowerCase() == 'user';

                  return Align(
                    alignment: isUser
                        ? AlignmentDirectional.centerStart
                        : AlignmentDirectional.centerEnd,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 620.w),
                      child: ReusableSurfaceCard(
                        padding: EdgeInsets.all(AppSizes.md.w),
                        color: isUser
                            ? AppColors.primary.withValues(alpha: 0.16)
                            : AppColors.surfaceAlt,
                        border: Border.all(
                          color: isUser
                              ? AppColors.primary.withValues(alpha: 0.45)
                              : AppColors.border,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ReusableStatusBadge(
                                  label: message.role,
                                  icon: isUser
                                      ? Icons.person_rounded
                                      : Icons.smart_toy_rounded,
                                  color: isUser
                                      ? AppColors.primary
                                      : AppColors.secondary,
                                ),
                                SizedBox(width: AppSizes.sm.w),
                                Expanded(
                                  child: ReusableText(
                                    text: controller.formatEpoch(
                                      message.createdAt,
                                    ),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizes.sm.h),
                            ReusableText.body(
                              text: controller.compactText(
                                message.content,
                                maxChars: 420,
                              ),
                              color: AppColors.textPrimary,
                            ),
                            if (message.modelProfileId != null) ...[
                              SizedBox(height: AppSizes.sm.h),
                              ReusableText(
                                text: message.modelProfileId!,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
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
