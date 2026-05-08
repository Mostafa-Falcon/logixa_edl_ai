import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import '../../data/models/model_profile_model.dart';
import 'reusable_button.dart';
import 'reusable_status_badge.dart';
import 'reusable_text.dart';

class ReusableModelProfileCard extends StatefulWidget {
  final ModelProfileModel profile;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const ReusableModelProfileCard({
    super.key,
    required this.profile,
    required this.isActive,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  State<ReusableModelProfileCard> createState() => _ReusableModelProfileCardState();
}

class _ReusableModelProfileCardState extends State<ReusableModelProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isActive
        ? AppColors.primary.withValues(alpha: 0.45)
        : _isHovered
            ? AppColors.glassBorder
            : AppColors.border;

    final backgroundColor = widget.isActive
        ? AppColors.primary.withValues(alpha: 0.10)
        : _isHovered
            ? AppColors.surfaceHover.withValues(alpha: 0.68)
            : AppColors.card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.normalAnimation),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(AppSizes.lg.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      gradient: widget.isActive ? AppColors.primaryGradient : null,
                      color: widget.isActive ? null : AppColors.editorBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Icon(
                      Icons.memory_rounded,
                      color: widget.isActive ? AppColors.textOnPrimary : AppColors.textMuted,
                      size: AppSizes.iconSm.sp,
                    ),
                  ),
                  SizedBox(width: AppSizes.md.w),
                  Expanded(
                    child: ReusableText(
                      text: widget.profile.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.isActive)
                    const ReusableStatusBadge(
                      label: AppStrings.activeProfileBadge,
                      color: AppColors.runtimeRunning,
                    ),
                ],
              ),
              SizedBox(height: AppSizes.md.h),
              ReusableText.body(
                text: widget.profile.modelPath.isEmpty ? AppStrings.noModelFileSelected : widget.profile.modelPath,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSizes.md.h),
              Wrap(
                spacing: AppSizes.sm.w,
                runSpacing: AppSizes.sm.h,
                children: [
                  _ProfileChip(label: 'CTX ${widget.profile.contextSize}'),
                  _ProfileChip(label: 'TH ${widget.profile.threads}'),
                  _ProfileChip(label: 'TOK ${widget.profile.maxTokens}'),
                  _ProfileChip(label: 'TEMP ${widget.profile.temperature}'),
                ],
              ),
              SizedBox(height: AppSizes.lg.h),
              Row(
                children: [
                  Expanded(
                    child: ReusableButton(
                      title: widget.isActive ? AppStrings.editProfileButton : AppStrings.setActiveProfileButton,
                      icon: widget.isActive ? Icons.edit_rounded : Icons.check_circle_rounded,
                      variant: widget.isActive ? ReusableButtonVariant.secondary : ReusableButtonVariant.primary,
                      onPressed: widget.onSelect,
                      expanded: true,
                    ),
                  ),
                  SizedBox(width: AppSizes.sm.w),
                  ReusableButton(
                    title: AppStrings.deleteProfileButton,
                    icon: Icons.delete_outline_rounded,
                    variant: ReusableButtonVariant.ghost,
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;

  const _ProfileChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.sm.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.editorBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
        border: Border.all(color: AppColors.border),
      ),
      child: ReusableText(
        text: label,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.textMuted,
      ),
    );
  }
}
