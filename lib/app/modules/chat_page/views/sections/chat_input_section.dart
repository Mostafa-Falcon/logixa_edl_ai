import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../controllers/chat_page_controller.dart';

class ChatInputSection extends GetView<ChatPageController> {
  const ChatInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      color: AppColors.panel,
      padding: EdgeInsets.all(AppSizes.md.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller.inputController,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.send,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                height: 1.55,
              ),
              decoration: InputDecoration(
                hintText: AppStrings.chatInputHint,
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.sp,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSizes.lg.w,
                  vertical: AppSizes.md.h,
                ),
              ),
              onSubmitted: (_) => controller.sendMessage(),
              inputFormatters: [LengthLimitingTextInputFormatter(12000)],
            ),
          ),
          SizedBox(width: AppSizes.md.w),
          Obx(() {
            if (controller.isStreaming.value) {
              return ReusableButton(
                title: AppStrings.chatStopGenerationButton,
                icon: Icons.stop_rounded,
                onPressed: controller.stopGeneration,
                height: 52,
              );
            }

            return ReusableButton(
              title: AppStrings.chatSendButton,
              icon: Icons.send_rounded,
              isLoading: controller.isSending.value,
              onPressed: controller.isSending.value
                  ? null
                  : controller.sendMessage,
              height: 52,
            );
          }),
        ],
      ),
    );
  }
}
