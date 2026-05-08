import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../data/models/quick_action_model.dart';
import 'reusable_text.dart';

class ReusableActionCard extends StatefulWidget {
  final QuickActionModel action;
  final VoidCallback? onTap;

  const ReusableActionCard({
    super.key,
    required this.action,
    this.onTap,
  });

  @override
  State<ReusableActionCard> createState() => _ReusableActionCardState();
}

class _ReusableActionCardState extends State<ReusableActionCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: AppSizes.fastAnimation),
          curve: Curves.easeOut,
          scale: _isPressed ? 0.985 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppSizes.normalAnimation),
            curve: Curves.easeOut,
            height: 132.h,
            padding: EdgeInsets.all(AppSizes.xl.w),
            transform: Matrix4.translationValues(0.0, _isHovered ? -3.0 : 0.0, 0.0),
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.surfaceHover : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
              border: Border.all(
                color: _isHovered ? AppColors.borderStrong : AppColors.border,
                width: AppSizes.borderThin,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: _isHovered ? 0.52 : 0.28),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                PositionedDirectional(
                  end: -20.w,
                  bottom: -28.h,
                  child: Icon(
                    widget.action.icon,
                    color: AppColors.textPrimary.withValues(alpha: 0.035),
                    size: 106.sp,
                  ),
                ),
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: AppSizes.fastAnimation),
                    width: _isHovered ? 4.w : 3.w,
                    decoration: BoxDecoration(
                      gradient: widget.action.gradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: AppSizes.lg.w),
                  child: Row(
                    children: [
                      Container(
                        width: 46.w,
                        height: 46.w,
                        decoration: BoxDecoration(
                          gradient: widget.action.gradient,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.20),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.action.icon,
                          color: AppColors.textOnPrimary,
                          size: 23.sp,
                        ),
                      ),
                      SizedBox(width: AppSizes.lg.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ReusableText(
                              text: widget.action.title,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppSizes.sm.h),
                            ReusableText(
                              text: widget.action.subtitle,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
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
