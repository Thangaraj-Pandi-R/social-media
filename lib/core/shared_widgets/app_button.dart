import 'package:flutter/material.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';

enum AppButtonStyle { primary, secondary, outline, danger }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonStyle style;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.style = AppButtonStyle.primary,
    this.height = 48,
    this.width,
    this.borderRadius = 24,
    this.fontSize = 15,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading && widget.onPressed != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading && widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isDisabled && !widget.isLoading && widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Gradient? gradient;
    Color? backgroundColor;
    Color textColor;
    Border? border;
    List<BoxShadow>? boxShadow;

    if (widget.isDisabled || widget.onPressed == null) {
      backgroundColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
      textColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    } else {
      switch (widget.style) {
        case AppButtonStyle.primary:
          gradient = AppTheme.primaryGradient;
          textColor = Colors.white;
          break;
        case AppButtonStyle.secondary:
          backgroundColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
          textColor = isDark ? Colors.white : const Color(0xFF0F172A);
          break;
        case AppButtonStyle.outline:
          backgroundColor = Colors.transparent;
          textColor = isDark ? Colors.white : AppTheme.primaryNeon;
          border = Border.all(
            color: isDark ? Colors.white24 : AppTheme.primaryNeon.withValues(alpha: 0.5),
            width: 1.5,
          );
          break;
        case AppButtonStyle.danger:
          backgroundColor = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
          textColor = isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
          border = Border.all(
            color: isDark ? Colors.redAccent.withValues(alpha: 0.3) : Colors.red.shade200,
            width: 1.2,
          );
          break;
      }
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: (widget.isDisabled || widget.isLoading) ? null : widget.onPressed,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border,
            boxShadow: boxShadow,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  height: widget.height * 0.45,
                  width: widget.height * 0.45,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: textColor, size: widget.fontSize * 1.2),
                      const SizedBox(width: 8),
                    ],
                    AppText(
                      widget.label,
                      color: textColor,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
