import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../constants/app_sizes.dart';
import 'reusable_text.dart';

class ReusableWorkspaceBottomTab extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const ReusableWorkspaceBottomTab({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<ReusableWorkspaceBottomTab> createState() =>
      _ReusableWorkspaceBottomTabState();
}

class _ReusableWorkspaceBottomTabState extends State<ReusableWorkspaceBottomTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.fastAnimation),
          curve: Curves.easeOut,
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md.w),
          decoration: BoxDecoration(
            color: _backgroundColor,
            border: Border(
              top: BorderSide(
                color: widget.isActive ? AppColors.primaryHover : Colors.transparent,
                width: 2.h,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14.sp, color: _iconColor),
              SizedBox(width: 7.w),
              ReusableText(
                text: widget.label,
                fontFamily: AppFonts.english,
                fontSize: 11,
                fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
                color: _textColor,
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (widget.isActive) return AppColors.editorBackground;
    if (_isHovered) return AppColors.surfaceHover.withValues(alpha: 0.42);
    return Colors.transparent;
  }

  Color get _iconColor {
    if (widget.isActive) return AppColors.primaryHover;
    if (_isHovered) return AppColors.textPrimary;
    return AppColors.textMuted;
  }

  Color get _textColor {
    if (widget.isActive) return AppColors.textPrimary;
    if (_isHovered) return AppColors.textPrimary;
    return AppColors.textSecondary;
  }
}
