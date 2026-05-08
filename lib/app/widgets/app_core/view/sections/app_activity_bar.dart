import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';

class AppActivityBarItem {
  final String tooltip;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const AppActivityBarItem({
    required this.tooltip,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });
}

class AppActivityBar extends StatelessWidget {
  final List<AppActivityBarItem> topItems;
  final List<AppActivityBarItem> bottomItems;

  const AppActivityBar({
    super.key,
    required this.topItems,
    this.bottomItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.workspaceActivityBarWidth.w,
      decoration: const BoxDecoration(
        color: AppColors.terminal,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: AppSizes.sm.h),
          ...topItems.map(
            (item) => _AppActivityBarButton(item: item),
          ),
          const Spacer(),
          ...bottomItems.map(
            (item) => _AppActivityBarButton(item: item),
          ),
          SizedBox(height: AppSizes.sm.h),
        ],
      ),
    );
  }
}

class _AppActivityBarButton extends StatefulWidget {
  final AppActivityBarItem item;

  const _AppActivityBarButton({required this.item});

  @override
  State<_AppActivityBarButton> createState() => _AppActivityBarButtonState();
}

class _AppActivityBarButtonState extends State<_AppActivityBarButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.item.isActive;
    final iconColor = isActive
        ? AppColors.primaryHover
        : _isHovered
            ? AppColors.textPrimary
            : AppColors.textDisabled;

    final backgroundColor = isActive
        ? AppColors.primary.withValues(alpha: 0.14)
        : _isHovered
            ? AppColors.glassBackgroundStrong
            : Colors.transparent;

    return Tooltip(
      message: widget.item.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: widget.item.onTap == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapCancel: () => setState(() => _isPressed = false),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTap: widget.item.onTap,
          child: SizedBox(
            width: AppSizes.workspaceActivityBarWidth.w,
            height: 48.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositionedDirectional(
                  duration: const Duration(
                    milliseconds: AppSizes.fastAnimation,
                  ),
                  curve: Curves.easeOut,
                  start: 0,
                  width: isActive ? 3.w : 0,
                  height: 30.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryHover,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusPill.r,
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: AppSizes.fastAnimation,
                  ),
                  curve: Curves.easeOut,
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.26)
                          : Colors.transparent,
                      width: AppSizes.borderThin,
                    ),
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(
                    milliseconds: AppSizes.fastAnimation,
                  ),
                  curve: Curves.easeOut,
                  scale: _isPressed ? 0.92 : (_isHovered ? 1.08 : 1),
                  child: Icon(
                    widget.item.icon,
                    color: iconColor,
                    size: AppSizes.iconMd.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
