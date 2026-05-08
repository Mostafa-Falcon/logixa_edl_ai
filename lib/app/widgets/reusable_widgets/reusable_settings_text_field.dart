import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import 'reusable_text.dart';

class ReusableSettingsTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int? maxLines;

  const ReusableSettingsTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.suffix,
    this.keyboardType,
    this.maxLines = 1,
  });

  List<TextInputFormatter>? get _inputFormatters {
    final type = keyboardType;
    if (type == null) return null;

    if (type == TextInputType.number) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))];
    }

    if (type == const TextInputType.numberWithOptions(decimal: true)) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReusableText(
          text: label,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: AppSizes.sm.h),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: _inputFormatters,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textDisabled,
              fontSize: 12.sp,
            ),
            filled: true,
            fillColor: AppColors.editorBackground,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.md.w,
              vertical: AppSizes.md.h,
            ),
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: EdgeInsetsDirectional.only(end: AppSizes.sm.w),
                    child: suffix,
                  ),
            suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 42.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              borderSide: const BorderSide(color: AppColors.primaryHover),
            ),
          ),
        ),
      ],
    );
  }
}
