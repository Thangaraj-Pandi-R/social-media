import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media/core/theme/theme.dart';

class UserAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final VoidCallback? onTap;
  final bool isNeonGlow;
  final bool hasThinBorder;
  final bool hasPlainBorder;
  final ImageProvider? localImage;

  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.onTap,
    this.isNeonGlow = false,
    this.hasThinBorder = false,
    this.hasPlainBorder = false,
    this.localImage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasImage = localImage != null || imageUrl.isNotEmpty;
    final imageProvider = hasImage 
        ? (localImage ?? CachedNetworkImageProvider(imageUrl))
        : null;

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundImage: imageProvider,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
      child: hasImage 
          ? null 
          : Icon(
              Icons.person_rounded, 
              size: radius * 1.2, 
              color: isDark ? Colors.white60 : Colors.black38,
            ),
    );

    if (isNeonGlow) {
      avatar = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
        ),
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppTheme.darkBg : Colors.white,
          ),
          child: avatar,
        ),
      );
    } else if (hasThinBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryNeon.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: avatar,
      );
    } else if (hasPlainBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
            width: 1.0,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}
