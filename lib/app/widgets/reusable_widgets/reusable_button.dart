import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import 'reusable_text.dart';

enum ReusableButtonVariant { primary, secondary, ghost, danger }

class ReusableButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;
  final ReusableButtonVariant variant;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const ReusableButton({
    super.key,
    required this.title,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
    this.variant = ReusableButtonVariant.primary,
    this.height,
    this.padding,
  });

  @override
  State<ReusableButton> createState() => _ReusableButtonState();
}

class _ReusableButtonState extends State<ReusableButton> {
  bool _isHovered = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.normalAnimation),
          height: widget.height?.h ?? 42.h,
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.w),
          decoration: _decoration,
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
                  ),
                ),
                SizedBox(width: 10.w),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, color: _foregroundColor, size: 18.sp),
                SizedBox(width: 8.w),
              ],
              ReusableText(
                text: widget.title,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _foregroundColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    return widget.expanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  BoxDecoration get _decoration {
    switch (widget.variant) {
      case ReusableButtonVariant.primary:
        return BoxDecoration(
          gradient: _isEnabled ? AppColors.primaryGradient : null,
          color: _isEnabled ? null : AppColors.surfacePressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          boxShadow: _isHovered && _isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        );
      case ReusableButtonVariant.secondary:
        return BoxDecoration(
          color: _isHovered ? AppColors.surfaceHover : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          border: Border.all(color: AppColors.border),
        );
      case ReusableButtonVariant.ghost:
        return BoxDecoration(
          color: _isHovered ? AppColors.glassBackgroundStrong : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        );
      case ReusableButtonVariant.danger:
        return BoxDecoration(
          color: _isHovered ? AppColors.error : AppColors.errorSoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        );
    }
  }

  Color get _foregroundColor {
    if (!_isEnabled) return AppColors.textDisabled;

    switch (widget.variant) {
      case ReusableButtonVariant.primary:
        return AppColors.textOnPrimary;
      case ReusableButtonVariant.secondary:
      case ReusableButtonVariant.ghost:
        return AppColors.textPrimary;
      case ReusableButtonVariant.danger:
        return AppColors.textPrimary;
    }
  }
}
