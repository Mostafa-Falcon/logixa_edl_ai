import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';

class ReusableSidebarIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const ReusableSidebarIcon({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<ReusableSidebarIcon> createState() => _ReusableSidebarIconState();
}

class _ReusableSidebarIconState extends State<ReusableSidebarIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? AppColors.primaryHover : AppColors.textMuted;

    return Tooltip(
      message: widget.label,
      waitDuration: const Duration(milliseconds: 350),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppSizes.fastAnimation),
            margin: EdgeInsets.symmetric(horizontal: AppSizes.md.w, vertical: AppSizes.sm.h),
            width: 56.w,
            height: 52.h,
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
              border: Border.all(color: _borderColor, width: AppSizes.borderThin),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isActive)
                  PositionedDirectional(
                    end: 5.w,
                    child: Container(
                      width: 4.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryHover,
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
                      ),
                    ),
                  ),
                Icon(widget.icon, color: color, size: AppSizes.iconMd.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (widget.isActive) return AppColors.primary.withValues(alpha: 0.12);
    if (_isHovered) return AppColors.glassBackgroundStrong;
    return Colors.transparent;
  }

  Color get _borderColor {
    if (widget.isActive) return AppColors.primary.withValues(alpha: 0.22);
    if (_isHovered) return AppColors.border;
    return Colors.transparent;
  }
}
