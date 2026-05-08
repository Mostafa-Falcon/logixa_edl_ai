import 'package:flutter/material.dart';
import 'package:logixa_edl_ai/app/constants/app_colors.dart';
import 'package:logixa_edl_ai/app/widgets/app_core/view/sections/app_main_navigation.dart';
import 'package:logixa_edl_ai/app/widgets/app_core/view/top_bar.dart';

class CorePage extends StatelessWidget {
  final Widget body;
  final bool showMainNavigation;

  const CorePage({
    super.key,
    required this.body,
    this.showMainNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TopBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              if (showMainNavigation) const AppMainNavigation(),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
