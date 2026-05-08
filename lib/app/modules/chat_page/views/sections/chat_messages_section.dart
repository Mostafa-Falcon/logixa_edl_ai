import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_chat_bubble.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/chat_page_controller.dart';

class ChatMessagesSection extends GetView<ChatPageController> {
  const ChatMessagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      color: AppColors.editor,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const _ChatTranscriptToolbar(),
          Expanded(
            child: Obx(() {
              return ListView.separated(
                controller: controller.messagesScrollController,
                padding: EdgeInsets.all(AppSizes.xl.w),
                itemBuilder: (context, index) {
                  return ReusableChatBubble(
                    message: controller.messages[index],
                  );
                },
                separatorBuilder: (_, _) => SizedBox(height: AppSizes.md.h),
                itemCount: controller.messages.length,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ChatTranscriptToolbar extends GetView<ChatPageController> {
  const _ChatTranscriptToolbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.lg.w,
        vertical: AppSizes.sm.h,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Icon(Icons.article_outlined, size: 18.w, color: AppColors.textMuted),
          SizedBox(width: AppSizes.sm.w),
          const Expanded(
            child: ReusableText(
              text: AppStrings.chatConversationToolsTitle,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Obx(() {
            final canCopy = controller.hasCopyableConversation;

            return TextButton.icon(
              onPressed: canCopy
                  ? controller.copyConversationToClipboard
                  : null,
              icon: Icon(Icons.copy_rounded, size: 16.w),
              label: const ReusableText(
                text: AppStrings.chatCopyConversationButton,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            );
          }),
        ],
      ),
    );
  }
}
