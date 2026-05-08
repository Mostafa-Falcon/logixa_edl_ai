import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../data/models/new_workspace_request.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';

class NewWorkspaceDialog extends StatefulWidget {
  final String defaultParentPath;

  const NewWorkspaceDialog({
    super.key,
    required this.defaultParentPath,
  });

  @override
  State<NewWorkspaceDialog> createState() => _NewWorkspaceDialogState();
}

class _NewWorkspaceDialogState extends State<NewWorkspaceDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AppStrings.defaultWorkspaceName);
    _pathController = TextEditingController(text: widget.defaultParentPath);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  String get _workspaceName => _nameController.text.trim();
  String get _parentPath => _pathController.text.trim();

  String get _safePreviewName {
    final safeName = _workspaceName
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\u0600-\u06FF ]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    return safeName.isEmpty ? AppStrings.workspaceNamePlaceholder : safeName;
  }

  String get _previewPath {
    if (_parentPath.isEmpty) return AppStrings.chooseWorkspaceParentFolder;
    return path.join(_parentPath, _safePreviewName);
  }

  Future<void> _pickParentFolder() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: AppStrings.chooseWorkspaceParentFolder,
    );

    if (selectedPath == null || selectedPath.trim().isEmpty) return;
    setState(() => _pathController.text = selectedPath);
  }

  void _submit() {
    if (_workspaceName.isEmpty || _parentPath.isEmpty) return;

    Get.back<NewWorkspaceRequest>(
      result: NewWorkspaceRequest(
        name: _workspaceName,
        parentPath: _parentPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 620.w),
        child: ReusableSurfaceCard(
          padding: EdgeInsets.all(AppSizes.xxl.w),
          gradient: AppColors.panelGradient,
          border: Border.all(color: AppColors.borderStrong),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_box_rounded,
                      color: AppColors.textOnPrimary,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: AppSizes.lg.w),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReusableText(
                          text: AppStrings.createWorkspaceTitle,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                        ReusableText.body(
                          text: AppStrings.createWorkspaceDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: AppStrings.cancel,
                    onPressed: () => Get.back<void>(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.xxl.h),
              _DialogInputField(
                label: AppStrings.workspaceNameLabel,
                hint: AppStrings.workspaceNameHint,
                controller: _nameController,
                icon: Icons.drive_file_rename_outline_rounded,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: AppSizes.lg.h),
              _DialogInputField(
                label: AppStrings.workspaceLocationLabel,
                hint: AppStrings.workspaceLocationHint,
                controller: _pathController,
                icon: Icons.folder_rounded,
                readOnly: true,
                suffix: ReusableButton(
                  title: AppStrings.browse,
                  icon: Icons.folder_open_rounded,
                  variant: ReusableButtonVariant.secondary,
                  height: 36,
                  onPressed: _pickParentFolder,
                ),
              ),
              SizedBox(height: AppSizes.lg.h),
              AnimatedContainer(
                duration: const Duration(milliseconds: AppSizes.fastAnimation),
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.lg.w),
                decoration: BoxDecoration(
                  color: AppColors.glassBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder_special_rounded, color: AppColors.primaryHover, size: 18.sp),
                    SizedBox(width: AppSizes.md.w),
                    Expanded(
                      child: ReusableText(
                        text: _previewPath,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.xxl.h),
              Row(
                children: [
                  Expanded(
                    child: ReusableButton(
                      title: AppStrings.cancel,
                      variant: ReusableButtonVariant.ghost,
                      expanded: true,
                      onPressed: () => Get.back<void>(),
                    ),
                  ),
                  SizedBox(width: AppSizes.md.w),
                  Expanded(
                    child: ReusableButton(
                      title: AppStrings.createWorkspaceButton,
                      icon: Icons.check_rounded,
                      expanded: true,
                      onPressed: _workspaceName.isEmpty || _parentPath.isEmpty ? null : _submit,
                    ),
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

class _DialogInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const _DialogInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.readOnly = false,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: AppSizes.sm.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          cursorColor: AppColors.primaryHover,
          textDirection: readOnly ? TextDirection.ltr : TextDirection.rtl,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 12.sp),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18.sp),
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: EdgeInsetsDirectional.only(end: AppSizes.sm.w),
                    child: Center(widthFactor: 1, child: suffix),
                  ),
            filled: true,
            fillColor: AppColors.surface.withValues(alpha: 0.72),
            contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.lg.w, vertical: AppSizes.md.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              borderSide: const BorderSide(color: AppColors.primaryHover),
            ),
          ),
        ),
      ],
    );
  }
}
