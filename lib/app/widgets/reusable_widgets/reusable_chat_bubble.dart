import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../data/models/chat_message_model.dart';
import 'reusable_text.dart';

class ReusableChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ReusableChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart;
    final bubbleColor = _bubbleColor;
    final borderColor = _borderColor;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 820.w),
        child: Container(
          padding: EdgeInsets.all(AppSizes.lg.w),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusLg.r),
              topRight: Radius.circular(AppSizes.radiusLg.r),
              bottomLeft: Radius.circular(
                message.isUser ? AppSizes.radiusLg.r : AppSizes.radiusSm.r,
              ),
              bottomRight: Radius.circular(
                message.isUser ? AppSizes.radiusSm.r : AppSizes.radiusLg.r,
              ),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSizes.sm.w,
                runSpacing: AppSizes.xs.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ReusableText(
                    text: message.roleLabel,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _titleColor,
                  ),
                  if (message.runtimeStage != null)
                    ReusableText(
                      text: '• ${message.runtimeStage}',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  if (message.modelProfileId != null)
                    ReusableText(
                      text: '• ${message.modelProfileId}',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
              SizedBox(height: AppSizes.sm.h),
              ReusableText(
                text: message.content,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.65,
                selectable: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _bubbleColor {
    if (message.isUser) return AppColors.userBubble;
    if (message.isSystem) return AppColors.systemBubble;
    return AppColors.assistantBubble;
  }

  Color get _borderColor {
    if (message.isUser) return AppColors.userBubbleBorder;
    if (message.isSystem) return AppColors.systemBubbleBorder;
    return AppColors.assistantBubbleBorder;
  }

  Color get _titleColor {
    if (message.isUser) return AppColors.primaryHover;
    if (message.isSystem) return AppColors.accentSoft;
    return AppColors.secondary;
  }
}
