import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_fonts.dart';
import '../../../../constants/app_sizes.dart';
import '../../controllers/work_space_controller.dart';

class WorkspaceCodeEditor extends StatefulWidget {
  const WorkspaceCodeEditor({super.key});

  @override
  State<WorkspaceCodeEditor> createState() => _WorkspaceCodeEditorState();
}

class _WorkspaceCodeEditorState extends State<WorkspaceCodeEditor> {
  final WorkSpaceController controller = Get.find<WorkSpaceController>();
  late final CodeController _codeController = CodeController(text: '');

  String _activePath = '';
  bool _isApplyingExternalText = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filePath = controller.openedFilePath.value;
      final content = controller.openedFileContent.value;
      final isEditable = controller.isActiveFileEditable;

      _syncEditorText(filePath: filePath, content: content);

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.editorBackground,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: CodeField(
            controller: _codeController,
            expands: true,
            wrap: false,
            readOnly: !isEditable,
            background: AppColors.editorBackground,
            cursorColor: AppColors.editorCursor,
            padding: EdgeInsets.all(AppSizes.lg.w),
            textSelectionTheme: const TextSelectionThemeData(
              selectionColor: AppColors.editorSelection,
              cursorColor: AppColors.editorCursor,
            ),
            textStyle: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 13.sp,
              height: 1.55,
              fontWeight: FontWeight.w500,
              color: isEditable ? AppColors.textSecondary : AppColors.textMuted,
            ),
            onChanged: _handleEditorChanged,
          ),
        ),
      );
    });
  }

  void _syncEditorText({required String filePath, required String content}) {
    if (_activePath == filePath && _codeController.text == content) return;

    _isApplyingExternalText = true;
    _activePath = filePath;
    _codeController.text = content;
    _codeController.selection = TextSelection.collapsed(
      offset: _codeController.text.length,
    );
    _isApplyingExternalText = false;
  }

  void _handleEditorChanged(String value) {
    if (_isApplyingExternalText) return;
    controller.updateActiveOpenedFileContent(value);
  }
}
