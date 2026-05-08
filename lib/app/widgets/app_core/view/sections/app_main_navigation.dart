import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/app_strings.dart';
import '../../../../routes/app_pages.dart';
import 'app_activity_bar.dart';

class AppMainNavigation extends StatelessWidget {
  const AppMainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return AppActivityBar(
      topItems: [
        AppActivityBarItem(
          tooltip: AppStrings.navHome,
          icon: Icons.dashboard_rounded,
          isActive: _isActive(currentRoute, Routes.home),
          onTap: () => _goTo(Routes.home),
        ),
        AppActivityBarItem(
          tooltip: AppStrings.navWorkspace,
          icon: Icons.code_rounded,
          isActive: _isActive(currentRoute, Routes.workSpace),
          onTap: () => _goTo(Routes.workSpace),
        ),
        AppActivityBarItem(
          tooltip: AppStrings.navChat,
          icon: Icons.chat_bubble_rounded,
          isActive: _isActive(currentRoute, Routes.chatPage),
          onTap: () => _goTo(Routes.chatPage),
        ),
        AppActivityBarItem(
          tooltip: AppStrings.navData,
          icon: Icons.hub_rounded,
          isActive: _isActive(currentRoute, Routes.dataCenter),
          onTap: () => _goTo(Routes.dataCenter),
        ),
      ],
      bottomItems: [
        AppActivityBarItem(
          tooltip: AppStrings.navSettings,
          icon: Icons.settings_rounded,
          isActive: _isActive(currentRoute, Routes.settings),
          onTap: () => _goTo(Routes.settings),
        ),
      ],
    );
  }

  bool _isActive(String currentRoute, String route) {
    return currentRoute == route || currentRoute.startsWith('$route/');
  }

  void _goTo(String route) {
    if (Get.currentRoute == route) return;
    Get.offNamed(route);
  }
}
