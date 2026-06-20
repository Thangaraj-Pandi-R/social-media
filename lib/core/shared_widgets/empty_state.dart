import 'package:flutter/material.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/theme/theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? actionButton;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131926) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? AppTheme.primaryNeon.withValues(alpha: 0.8) : AppTheme.primaryNeon,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            AppText.heading(
              title,
              textAlign: TextAlign.center,
              fontSize: 18,
            ),
            const SizedBox(height: 8),
            AppText.body(
              message,
              textAlign: TextAlign.center,
              fontSize: 14,
              isSecondary: true,
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
