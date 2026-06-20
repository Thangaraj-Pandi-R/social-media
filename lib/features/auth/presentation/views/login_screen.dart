import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/utils/validators.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/auth/presentation/views/auth_widgets.dart';
import 'package:social_media/features/auth/presentation/views/register_screen.dart';
import 'package:social_media/core/shared_widgets/brand_title.dart';
import 'package:social_media/core/shared_widgets/app_button.dart';
import 'package:social_media/core/utils/string_constants.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  Future<void> _submit(
      BuildContext context, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await authProvider.login(
      authProvider.emailCtrl.text,
      authProvider.passwordCtrl.text,
    );
    if (success && context.mounted) {
      ToastService.showSuccess(
        context,
        '${AppStrings.splashWelcome}${authProvider.user?.displayName}!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetVal = ValueNotifier<double>(1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF04060E), const Color(0xFF0A0D1A), const Color(0xFF0F0A1E)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFEEF2F6), const Color(0xFFE2E8F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          RepaintBoundary(
            child: ValueListenableBuilder<double>(
              valueListenable: targetVal,
              builder: (context, target, child) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.0 - target, end: target),
                  duration: const Duration(seconds: 8),
                  onEnd: () {
                    targetVal.value = 1.0 - targetVal.value;
                  },
                  builder: (context, animValue, child) {
                    return Stack(
                      children: [
                        Positioned(
                          top: -80,
                          right: -60,
                          child: AuthGlowOrb(
                            size: 300,
                            color: AppTheme.primaryNeon.withValues(
                              alpha: 0.18 + 0.08 * animValue,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -100,
                          left: -80,
                          child: AuthGlowOrb(
                            size: 320,
                            color: AppTheme.secondaryNeon.withValues(
                              alpha: 0.12 + 0.06 * animValue,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            top: size.height * 0.45,
            right: -40,
            child: AuthGlowOrb(
              size: 180,
              color: AppTheme.accentNeon.withValues(alpha: 0.08),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1.0 - value) * 40),
                        child: child,
                      ),
                    );
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthHeader(
                          subtitle: AppStrings.loginHeaderSubtitle,
                        ),
                        const SizedBox(height: 40),

                        Selector<AuthProvider, ({bool hidePassword, String? error, bool loading})>(
                          selector: (_, provider) => (
                            hidePassword: provider.hidePassword,
                            error: provider.error,
                            loading: provider.loading,
                          ),
                          builder: (context, data, _) {
                            return AuthGlassCard(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AuthTextField(
                                      controller: authProvider.emailCtrl,
                                      label: AppStrings.emailAddressLabel,
                                      hint: AppStrings.emailHint,
                                      icon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: Validators.validateEmail,
                                    ),
                                    const SizedBox(height: 16),
                                    AuthTextField(
                                      controller: authProvider.passwordCtrl,
                                      label: AppStrings.passwordLabel,
                                      hint: AppStrings.passwordHint,
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: data.hidePassword,
                                      validator: Validators.validatePassword,
                                      suffixIcon: AuthVisibilityToggle(
                                        isObscure: data.hidePassword,
                                        onTap: authProvider.togglePasswordVisibility,
                                      ),
                                    ),
                                    if (data.error != null) ...[
                                      const SizedBox(height: 16),
                                      AuthErrorBanner(
                                          message: data.error!),
                                    ],
                                    const SizedBox(height: 24),
                                    AppButton(
                                      label: AppStrings.signInButton,
                                      isLoading: data.loading,
                                      style: AppButtonStyle.primary,
                                      onPressed: () =>
                                          _submit(context, authProvider),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        AuthFooterLink(
                          question: AppStrings.dontHaveAccount,
                          actionLabel: AppStrings.createAccount,
                          onTap: () {
                            authProvider.resetForms();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, anim, __) =>
                                    RegisterScreen(),
                                transitionsBuilder: (_, anim, __, child) =>
                                    FadeTransition(
                                  opacity: anim,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.04, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOut,
                                    )),
                                    child: child,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthBranding extends StatelessWidget {
  const AuthBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: BrandTitle(fontSize: 38),
    );
  }
}
