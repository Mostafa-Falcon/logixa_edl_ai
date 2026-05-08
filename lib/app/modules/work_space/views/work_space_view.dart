import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/core_page.dart';
import '../controllers/work_space_controller.dart';
import 'sections/workspace_activity_bar.dart';
import 'sections/workspace_bottom_panel.dart';
import 'sections/workspace_editor_area.dart';
import 'sections/workspace_extensions_panel.dart';
import 'sections/workspace_file_explorer.dart';

class WorkSpaceView extends GetView<WorkSpaceController> {
  const WorkSpaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return CorePage(
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            const WorkspaceActivityBar(),
            Obx(() {
              if (controller.isExtensionsPanelActive) {
                return const WorkspaceExtensionsPanel();
              }

              return const WorkspaceFileExplorer();
            }),
            const Expanded(
              child: Column(
                children: [
                  Expanded(child: WorkspaceEditorArea()),
                  WorkspaceBottomPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
