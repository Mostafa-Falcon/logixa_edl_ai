import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/app_strings.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_core/view/sections/app_activity_bar.dart';
import '../../../widgets/core_page.dart';
import '../controllers/settings_controller.dart';
import 'sections/local_model_settings_section.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return CorePage(
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            AppActivityBar(
              topItems: [
                AppActivityBarItem(
                  tooltip: AppStrings.navHome,
                  icon: Icons.dashboard_rounded,
                  onTap: () => Get.offAllNamed(Routes.home),
                ),
                AppActivityBarItem(
                  tooltip: AppStrings.navWorkspace,
                  icon: Icons.code_rounded,
                  onTap: () => Get.offNamed(Routes.workSpace),
                ),
                const AppActivityBarItem(
                  tooltip: AppStrings.navChat,
                  icon: Icons.chat_bubble_rounded,
                ),
                const AppActivityBarItem(
                  tooltip: AppStrings.navTerminal,
                  icon: Icons.terminal_rounded,
                ),
                const AppActivityBarItem(
                  tooltip: AppStrings.navData,
                  icon: Icons.storage_rounded,
                ),
              ],
              bottomItems: const [
                AppActivityBarItem(
                  tooltip: AppStrings.navSettings,
                  icon: Icons.settings_rounded,
                  isActive: true,
                ),
              ],
            ),
            const Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: LocalModelSettingsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
