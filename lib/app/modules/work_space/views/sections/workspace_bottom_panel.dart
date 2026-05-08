import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_fonts.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../../../widgets/reusable_widgets/reusable_workspace_bottom_tab.dart';
import '../../controllers/work_space_controller.dart';

class WorkspaceBottomPanel extends GetView<WorkSpaceController> {
  const WorkspaceBottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVisible = controller.isBottomPanelVisible.value;
      final activePanel = controller.activeBottomPanel.value;
      final logs = controller.workspaceLogs.toList(growable: false);
      final errorMessage = controller.errorMessage.value;
      final workspace = controller.activeWorkspace.value;
      final fileCount = controller.workspaceFiles.length;
      final openedTabsCount = controller.openedFiles.length;
      final openedFileName = controller.openedFileName.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: AppSizes.normalAnimation),
        curve: Curves.easeOutCubic,
        height: isVisible
            ? AppSizes.workspaceBottomPanelHeight.h
            : AppSizes.workspaceBottomPanelCollapsedHeight.h,
        decoration: const BoxDecoration(
          color: AppColors.panel,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: AppSizes.borderThin,
            ),
          ),
        ),
        child: Column(
          children: [
            _WorkspaceBottomPanelHeader(
              activePanel: activePanel,
              isVisible: isVisible,
              onSelectPanel: controller.selectBottomPanel,
              onToggle: controller.toggleBottomPanelVisibility,
              onClearLogs: controller.clearWorkspaceLogs,
            ),
            if (isVisible)
              Expanded(
                child: _WorkspaceBottomPanelBody(
                  activePanel: activePanel,
                  logs: logs,
                  errorMessage: errorMessage,
                  workspaceName: workspace?.name ?? 'No workspace',
                  workspacePath: workspace?.path ?? '',
                  fileCount: fileCount,
                  openedTabsCount: openedTabsCount,
                  openedFileName: openedFileName,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _WorkspaceBottomPanelHeader extends StatelessWidget {
  final WorkSpaceBottomPanel activePanel;
  final bool isVisible;
  final ValueChanged<WorkSpaceBottomPanel> onSelectPanel;
  final VoidCallback onToggle;
  final VoidCallback onClearLogs;

  const _WorkspaceBottomPanelHeader({
    required this.activePanel,
    required this.isVisible,
    required this.onSelectPanel,
    required this.onToggle,
    required this.onClearLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.workspaceBottomPanelCollapsedHeight.h,
      decoration: const BoxDecoration(
        color: AppColors.bottomBar,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          ReusableWorkspaceBottomTab(
            label: AppStrings.workspaceBottomPanelTerminal,
            icon: Icons.terminal_rounded,
            isActive: activePanel == WorkSpaceBottomPanel.terminal,
            onTap: () => onSelectPanel(WorkSpaceBottomPanel.terminal),
          ),
          ReusableWorkspaceBottomTab(
            label: AppStrings.workspaceBottomPanelLogs,
            icon: Icons.article_rounded,
            isActive: activePanel == WorkSpaceBottomPanel.logs,
            onTap: () => onSelectPanel(WorkSpaceBottomPanel.logs),
          ),
          ReusableWorkspaceBottomTab(
            label: AppStrings.workspaceBottomPanelProblems,
            icon: Icons.error_outline_rounded,
            isActive: activePanel == WorkSpaceBottomPanel.problems,
            onTap: () => onSelectPanel(WorkSpaceBottomPanel.problems),
          ),
          ReusableWorkspaceBottomTab(
            label: AppStrings.workspaceBottomPanelOutput,
            icon: Icons.output_rounded,
            isActive: activePanel == WorkSpaceBottomPanel.output,
            onTap: () => onSelectPanel(WorkSpaceBottomPanel.output),
          ),
          const Spacer(),
          if (activePanel == WorkSpaceBottomPanel.logs)
            _WorkspaceBottomIconButton(
              tooltip: AppStrings.workspaceBottomPanelClearLogs,
              icon: Icons.clear_all_rounded,
              onTap: onClearLogs,
            ),
          _WorkspaceBottomIconButton(
            tooltip: AppStrings.workspaceBottomPanelToggle,
            icon: isVisible
                ? Icons.keyboard_arrow_down_rounded
                : Icons.keyboard_arrow_up_rounded,
            onTap: onToggle,
          ),
          SizedBox(width: AppSizes.sm.w),
        ],
      ),
    );
  }
}

class _WorkspaceBottomIconButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _WorkspaceBottomIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_WorkspaceBottomIconButton> createState() =>
      _WorkspaceBottomIconButtonState();
}

class _WorkspaceBottomIconButtonState extends State<_WorkspaceBottomIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: AppSizes.fastAnimation),
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppColors.surfaceHover.withValues(alpha: 0.65)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
            ),
            child: Icon(
              widget.icon,
              color: _isHovered ? AppColors.textPrimary : AppColors.textMuted,
              size: 17.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceBottomPanelBody extends StatelessWidget {
  final WorkSpaceBottomPanel activePanel;
  final List<String> logs;
  final String errorMessage;
  final String workspaceName;
  final String workspacePath;
  final int fileCount;
  final int openedTabsCount;
  final String openedFileName;

  const _WorkspaceBottomPanelBody({
    required this.activePanel,
    required this.logs,
    required this.errorMessage,
    required this.workspaceName,
    required this.workspacePath,
    required this.fileCount,
    required this.openedTabsCount,
    required this.openedFileName,
  });

  @override
  Widget build(BuildContext context) {
    switch (activePanel) {
      case WorkSpaceBottomPanel.terminal:
        return const _TerminalPlaceholderPanel();
      case WorkSpaceBottomPanel.logs:
        return _LogsPanel(logs: logs);
      case WorkSpaceBottomPanel.problems:
        return _ProblemsPanel(errorMessage: errorMessage);
      case WorkSpaceBottomPanel.output:
        return _OutputPanel(
          workspaceName: workspaceName,
          workspacePath: workspacePath,
          fileCount: fileCount,
          openedTabsCount: openedTabsCount,
          openedFileName: openedFileName,
        );
    }
  }
}

class _TerminalPlaceholderPanel extends StatelessWidget {
  const _TerminalPlaceholderPanel();

  @override
  Widget build(BuildContext context) {
    return _BottomPanelPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.terminal_rounded,
            title: AppStrings.workspaceTerminalPlaceholderTitle,
          ),
          SizedBox(height: AppSizes.sm.h),
          const ReusableText.body(
            text: AppStrings.workspaceTerminalPlaceholderMessage,
            color: AppColors.textMuted,
          ),
          SizedBox(height: AppSizes.lg.h),
          _MonoLine(text: r'$ flutter analyze'),
          _MonoLine(text: r'$ cargo run -- status'),
          _MonoLine(text: r'$ logixa_engine --health'),
        ],
      ),
    );
  }
}

