import 'package:flutter/material.dart';
import 'package:social_media/core/theme/theme.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final double? height;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final bool isSecondary;

  const AppText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.height,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.isSecondary = false,
  });

  const AppText.heading(
    this.text, {
    super.key,
    this.fontSize = 20,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.letterSpacing = 0.1,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.height,
  }) : isSecondary = false;

  const AppText.body(
    this.text, {
    super.key,
    this.fontSize = 14.5,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.height = 1.45,
    this.letterSpacing = 0.1,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.isSecondary = false,
  });

  const AppText.caption(
    this.text, {
    super.key,
    this.fontSize = 12,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.letterSpacing = 0.1,
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.height,
  }) : isSecondary = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color resolvedColor;
    if (color != null) {
      resolvedColor = color!;
    } else if (isSecondary) {
      resolvedColor = isDark ? AppTheme.textDarkSecondary : AppTheme.textLightSecondary;
    } else {
      resolvedColor = isDark ? AppTheme.textDarkPrimary : AppTheme.textLightPrimary;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: resolvedColor,
        letterSpacing: letterSpacing,
        height: height,
      ),
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}
