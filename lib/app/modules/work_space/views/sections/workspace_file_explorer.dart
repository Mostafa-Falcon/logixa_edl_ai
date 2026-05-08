import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:super_context_menu/super_context_menu.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_fonts.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../data/models/workspace_file_item_model.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../../../widgets/reusable_widgets/reusable_workspace_tree_tile.dart';
import '../../controllers/work_space_controller.dart';

class WorkspaceFileExplorer extends StatefulWidget {
  const WorkspaceFileExplorer({super.key});

  @override
  State<WorkspaceFileExplorer> createState() => _WorkspaceFileExplorerState();
}

class _WorkspaceFileExplorerState extends State<WorkspaceFileExplorer> {
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
      width: AppSizes.workspaceSidePanelWidth.w,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: Column(
        children: [
          const _ExplorerTopHeader(),
          const _ExplorerRootHeader(),
          Expanded(
            child: Obx(() {
              final isLoading = controller.isLoading.value;
              final visibleFiles = controller.visibleWorkspaceFiles;

              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              if (visibleFiles.isEmpty) return const _WorkspaceEmptyState();

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: _scrollController,
                  primary: false,
                  padding: EdgeInsets.only(
                    top: AppSizes.xs.h,
                    bottom: AppSizes.lg.h,
                  ),
                  itemCount: visibleFiles.length,
                  itemBuilder: (context, index) {
                    final item = visibleFiles[index];
                    return _WorkspaceTreeTile(item: item);
                  },
                ),
              );
            }),
          ),
          const _ExplorerFooter(),
        ],
      ),
    );
  }
}

class _ExplorerTopHeader extends GetView<WorkSpaceController> {
  const _ExplorerTopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsetsDirectional.only(
        start: AppSizes.lg.w,
        end: AppSizes.sm.w,
      ),
      child: Row(
        children: [
          const Expanded(
            child: ReusableText(
              text: AppStrings.workspaceExplorerPanelTitle,
              fontFamily: AppFonts.english,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _ExplorerIconButton(
            tooltip: AppStrings.refreshWorkspace,
            icon: Icons.refresh_rounded,
            onTap: controller.refreshWorkspace,
          ),
          _ExplorerIconButton(
            tooltip: AppStrings.expandAllFolders,
            icon: Icons.unfold_more_rounded,
            onTap: controller.expandAllDirectories,
          ),
          _ExplorerIconButton(
            tooltip: AppStrings.collapseAllFolders,
            icon: Icons.unfold_less_rounded,
            onTap: controller.collapseAllDirectories,
          ),
        ],
      ),
    );
  }
}

class _ExplorerRootHeader extends GetView<WorkSpaceController> {
  const _ExplorerRootHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final workspace = controller.activeWorkspace.value;
      final title = workspace?.name ?? AppStrings.noActiveWorkspace;
      final subtitle = workspace?.path ?? AppStrings.openProjectFromHome;

      return Container(
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSizes.sm.w,
          AppSizes.sm.h,
          AppSizes.sm.w,
          AppSizes.sm.h,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppSizes.borderThin,
            ),
            bottom: BorderSide(
              color: AppColors.border,
              width: AppSizes.borderThin,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 18.sp,
            ),
            SizedBox(width: AppSizes.xs.w),
            Icon(Icons.folder_rounded, color: AppColors.warning, size: 17.sp),
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
                    textDirection: TextDirection.ltr,
                  ),
                  SizedBox(height: 2.h),
                  ReusableText(
                    text: subtitle,
                    fontFamily: AppFonts.mono,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ExplorerIconButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _ExplorerIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ExplorerIconButton> createState() => _ExplorerIconButtonState();
}

