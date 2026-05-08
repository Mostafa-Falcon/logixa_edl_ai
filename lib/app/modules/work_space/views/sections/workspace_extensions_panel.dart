import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_fonts.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';

class WorkspaceExtensionsPanel extends StatelessWidget {
  const WorkspaceExtensionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.workspaceSidePanelWidth.w,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(color: AppColors.border, width: AppSizes.borderThin),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ExtensionsHeader(),
          const _ExtensionsSearchBox(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: AppSizes.sm.h),
              children: const [
                _ExtensionsGroupTitle(title: AppStrings.installedExtensions),
                _ExtensionItem(
                  icon: Icons.code_rounded,
                  title: 'Dart Tools',
                  subtitle: 'Dart code support, snippets, and analysis hooks.',
                  status: AppStrings.extensionInstalled,
                  installed: true,
                ),
                _ExtensionItem(
                  icon: Icons.terminal_rounded,
                  title: 'Rust Engine Tools',
                  subtitle: 'Controls and logs for the local Rust engine.',
                  status: AppStrings.extensionInstalled,
                  installed: true,
                ),
                _ExtensionsGroupTitle(title: AppStrings.recommendedExtensions),
                _ExtensionItem(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Expert Pack',
                  subtitle: 'Future expert templates for DEV, BIZ, PLAN, and LEX.',
                  status: AppStrings.extensionInstall,
                ),
                _ExtensionItem(
                  icon: Icons.memory_rounded,
                  title: 'Model Runtime Kit',
                  subtitle: 'Future controls for local model profiles and lifecycle.',
                  status: AppStrings.extensionInstall,
                ),
                _ExtensionItem(
                  icon: Icons.dataset_rounded,
                  title: 'Dataset Builder',
                  subtitle: 'Future import, cleaning, and training data preparation.',
                  status: AppStrings.extensionInstall,
                ),
              ],
            ),
          ),
          const _ExtensionsFooterNote(),
        ],
      ),
    );
  }
}

class _ExtensionsHeader extends StatelessWidget {
  const _ExtensionsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsetsDirectional.only(
        start: AppSizes.lg.w,
        end: AppSizes.sm.w,
      ),
      child: const Align(
        alignment: AlignmentDirectional.centerStart,
        child: ReusableText(
          text: AppStrings.workspaceExtensionsPanelTitle,
          fontFamily: AppFonts.english,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ExtensionsSearchBox extends StatelessWidget {
  const _ExtensionsSearchBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.md.w),
      child: Container(
        height: 34.h,
        padding: EdgeInsets.symmetric(horizontal: AppSizes.sm.w),
        decoration: BoxDecoration(
          color: AppColors.editorBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 17.sp, color: AppColors.textMuted),
            SizedBox(width: AppSizes.sm.w),
            const Expanded(
              child: ReusableText(
                text: AppStrings.workspaceExtensionsSearchHint,
                fontFamily: AppFonts.english,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDisabled,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.filter_list_rounded, size: 16.sp, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ExtensionsGroupTitle extends StatelessWidget {
  final String title;

  const _ExtensionsGroupTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSizes.lg.w,
        end: AppSizes.md.w,
        top: AppSizes.lg.h,
        bottom: AppSizes.sm.h,
      ),
      child: ReusableText(
        text: title,
        fontFamily: AppFonts.english,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _ExtensionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final bool installed;

  const _ExtensionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    this.installed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.sm.w, vertical: 2.h),
      padding: EdgeInsets.all(AppSizes.sm.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: installed
                  ? AppColors.primary.withValues(alpha: 0.16)
                  : AppColors.surfaceHover.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              color: installed ? AppColors.primaryHover : AppColors.textMuted,
              size: 19.sp,
            ),
          ),
          SizedBox(width: AppSizes.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReusableText(
                  text: title,
                  fontFamily: AppFonts.english,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                ReusableText(
                  text: subtitle,
                  fontFamily: AppFonts.english,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizes.sm.h),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: installed
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
                      border: Border.all(
                        color: installed
                            ? AppColors.success.withValues(alpha: 0.28)
                            : AppColors.primary.withValues(alpha: 0.34),
                      ),
                    ),
                    child: ReusableText(
                      text: status,
                      fontFamily: AppFonts.english,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: installed ? AppColors.success : AppColors.primaryHover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtensionsFooterNote extends StatelessWidget {
  const _ExtensionsFooterNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md.w),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: AppSizes.borderThin),
        ),
      ),
      child: const ReusableText(
        text: AppStrings.workspaceExtensionsHint,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textMuted,
      ),
    );
  }
}
