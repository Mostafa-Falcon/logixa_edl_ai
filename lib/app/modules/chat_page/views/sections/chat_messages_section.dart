import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../widgets/reusable_widgets/reusable_chat_bubble.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../controllers/chat_page_controller.dart';

class ChatMessagesSection extends GetView<ChatPageController> {
  const ChatMessagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ReusableSurfaceCard(
      color: AppColors.editor,
      padding: EdgeInsets.zero,
      child: Obx(() {
        return ListView.separated(
          controller: controller.messagesScrollController,
          padding: EdgeInsets.all(AppSizes.xl.w),
          itemBuilder: (context, index) {
            return ReusableChatBubble(message: controller.messages[index]);
          },
          separatorBuilder: (_, _) => SizedBox(height: AppSizes.md.h),
          itemCount: controller.messages.length,
        );
      }),
    );
  }
}
