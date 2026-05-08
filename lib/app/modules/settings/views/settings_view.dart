import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/core_page.dart';
import '../controllers/settings_controller.dart';
import 'sections/local_model_settings_section.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CorePage(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: LocalModelSettingsSection(),
      ),
    );
  }
}
