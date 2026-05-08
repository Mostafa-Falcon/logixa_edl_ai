import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_strings.dart';
import '../../../../widgets/app_core/view/sections/app_activity_bar.dart';
import '../../controllers/home_controller.dart';

class HomeSidebar extends GetView<HomeController> {
  const HomeSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activeIndex = controller.selectedSidebarIndex.value;

      return AppActivityBar(
        topItems: [
          for (var index = 0; index < controller.sidebarItems.length; index++)
            AppActivityBarItem(
              tooltip: controller.sidebarItems[index].label,
              icon: controller.sidebarItems[index].icon,
              isActive: activeIndex == index,
              onTap: () => controller.selectSidebarItem(index),
            ),
        ],
        bottomItems: const [
          AppActivityBarItem(
            tooltip: AppStrings.navProfile,
            icon: Icons.person_outline_rounded,
          ),
        ],
      );
    });
  }
}
