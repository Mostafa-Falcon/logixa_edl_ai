import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_fonts.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';
import '../../controllers/work_space_controller.dart';

class WorkspaceTerminalPanel extends GetView<WorkSpaceController> {
  const WorkspaceTerminalPanel({super.key});

  static const double _minUsableHeight = 88;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final minUsableHeight = _minUsableHeight.h;

        if (maxHeight.isFinite && maxHeight < minUsableHeight) {
          return const SizedBox.shrink();
        }

        return Obx(() {
          final hasWorkspace = controller.hasWorkspace;
          final isRunning = controller.isTerminalRunning.value;
          final isStarting = controller.isTerminalStarting.value;
          final status = controller.terminalStatusMessage.value;
          final workingDirectory = controller.terminalWorkingDirectory.value;

          return ClipRect(
            child: Column(
              children: [
                _TerminalToolbar(
                  hasWorkspace: hasWorkspace,
                  isRunning: isRunning,
                  isStarting: isStarting,
                  status: status,
                  workingDirectory: workingDirectory,
                  onStart: controller.startTerminal,
                  onStop: controller.stopTerminal,
                  onRestart: controller.restartTerminal,
                ),
                Expanded(
                  child: hasWorkspace
                      ? _TerminalViewFrame(isRunning: isRunning)
                      : const _TerminalEmptyState(),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _TerminalToolbar extends StatelessWidget {
  final bool hasWorkspace;
  final bool isRunning;
  final bool isStarting;
  final String status;
  final String workingDirectory;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRestart;

  const _TerminalToolbar({
    required this.hasWorkspace,
    required this.isRunning,
    required this.isStarting,
    required this.status,
    required this.workingDirectory,
    required this.onStart,
    required this.onStop,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: AppSizes.md.w),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: AppSizes.borderThin,
          ),
        ),
      ),
      child: Row(
        children: [
          _TerminalStatusPill(isRunning: isRunning, status: status),
          SizedBox(width: AppSizes.md.w),
          Expanded(
            child: _TerminalWorkingDirectoryLabel(
              workingDirectory: workingDirectory,
            ),
          ),
          SizedBox(width: AppSizes.md.w),
          ReusableButton(
            title: AppStrings.workspaceTerminalStart,
            icon: Icons.play_arrow_rounded,
            height: 32,
            variant: ReusableButtonVariant.secondary,
            isLoading: isStarting,
            onPressed: hasWorkspace && !isRunning && !isStarting
                ? onStart
                : null,
          ),
          SizedBox(width: AppSizes.sm.w),
          ReusableButton(
            title: AppStrings.workspaceTerminalRestart,
            icon: Icons.restart_alt_rounded,
            height: 32,
            variant: ReusableButtonVariant.ghost,
            onPressed: hasWorkspace && isRunning && !isStarting
                ? onRestart
                : null,
          ),
          SizedBox(width: AppSizes.sm.w),
          ReusableButton(
            title: AppStrings.workspaceTerminalStop,
            icon: Icons.stop_rounded,
            height: 32,
            variant: ReusableButtonVariant.danger,
            onPressed: isRunning ? onStop : null,
          ),
        ],
      ),
    );
  }
}

class _TerminalStatusPill extends StatelessWidget {
  final bool isRunning;
  final String status;

  const _TerminalStatusPill({required this.isRunning, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = isRunning ? AppColors.success : AppColors.textMuted;
    final background = isRunning
        ? AppColors.successSoft.withValues(alpha: 0.42)
        : AppColors.surfaceHover.withValues(alpha: 0.65);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.md.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRunning ? Icons.circle_rounded : Icons.circle_outlined,
            size: 9.sp,
            color: color,
          ),
          SizedBox(width: AppSizes.xs.w),
          ReusableText(
            text: status,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _TerminalWorkingDirectoryLabel extends StatelessWidget {
  final String workingDirectory;

  const _TerminalWorkingDirectoryLabel({required this.workingDirectory});

  @override
  Widget build(BuildContext context) {
    final value = workingDirectory.trim().isEmpty
        ? AppStrings.workspaceTerminalWorkingDirectoryPending
        : workingDirectory;

    return Row(
      children: [
        const ReusableText(
          text: AppStrings.workspaceTerminalWorkingDirectory,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.textMuted,
        ),
        SizedBox(width: AppSizes.sm.w),
        Expanded(
          child: ReusableText(
            text: value,
            fontFamily: AppFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }
}

class _TerminalViewFrame extends GetView<WorkSpaceController> {
  final bool isRunning;

  const _TerminalViewFrame({required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.terminal,
      child: TerminalView(
        controller.terminal,
        padding: EdgeInsets.all(AppSizes.md.w),
        autofocus: isRunning,
        readOnly: !isRunning,
      ),
    );
  }
}

class _TerminalEmptyState extends StatelessWidget {
  const _TerminalEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 420.w,
        padding: EdgeInsets.all(AppSizes.xl.w),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.terminal_rounded,
              color: AppColors.primaryHover,
              size: AppSizes.iconMd.sp,
            ),
            SizedBox(height: AppSizes.md.h),
            const ReusableText(
              text: AppStrings.workspaceTerminalNoWorkspaceTitle,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.sm.h),
            const ReusableText.body(
              text: AppStrings.workspaceTerminalNoWorkspaceMessage,
              color: AppColors.textMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
