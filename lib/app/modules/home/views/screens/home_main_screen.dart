import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/app_sizes.dart';
import '../sections/home_header.dart';
import '../sections/home_quick_actions.dart';
import '../sections/home_recent_workspaces.dart';

class HomeMainScreen extends StatelessWidget {
  const HomeMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.pageHorizontalPadding.w,
        vertical: AppSizes.pageVerticalPadding.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeHeader(),
          SizedBox(height: AppSizes.sectionGap.h),
          const HomeQuickActions(),
          SizedBox(height: AppSizes.sectionGap.h),
          const HomeRecentWorkspaces(),
        ],
      ),
    );
  }
}
