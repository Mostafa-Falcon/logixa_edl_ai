import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../controller/top_bar_controller.dart';

class TopBarWindowControls extends GetView<TopBarController> {
  const TopBarWindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Material(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            _WindowControlButton(
              tooltip: AppStrings.minimizeTooltip,
              icon: Icons.remove_rounded,
              onPressed: () => controller.minimizeWindow(),
            ),
            _WindowControlButton(
              tooltip: controller.isMaximized.value
                  ? AppStrings.restoreTooltip
                  : AppStrings.maximizeTooltip,
              icon: controller.isMaximized.value
                  ? Icons.filter_none_rounded
                  : Icons.crop_square_rounded,
              onPressed: () => controller.toggleMaximize(),
            ),
            _WindowControlButton(
              tooltip: AppStrings.closeTooltip,
              icon: Icons.close_rounded,
              hoverColor: AppColors.closeButton.withValues(alpha: 0.86),
              hoverIconColor: Colors.white,
              onPressed: () => controller.closeWindow(),
            ),
          ],
        )));
  }
}

class _WindowControlButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? hoverColor;
  final Color? hoverIconColor;

  const _WindowControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.hoverColor,
    this.hoverIconColor,
  });

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 450),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () {
            debugPrint('Button Pressed: ${widget.tooltip}');
            widget.onPressed();
          },
          onHighlightChanged: (hovered) => setState(() => _isPressed = hovered),
          child: AnimatedScale(
            scale: _isPressed ? 0.94 : 1,
            duration: const Duration(milliseconds: AppSizes.fastAnimation),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: AppSizes.fastAnimation),
              curve: Curves.easeOut,
              width: 48.w,
              height: AppSizes.topBarHeight.h,
              color: _isHovered
                  ? widget.hoverColor ?? Colors.white.withValues(alpha: 0.055)
                  : Colors.transparent,
              child: Icon(
                widget.icon,
                size: AppSizes.iconSm.sp,
                color: _isHovered
                    ? widget.hoverIconColor ?? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
