import 'package:flutter/material.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/shared_widgets/brand_title.dart';
import 'package:social_media/core/theme/theme.dart';

class AuthGlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const AuthGlowOrb({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

class AuthGlassCard extends StatelessWidget {
  final Widget child;
  const AuthGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 20),
        const BrandTitle(fontSize: 38),
        const SizedBox(height: 10),
        AppText.body(
          subtitle,
          textAlign: TextAlign.center,
          fontSize: 15,
          isSecondary: true,
          height: 1.4,
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFocused = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isFocused,
      builder: (context, focused, child) {
        return Focus(
          onFocusChange: (val) => isFocused.value = val,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(
                color: isDark ? const Color(0xFFE8EFF8) : const Color(0xFF0F172A),
                fontSize: 15,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: TextStyle(
                  color: focused 
                      ? AppTheme.primaryNeon 
                      : (isDark ? const Color(0xFF6B7A99) : const Color(0xFF475569)),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF3D4A60) : const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    icon,
                    size: 20,
                    color: focused 
                        ? AppTheme.primaryNeon 
                        : (isDark ? const Color(0xFF6B7A99) : const Color(0xFF475569)),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.06) 
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.06) 
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryNeon, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                errorStyle: const TextStyle(fontSize: 11.5),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AuthVisibilityToggle extends StatelessWidget {
  final bool isObscure;
  final VoidCallback onTap;
  const AuthVisibilityToggle({
    super.key,
    required this.isObscure,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: const Color(0xFF6B7A99),
      ),
      splashRadius: 20,
      onPressed: onTap,
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D0E0E) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.4 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: AppText(
              message,
              color: isDark ? const Color(0xFFFF8080) : const Color(0xFF991B1B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  final String question;
  final String actionLabel;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.question,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppText.body(
          '$question ',
          fontSize: 14,
          isSecondary: true,
        ),
        GestureDetector(
          onTap: onTap,
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: AppText(
              actionLabel,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
