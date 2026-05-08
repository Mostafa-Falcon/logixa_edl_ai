
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';

class ReusableText extends StatelessWidget {
  final String text;

  final String fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final Color? color;
  final double? height;
  final double? letterSpacing;
  final double? wordSpacing;

  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextBaseline? textBaseline;
  final Locale? locale;

  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;

  final Color? backgroundColor;
  final List<Shadow>? shadows;
  final List<FontFeature>? fontFeatures;
  final List<FontVariation>? fontVariations;

  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final StrutStyle? strutStyle;
  final TextScaler? textScaler;
  final Color? selectionColor;

  final bool selectable;
  final bool enableInteractiveSelection;
  final GestureTapCallback? onTap;

  final TextStyle? style;

  const ReusableText({
    super.key,
    required this.text,
    this.fontFamily = AppFonts.arabic,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.color,
    this.height,
    this.letterSpacing,
    this.wordSpacing,
    this.textAlign,
    this.textDirection,
    this.textBaseline,
    this.locale,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.backgroundColor,
    this.shadows,
    this.fontFeatures,
    this.fontVariations,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.strutStyle,
    this.textScaler,
    this.selectionColor,
    this.selectable = false,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.style,
  });

  const ReusableText.title({
    super.key,
    required this.text,
    this.color = AppColors.textPrimary,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.onTap,
  })  : fontFamily = AppFonts.arabic,
        fontSize = 28,
        fontWeight = FontWeight.w800,
        fontStyle = null,
        height = 1.25,
        letterSpacing = null,
        wordSpacing = null,
        textDirection = null,
        textBaseline = null,
        locale = null,
        softWrap = null,
        decoration = null,
        decorationColor = null,
        decorationStyle = null,
        decorationThickness = null,
        backgroundColor = null,
        shadows = null,
        fontFeatures = null,
        fontVariations = null,
        textWidthBasis = null,
        textHeightBehavior = null,
        strutStyle = null,
        textScaler = null,
        selectionColor = null,
        selectable = false,
        enableInteractiveSelection = true,
        style = null;

  const ReusableText.body({
    super.key,
    required this.text,
    this.color = AppColors.textSecondary,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.onTap,
  })  : fontFamily = AppFonts.arabic,
        fontSize = 14,
        fontWeight = FontWeight.w500,
        fontStyle = null,
        height = 1.65,
        letterSpacing = null,
        wordSpacing = null,
        textDirection = null,
        textBaseline = null,
        locale = null,
        softWrap = null,
        decoration = null,
        decorationColor = null,
        decorationStyle = null,
        decorationThickness = null,
        backgroundColor = null,
        shadows = null,
        fontFeatures = null,
        fontVariations = null,
        textWidthBasis = null,
        textHeightBehavior = null,
        strutStyle = null,
        textScaler = null,
        selectionColor = null,
        selectable = false,
        enableInteractiveSelection = true,
        style = null;

  TextStyle get _textStyle {
    final baseStyle = style ??
        TextStyle(
          fontSize: (fontSize ?? 16).sp,
          fontWeight: fontWeight ?? FontWeight.w400,
          fontStyle: fontStyle,
          color: color ?? AppColors.textPrimary,
          height: height,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          textBaseline: textBaseline,
          locale: locale,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
          backgroundColor: backgroundColor,
          shadows: shadows,
          fontFeatures: fontFeatures,
          fontVariations: fontVariations,
        );

    return baseStyle.copyWith(
      fontFamily: fontFamily,
      fontFamilyFallback: const [
        AppFonts.arabicAlt,
        AppFonts.english,
        'Arial',
        'Noto Sans Arabic',
        'monospace',
        'sans-serif',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectable) {
      return SelectableText(
        text,
        style: _textStyle,
        textAlign: textAlign ?? TextAlign.start,
        textDirection: textDirection,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        strutStyle: strutStyle,
        textScaler: textScaler,
        enableInteractiveSelection: enableInteractiveSelection,
        onTap: onTap,
      );
    }

    return Text(
      text,
      style: _textStyle,
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      strutStyle: strutStyle,
      textScaler: textScaler,
      selectionColor: selectionColor,
    );
  }
}