class _ExplorerIconButtonState extends State<_ExplorerIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 450),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppSizes.fastAnimation),
            width: 27.w,
            height: 27.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.surfaceHover.withValues(alpha: 0.65)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
            ),
            child: Icon(widget.icon, color: AppColors.textMuted, size: 16.sp),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceTreeTile extends GetView<WorkSpaceController> {
  final WorkspaceFileItemModel item;

  const _WorkspaceTreeTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.isDirectoryExpanded(item);
      final isOpened = controller.isFileOpened(item);

      return ContextMenuWidget(
        menuProvider: (_) => Menu(
          children: [
            MenuAction(
              title: AppStrings.workspaceContextOpen,
              callback: () {
                unawaited(controller.openWorkspaceItemFromContextMenu(item));
              },
            ),
            MenuAction(
              title: AppStrings.workspaceContextCopyPath,
              callback: () {
                unawaited(controller.copyWorkspaceItemPath(item));
              },
            ),
            MenuAction(
              title: AppStrings.workspaceContextRevealPath,
              callback: () {
                unawaited(controller.revealWorkspaceItemPath(item));
              },
            ),
            MenuSeparator(),
            MenuAction(
              title: AppStrings.workspaceContextRefresh,
              callback: () {
                unawaited(controller.refreshWorkspace());
              },
            ),
          ],
        ),
        child: ReusableWorkspaceTreeTile(
          label: item.name,
          depth: item.depth,
          icon: _resolveIcon(item, isExpanded),
          iconColor: _resolveIconColor(item),
          isDirectory: item.isDirectory,
          isExpanded: isExpanded,
          isActive: isOpened,
          onTap: () {
            if (item.isDirectory) {
              controller.toggleDirectory(item);
            } else {
              controller.openFile(item);
            }
          },
        ),
      );
    });
  }

  IconData _resolveIcon(WorkspaceFileItemModel item, bool isExpanded) {
    if (item.isDirectory) {
      final lower = item.name.toLowerCase();
      if (lower == 'lib') return Icons.folder_special_rounded;
      if (lower == 'app') return Icons.widgets_rounded;
      if (lower == 'data') return Icons.storage_rounded;
      if (lower == 'controllers') return Icons.settings_applications_rounded;
      if (lower == 'views') return Icons.web_asset_rounded;
      if (lower == 'sections') return Icons.view_quilt_rounded;
      if (lower == 'routes') return Icons.alt_route_rounded;
      if (lower == 'widgets') return Icons.extension_rounded;
      if (lower == 'models') return Icons.account_tree_rounded;
      if (lower == 'services') return Icons.miscellaneous_services_rounded;
      if (lower == 'constants') return Icons.tune_rounded;
      if (lower == 'theme') return Icons.palette_rounded;
      if (lower == 'assets') return Icons.perm_media_rounded;
      return isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded;
    }

    switch (path.extension(item.name).toLowerCase()) {
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
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.webp':
        return Icons.image_rounded;
      case '.lock':
        return Icons.lock_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color _resolveIconColor(WorkspaceFileItemModel item) {
    if (item.isDirectory) {
      final lower = item.name.toLowerCase();
      if (lower == 'lib') return AppColors.success;
      if (lower == 'app') return AppColors.error;
      if (lower == 'data') return AppColors.warning;
      if (lower == 'modules') return AppColors.info;
      if (lower == 'controllers') return AppColors.warning;
      if (lower == 'views') return AppColors.error;
      if (lower == 'routes') return AppColors.success;
      if (lower == 'widgets') return AppColors.success;
      return AppColors.textMuted;
    }

    switch (path.extension(item.name).toLowerCase()) {
      case '.dart':
        return AppColors.info;
      case '.rs':
        return AppColors.warning;
      case '.json':
      case '.yaml':
      case '.yml':
      case '.toml':
        return AppColors.codeNumber;
      case '.md':
      case '.txt':
        return AppColors.textMuted;
      default:
        return AppColors.textDisabled;
    }
  }
}

class _ExplorerFooter extends GetView<WorkSpaceController> {
  const _ExplorerFooter();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.workspaceFiles.length;
      final limited = controller.isTreePossiblyLimited;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.md.w,
          vertical: AppSizes.sm.h,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppSizes.borderThin,
            ),
          ),
        ),
        child: ReusableText(
          text: limited
              ? '$count item(s) • tree limited for performance'
              : '$count item(s)',
          fontFamily: AppFonts.english,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: limited ? AppColors.warning : AppColors.textMuted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
        ),
      );
    });
  }
}

class _WorkspaceEmptyState extends StatelessWidget {
  const _WorkspaceEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.xl.w),
        child: const ReusableText.body(
          text: AppStrings.workspaceFilesEmpty,
          textAlign: TextAlign.center,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
