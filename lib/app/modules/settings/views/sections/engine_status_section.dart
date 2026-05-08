import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../data/services/engine_client_service.dart';
import '../../../../widgets/reusable_widgets/reusable_button.dart';
import '../../../../widgets/reusable_widgets/reusable_status_badge.dart';
import '../../../../widgets/reusable_widgets/reusable_surface_card.dart';
import '../../../../widgets/reusable_widgets/reusable_text.dart';

class EngineStatusSection extends StatelessWidget {
  const EngineStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    final engineClientService = Get.find<EngineClientService>();

    return ReusableSurfaceCard(
      padding: EdgeInsets.all(AppSizes.xl.w),
      child: Obx(() {
        final status = engineClientService.engineStatus.value;
        final statusLabel = status.isChecking
            ? AppStrings.engineChecking
            : status.isOnline
            ? AppStrings.engineOnline
            : AppStrings.engineOffline;
        final statusColor = status.isChecking
            ? AppColors.runtimeBusy
            : status.isOnline
            ? AppColors.runtimeRunning
            : AppColors.runtimeError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                    border: Border.all(color: statusColor.withValues(alpha: 0.28)),
                  ),
                  child: Icon(
                    Icons.router_rounded,
                    color: statusColor,
                    size: AppSizes.iconMd.sp,
                  ),
                ),
                SizedBox(width: AppSizes.md.w),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReusableText.title(text: AppStrings.engineStatusTitle),
                      ReusableText.body(text: AppStrings.engineStatusDescription),
                    ],
                  ),
                ),
                ReusableStatusBadge(
                  label: statusLabel,
                  color: statusColor,
                  icon: status.isOnline
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                ),
                SizedBox(width: AppSizes.md.w),
                ReusableButton(
                  title: AppStrings.engineRefreshButton,
                  icon: Icons.sync_rounded,
                  isLoading: status.isChecking,
                  onPressed: () => engineClientService.refreshEngineStatus(),
                ),
              ],
            ),
            SizedBox(height: AppSizes.lg.h),
            Wrap(
              spacing: AppSizes.md.w,
              runSpacing: AppSizes.md.h,
              children: [
                _EngineStatusItem(
                  label: AppStrings.engineServiceLabel,
                  value: status.service,
                ),
                _EngineStatusItem(
                  label: AppStrings.engineVersionLabel,
                  value: status.version,
                ),
                _EngineStatusItem(
                  label: AppStrings.engineRuntimeStageLabel,
                  value: status.runtimeStage,
                ),
                _EngineStatusItem(
                  label: AppStrings.engineModelLoadedLabel,
                  value: status.modelLoaded ? 'true' : 'false',
                ),
                _EngineStatusItem(
                  label: AppStrings.engineLocalModelEnabledLabel,
                  value: status.localModelEnabled ? 'true' : 'false',
                ),
                _EngineStatusItem(
                  label: AppStrings.engineActiveProfileLabel,
                  value: status.activeModelProfileId ?? AppStrings.engineNoActiveProfile,
                ),
                _EngineStatusItem(
                  label: AppStrings.engineUptimeLabel,
                  value: status.uptimeSeconds == null
                      ? AppStrings.engineUnknownValue
                      : '${status.uptimeSeconds}s',
                ),
                _EngineStatusItem(
                  label: AppStrings.engineConfigPathLabel,
                  value: status.configPath ?? AppStrings.engineUnknownValue,
                ),
                _EngineStatusItem(
                  label: AppStrings.engineMemoryPathLabel,
                  value: status.memoryDbPath ?? AppStrings.engineUnknownValue,
                ),
              ],
            ),
            if (status.errorMessage != null) ...[
              SizedBox(height: AppSizes.md.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.md.w),
                decoration: BoxDecoration(
                  color: AppColors.errorSoft.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
                ),
                child: ReusableText.body(
                  text: status.errorMessage!,
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _EngineStatusItem extends StatelessWidget {
  final String label;
  final String value;

  const _EngineStatusItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w,
      padding: EdgeInsets.all(AppSizes.md.w),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReusableText(
            text: label,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 5.h),
          ReusableText(
            text: value,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
