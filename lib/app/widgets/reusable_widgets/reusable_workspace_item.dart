import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logixa_edl_ai/app/constants/app_strings.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../data/models/workspace_model.dart';
import 'reusable_text.dart';

class ReusableWorkspaceItem extends StatefulWidget {
  final WorkspaceModel workspace;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ReusableWorkspaceItem({
    super.key,
    required this.workspace,
    this.onTap,
    this.onDelete,
  });

  @override
  State<ReusableWorkspaceItem> createState() => _ReusableWorkspaceItemState();
}

class _ReusableWorkspaceItemState extends State<ReusableWorkspaceItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.fastAnimation),
          margin: EdgeInsets.only(bottom: AppSizes.md.h),
          padding: EdgeInsets.all(AppSizes.lg.w),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.surfaceHover : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
            border: Border.all(
              color: _isHovered ? AppColors.borderStrong : AppColors.border,
              width: AppSizes.borderThin,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                ),
                child: Icon(
                  widget.workspace.icon,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSizes.lg.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReusableText(
                      text: widget.workspace.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    ReusableText(
                      text: widget.workspace.path,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    widget.onDelete?.call();
                  }
                },
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  side: const BorderSide(color: AppColors.border, width: 1),
                ),
                color: AppColors.surface,
                elevation: 4,
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        const ReusableText(
                          text: AppStrings.deleteWorkspace,
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textMuted,
                  size: 18.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
