import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../controller/top_bar_controller.dart';
import 'sections/top_bar_actions_section.dart';
import 'sections/top_bar_hint_section.dart';
import 'sections/top_bar_title_section.dart';
import 'sections/top_bar_window_controls.dart';

class TopBar extends GetView<TopBarController> implements PreferredSizeWidget {
  const TopBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(AppSizes.topBarHeight.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.topBarHeight.h,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.86),
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorder,
            width: AppSizes.borderThin,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Row(
            children: [
              const Expanded(
                child: DragToMoveArea(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 16.0),
                    child: Row(
                      children: [
                        TopBarTitleSection(),
                        Spacer(),
                        TopBarHintSection(),
                      ],
                    ),
                  ),
                ),
              ),
              const TopBarActionsSection(),
              SizedBox(width: AppSizes.sm.w),
              const TopBarWindowControls(),
            ],
          ),
        ),
      ),
    );
  }
}
