import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/app_sizes.dart';
import '../../../widgets/core_page.dart';
import '../controllers/data_center_controller.dart';
import 'sections/data_center_content_section.dart';
import 'sections/data_center_header_section.dart';
import 'sections/data_center_overview_section.dart';

class DataCenterView extends GetView<DataCenterController> {
  const DataCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return CorePage(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.pageHorizontalPadding.w,
            vertical: AppSizes.pageVerticalPadding.h,
          ),
          child: Column(
            children: [
              const DataCenterHeaderSection(),
              SizedBox(height: AppSizes.lg.h),
              const DataCenterOverviewSection(),
              SizedBox(height: AppSizes.lg.h),
              const Expanded(child: DataCenterContentSection()),
            ],
          ),
        ),
      ),
    );
  }
}
