import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../constants/app_sizes.dart';
import 'reusable_text.dart';

class ReusableWorkspaceTreeTile extends StatefulWidget {
  final String label;
  final int depth;
  final IconData icon;
  final Color iconColor;
  final bool isDirectory;
  final bool isExpanded;
  final bool isActive;
  final VoidCallback onTap;

  const ReusableWorkspaceTreeTile({
    super.key,
    required this.label,
    required this.depth,
    required this.icon,
    required this.iconColor,
    required this.isDirectory,
    required this.isExpanded,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<ReusableWorkspaceTreeTile> createState() =>
      _ReusableWorkspaceTreeTileState();
}

class _ReusableWorkspaceTreeTileState extends State<ReusableWorkspaceTreeTile> {
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
          height: 28.h,
          padding: EdgeInsetsDirectional.only(
            start: (AppSizes.sm + (widget.depth * 16)).w,
            end: AppSizes.sm.w,
          ),
          decoration: BoxDecoration(
            color: _backgroundColor,
            border: BorderDirectional(
              start: BorderSide(
                color: widget.isActive ? AppColors.primaryHover : Colors.transparent,
                width: 2.w,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16.w,
                child: widget.isDirectory
                    ? AnimatedRotation(
                        turns: widget.isExpanded ? 0 : -0.25,
                        duration: const Duration(
                          milliseconds: AppSizes.fastAnimation,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textMuted,
                          size: 17.sp,
                        ),
                      )
                    : null,
              ),
              Icon(widget.icon, color: widget.iconColor, size: 17.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: ReusableText(
                  text: widget.label,
                  fontFamily: AppFonts.english,
                  fontSize: 12,
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    if (widget.isActive) return AppColors.primary.withValues(alpha: 0.18);
    if (_isHovered) return AppColors.surfaceHover.withValues(alpha: 0.55);
    return Colors.transparent;
  }
}
