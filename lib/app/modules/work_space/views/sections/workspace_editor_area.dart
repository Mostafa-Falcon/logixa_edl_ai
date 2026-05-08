import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_fonts.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../data/models/opened_file_model.dart';
import '../../../../widgets/reusable_widgets/reusable_editor_tab.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/work_space_controller.dart';

class WorkspaceEditorArea extends GetView<WorkSpaceController> {
  const WorkspaceEditorArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _WorkspaceEditorTabsBar(),
        const _WorkspaceEditorHeader(),
        Expanded(
          child: Obx(() {
            if (controller.errorMessage.value.isNotEmpty) {
              return _WorkspaceMessageState(
                icon: Icons.warning_amber_rounded,
                title: AppStrings.workspaceErrorTitle,
                message: controller.errorMessage.value,
                color: AppColors.warning,
              );
            }

            if (!controller.hasWorkspace) {
              return const _WorkspaceMessageState(
                icon: Icons.folder_open_rounded,
                title: AppStrings.noActiveWorkspace,
                message: AppStrings.openProjectFromHome,
                color: AppColors.info,
              );
            }

            if (!controller.hasOpenedFile) {
              return const _WorkspaceMessageState(
                icon: Icons.code_rounded,
                title: AppStrings.workspaceReadyTitle,
                message: AppStrings.workspaceReadyMessage,
                color: AppColors.primaryHover,
              );
            }

            return const _WorkspaceFilePreview();
          }),
        ),
      ],
    );
  }
}

class _WorkspaceEditorTabsBar extends StatefulWidget {
  const _WorkspaceEditorTabsBar();

  @override
  State<_WorkspaceEditorTabsBar> createState() =>
      _WorkspaceEditorTabsBarState();
}

class _WorkspaceEditorTabsBarState extends State<_WorkspaceEditorTabsBar> {
  final ScrollController _scrollController = ScrollController();
  final WorkSpaceController controller = Get.find<WorkSpaceController>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: Obx(() {
        final tabs = controller.openedFiles.toList(growable: false);
        final activePath = controller.openedFilePath.value;

        if (tabs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.xl.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ReusableText(
                text: AppStrings.workspaceNoOpenTabs,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                textDirection: TextDirection.ltr,
              ),
            ),
          );
        }

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: false,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            primary: false,
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              final tab = tabs[index];

              return ReusableEditorTab(
                title: tab.name,
                icon: _resolveFileIcon(tab),
                isActive: tab.path == activePath,
                onTap: () => controller.setActiveOpenedFile(tab.path),
                onClose: () => controller.closeOpenedFile(tab.path),
              );
            },
          ),
        );
      }),
    );
  }

  IconData _resolveFileIcon(OpenedFileModel file) {
    switch (path.extension(file.name).toLowerCase()) {
      case '.dart':
        return Icons.flutter_dash_rounded;
      case '.rs':
        return Icons.memory_rounded;
      case '.json':
      case '.yaml':
      case '.yml':
      case '.toml':
        return Icons.data_object_rounded;
      case '.md':
      case '.txt':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}

class _WorkspaceEditorHeader extends GetView<WorkSpaceController> {
  const _WorkspaceEditorHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.xl.w),
      decoration: const BoxDecoration(
        color: AppColors.editorBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: Obx(() {
        final fileName = controller.openedFileName.value;
        final filePath = controller.openedFileSubtitle;

        return Row(
          children: [
            Icon(
              fileName.isEmpty
                  ? Icons.dashboard_customize_rounded
                  : Icons.code_rounded,
              color: AppColors.primaryHover,
              size: AppSizes.iconSm.sp,
            ),
            SizedBox(width: AppSizes.sm.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (filePath.isNotEmpty) ...[
                    ReusableText(
                      text: filePath,
                      fontFamily: AppFonts.mono,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _WorkspaceFilePreview extends StatefulWidget {
  const _WorkspaceFilePreview();

  @override
  State<_WorkspaceFilePreview> createState() => _WorkspaceFilePreviewState();
}

class _WorkspaceFilePreviewState extends State<_WorkspaceFilePreview> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final WorkSpaceController controller = Get.find<WorkSpaceController>();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final content = controller.openedFileContent.value;

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.editorBackground,
        child: Scrollbar(
          controller: _verticalController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _verticalController,
            primary: false,
            padding: EdgeInsets.all(AppSizes.xl.w),
            child: Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              notificationPredicate: (notification) => notification.depth == 1,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                primary: false,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 900.w),
                    child: ReusableText(
                      text: content,
                      fontFamily: AppFonts.mono,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                      color: AppColors.textSecondary,
                      selectable: true,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _WorkspaceMessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _WorkspaceMessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 460.w,
        padding: EdgeInsets.all(AppSizes.xxl.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 38.sp),
            SizedBox(height: AppSizes.lg.h),
            ReusableText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.sm.h),
            ReusableText.body(
              text: message,
              textAlign: TextAlign.center,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
