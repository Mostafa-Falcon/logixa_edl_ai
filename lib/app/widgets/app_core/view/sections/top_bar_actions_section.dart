import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routes/app_pages.dart';
import '../../controller/top_bar_controller.dart';

class TopBarActionsSection extends GetView<TopBarController> {
  const TopBarActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopBarActionButton(
            tooltip: AppStrings.searchTooltip,
            icon: Icons.search_rounded,
            onPressed: () {},
          ),
          _TopBarActionButton(
            tooltip: AppStrings.commandsTooltip,
            icon: Icons.bolt_rounded,
            onPressed: () {},
          ),
          Obx(
            () => _TopBarActionButton(
              tooltip: controller.isLocalModelEnabled.value
                  ? AppStrings.disableLocalModelTooltip
                  : AppStrings.enableLocalModelTooltip,
              icon: controller.isLocalModelEnabled.value
                  ? Icons.memory_rounded
                  : Icons.memory_outlined,
              active: controller.isLocalModelEnabled.value,
              onPressed: controller.toggleLocalModelMode,
            ),
          ),
          _TopBarActionButton(
            tooltip: AppStrings.settingsTooltip,
            icon: Icons.tune_rounded,
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
    );
  }
}

class _TopBarActionButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;

  const _TopBarActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  @override
  State<_TopBarActionButton> createState() => _TopBarActionButtonState();
}

class _TopBarActionButtonState extends State<_TopBarActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.active
        ? AppColors.primary.withValues(alpha: 0.20)
        : _isHovered
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.transparent;

    final borderColor = widget.active
        ? AppColors.primary.withValues(alpha: 0.45)
        : _isHovered
        ? AppColors.glassBorder
        : Colors.transparent;

    final iconColor = widget.active
        ? AppColors.primaryHover
        : _isHovered
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 450),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : 1,
            duration: const Duration(milliseconds: AppSizes.fastAnimation),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: AppSizes.fastAnimation),
              curve: Curves.easeOut,
              width: 38.w,
              height: 34.h,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                widget.icon,
                size: AppSizes.iconSm.sp,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
