import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../constants/app_strings.dart';
import 'reusable_text.dart';

class ReusableAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final IconData? icon;

  const ReusableAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    this.cancelLabel = AppStrings.cancel,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Container(
        width: 420.w,
        padding: EdgeInsets.all(AppSizes.xl.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: (isDestructive ? AppColors.error : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  ),
                  child: Icon(
                    icon ??
                        (isDestructive
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline_rounded),
                    color: isDestructive ? AppColors.error : AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: AppSizes.lg.w),
                Expanded(
                  child: ReusableText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.xl.h),
            Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: ReusableText(
                text: content,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            SizedBox(height: AppSizes.xxl.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel ?? () => Get.back(result: false),
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                    ),
                  ),
                  child: ReusableText(
                    text: cancelLabel,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(width: AppSizes.md.w),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onConfirm,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                        horizontal: 28.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: isDestructive
                            ? LinearGradient(
                                colors: [
                                  AppColors.error,
                                  AppColors.error.withValues(alpha: 0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                        boxShadow: [
                          BoxShadow(
                            color: (isDestructive
                                    ? AppColors.error
                                    : AppColors.primary)
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ReusableText(
                        text: confirmLabel,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
