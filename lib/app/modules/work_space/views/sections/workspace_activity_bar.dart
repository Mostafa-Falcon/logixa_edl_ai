import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_strings.dart';
import '../../../../routes/app_pages.dart';
import '../../../../widgets/app_core/view/sections/app_activity_bar.dart';
import '../../controllers/work_space_controller.dart';

class WorkspaceActivityBar extends GetView<WorkSpaceController> {
  const WorkspaceActivityBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppActivityBar(
        topItems: [
          AppActivityBarItem(
            tooltip: AppStrings.openExplorerTooltip,
            icon: Icons.content_copy_rounded,
            isActive: controller.isExplorerPanelActive,
            onTap: () => controller.selectSidePanel(WorkSpaceSidePanel.explorer),
          ),
          const AppActivityBarItem(
            tooltip: AppStrings.searchTooltip,
            icon: Icons.search_rounded,
          ),
          const AppActivityBarItem(
            tooltip: AppStrings.navData,
            icon: Icons.account_tree_rounded,
          ),
          AppActivityBarItem(
            tooltip: AppStrings.openExtensionsTooltip,
            icon: Icons.extension_rounded,
            isActive: controller.isExtensionsPanelActive,
            onTap: () => controller.selectSidePanel(WorkSpaceSidePanel.extensions),
          ),
        ],
        bottomItems: [
          AppActivityBarItem(
            tooltip: AppStrings.settingsTooltip,
            icon: Icons.settings_rounded,
            onTap: () => Get.toNamed(Routes.settings),
          ),
        ],
      );
    });
  }
}
