import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../constants/app_sizes.dart';
import 'reusable_text.dart';

class ReusableEditorTab extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const ReusableEditorTab({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<ReusableEditorTab> createState() => _ReusableEditorTabState();
}

class _ReusableEditorTabState extends State<ReusableEditorTab> {
  bool _isHovered = false;
  bool _isCloseHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isCloseHovered = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.fastAnimation),
          curve: Curves.easeOut,
          constraints: BoxConstraints(minWidth: 128.w, maxWidth: 230.w),
          height: 39.h,
          padding: EdgeInsetsDirectional.only(
            start: AppSizes.md.w,
            end: AppSizes.xs.w,
          ),
          decoration: BoxDecoration(
            color: _backgroundColor,
            border: BorderDirectional(
              top: BorderSide(
                color: widget.isActive ? AppColors.primaryHover : Colors.transparent,
                width: 2.h,
              ),
              end: const BorderSide(
                color: AppColors.border,
                width: AppSizes.borderThin,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: _iconColor, size: 15.sp),
              SizedBox(width: 7.w),
              Flexible(
                child: ReusableText(
                  text: widget.title,
                  fontFamily: AppFonts.english,
                  fontSize: 12,
                  fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
                  color: widget.isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
              ),
              SizedBox(width: 8.w),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isCloseHovered = true),
                onExit: (_) => setState(() => _isCloseHovered = false),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onClose,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: AppSizes.fastAnimation),
                    width: 22.w,
                    height: 22.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isCloseHovered
                          ? AppColors.surfaceHover
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14.sp,
                      color: _isCloseHovered
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (widget.isActive) return AppColors.editorBackground;
    if (_isHovered) return AppColors.surfaceHover.withValues(alpha: 0.45);
    return AppColors.panel;
  }

  Color get _iconColor {
    if (widget.isActive) return AppColors.primaryHover;
    if (_isHovered) return AppColors.textPrimary;
    return AppColors.textMuted;
  }
}