class _LogsPanel extends StatelessWidget {
  final List<String> logs;

  const _LogsPanel({required this.logs});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const _EmptyPanelMessage(
        icon: Icons.article_outlined,
        message: AppStrings.workspaceLogsEmpty,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.md.w),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: ReusableText(
            text: logs[index],
            fontFamily: AppFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            textDirection: TextDirection.ltr,
          ),
        );
      },
    );
  }
}

class _ProblemsPanel extends StatelessWidget {
  final String errorMessage;

  const _ProblemsPanel({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage.trim().isEmpty) {
      return const _EmptyPanelMessage(
        icon: Icons.check_circle_outline_rounded,
        message: AppStrings.workspaceProblemsEmpty,
        color: AppColors.success,
      );
    }

    return _BottomPanelPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.warning_amber_rounded,
            title: AppStrings.workspaceErrorTitle,
            color: AppColors.warning,
          ),
          SizedBox(height: AppSizes.sm.h),
          ReusableText.body(text: errorMessage, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _OutputPanel extends StatelessWidget {
  final String workspaceName;
  final String workspacePath;
  final int fileCount;
  final int openedTabsCount;
  final String openedFileName;

  const _OutputPanel({
    required this.workspaceName,
    required this.workspacePath,
    required this.fileCount,
    required this.openedTabsCount,
    required this.openedFileName,
  });

  @override
  Widget build(BuildContext context) {
    return _BottomPanelPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelTitle(
            icon: Icons.output_rounded,
            title: AppStrings.workspaceOutputSummary,
          ),
          SizedBox(height: AppSizes.md.h),
          _OutputRow(label: 'Workspace', value: workspaceName),
          _OutputRow(label: 'Path', value: workspacePath),
          _OutputRow(label: 'Indexed Items', value: '$fileCount'),
          _OutputRow(label: 'Opened Tabs', value: '$openedTabsCount'),
          _OutputRow(
            label: 'Active File',
            value: openedFileName.isEmpty ? 'No active file' : openedFileName,
          ),
        ],
      ),
    );
  }
}

class _BottomPanelPadding extends StatelessWidget {
  final Widget child;

  const _BottomPanelPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.lg.w),
      child: child,
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _PanelTitle({
    required this.icon,
    required this.title,
    this.color = AppColors.primaryHover,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppSizes.iconSm.sp),
        SizedBox(width: AppSizes.sm.w),
        ReusableText(
          text: title,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}

class _MonoLine extends StatelessWidget {
  final String text;

  const _MonoLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: ReusableText(
        text: text,
        fontFamily: AppFonts.mono,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

class _OutputRow extends StatelessWidget {
  final String label;
  final String value;

  const _OutputRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm.h),
      child: Row(
        children: [
          SizedBox(
            width: 128.w,
            child: ReusableText(
              text: label,
              fontFamily: AppFonts.english,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              textDirection: TextDirection.ltr,
            ),
          ),
          Expanded(
            child: ReusableText(
              text: value,
              fontFamily: AppFonts.mono,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanelMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyPanelMessage({
    required this.icon,
    required this.message,
    this.color = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm.sp, color: color),
          SizedBox(width: AppSizes.sm.w),
          ReusableText.body(text: message, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
