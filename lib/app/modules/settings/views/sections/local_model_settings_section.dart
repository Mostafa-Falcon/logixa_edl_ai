import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_sizes.dart';
import 'active_model_profile_form_section.dart';
import 'engine_status_section.dart';
import 'local_model_runtime_policy_section.dart';
import 'runtime_model_router_section.dart';
import 'model_profiles_section.dart';
import 'settings_header_section.dart';
import 'system_prompt_settings_section.dart';

class LocalModelSettingsSection extends StatelessWidget {
  const LocalModelSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSizes.pageHorizontalPadding.w),
      children: [
        const SettingsHeaderSection(),
        SizedBox(height: AppSizes.xxl.h),
        const EngineStatusSection(),
        SizedBox(height: AppSizes.xl.h),
        const LocalModelRuntimePolicySection(),
        SizedBox(height: AppSizes.xl.h),
        const RuntimeModelRouterSection(),
        SizedBox(height: AppSizes.xl.h),
        const SystemPromptSettingsSection(),
        SizedBox(height: AppSizes.xl.h),
        const ModelProfilesSection(),
        SizedBox(height: AppSizes.xl.h),
        const ActiveModelProfileFormSection(),
      ],
    );
  }
}
