import 'package:flutter/material.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/utils/string_constants.dart';

class BrandTitle extends StatelessWidget {
  final double fontSize;
  const BrandTitle({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
      child: Text(
        AppStrings.appName,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: fontSize,
          color: Colors.white,
          letterSpacing: fontSize > 30 ? -1.5 : -0.8,
          height: 1,
        ),
      ),
    );
  }
}

