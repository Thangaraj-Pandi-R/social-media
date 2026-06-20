import 'package:flutter/material.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/shared_widgets/app_button.dart';
import 'package:social_media/core/utils/string_constants.dart';

class ErrorLayout extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorLayout({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            AppText.body(
              message,
              textAlign: TextAlign.center,
              fontSize: 15,
              isSecondary: true,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                label: AppStrings.tryAgain,
                icon: Icons.refresh_rounded,
                style: AppButtonStyle.outline,
                width: 160,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
