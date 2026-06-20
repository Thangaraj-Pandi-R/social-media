import 'package:flutter/material.dart';
import 'package:social_media/core/theme/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 14.5,
                color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
                letterSpacing: 0.1,
              ),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                labelStyle: TextStyle(
                  color: focused ? AppTheme.primaryNeon : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    prefixIcon,
                    size: 20,
                    color: focused ? AppTheme.primaryNeon : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        );
      },
    );
  }
}
