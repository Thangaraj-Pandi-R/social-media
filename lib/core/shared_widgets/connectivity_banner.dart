import 'package:flutter/material.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/services/connectivity_provider.dart';
import 'package:social_media/core/utils/string_constants.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final isConnected = connectivity.isConnected;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1014) : const Color(0xFFFEF2F2),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.redAccent.withValues(alpha: 0.4) : Colors.red.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: isDark ? Colors.redAccent : Colors.red.shade700,
              size: 16,
            ),
            const SizedBox(width: 8),
            AppText(
              AppStrings.noInternetConnectionLong,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.redAccent.shade100 : Colors.red.shade800,
            ),
          ],
        ),
      ),
      crossFadeState: isConnected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 300),
    );
  }
}
