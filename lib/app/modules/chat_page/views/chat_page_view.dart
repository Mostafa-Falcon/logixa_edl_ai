import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:logixa_edl_ai/app/constants/app_sizes.dart';
import 'package:logixa_edl_ai/app/widgets/core_page.dart';

import '../controllers/chat_page_controller.dart';
import 'sections/chat_header_section.dart';
import 'sections/chat_input_section.dart';
import 'sections/chat_messages_section.dart';

class ChatPageView extends GetView<ChatPageController> {
  const ChatPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return CorePage(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.pageHorizontalPadding.w,
            vertical: AppSizes.pageVerticalPadding.h,
          ),
          child: Column(
            children: [
              const ChatHeaderSection(),
              SizedBox(height: AppSizes.lg.h),
              const Expanded(child: ChatMessagesSection()),
              SizedBox(height: AppSizes.md.h),
              const ChatInputSection(),
            ],
          ),
        ),
      ),
    );
  }
}
