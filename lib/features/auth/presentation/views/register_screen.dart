import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/utils/validators.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/auth/presentation/views/auth_widgets.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/shared_widgets/app_button.dart';
import 'package:social_media/core/utils/string_constants.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  Future<void> _submit(
      BuildContext context, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.register(
      email: authProvider.regEmailCtrl.text,
      password: authProvider.regPassCtrl.text,
      username: authProvider.regUserCtrl.text,
      displayName: authProvider.regNameCtrl.text,
    );

    if (success && context.mounted) {
      ToastService.showSuccess(
        context,
        '${AppStrings.welcomeUserPrefix}${authProvider.regNameCtrl.text}${AppStrings.welcomeUserSuffix}',
      );
      Navigator.of(context).pop();
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
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
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
                          top: -60,
                          left: -80,
                          child: AuthGlowOrb(
                            size: 280,
                            color: AppTheme.primaryNeon.withValues(
                              alpha: 0.15 + 0.08 * animValue,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -80,
                          right: -60,
                          child: AuthGlowOrb(
                            size: 300,
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
            top: size.height * 0.5,
            left: -30,
            child: AuthGlowOrb(
              size: 160,
              color: AppTheme.accentNeon.withValues(alpha: 0.07),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                            const SizedBox(height: 8),

                            const AuthHeader(
                              subtitle: AppStrings.registerHeaderSubtitle,
                            ),
                            const SizedBox(height: 32),

                            Selector<AuthProvider, ({bool regHidePassword, String? error, bool loading})>(
                              selector: (_, provider) => (
                                regHidePassword: provider.regHidePassword,
                                error: provider.error,
                                loading: provider.loading,
                              ),
                              builder: (context, data, _) {
                                return AuthGlassCard(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                gradient:
                                                    AppTheme.primaryGradient,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const AppText(
                                                AppStrings.createAccount,
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        AuthTextField(
                                          controller:
                                              authProvider.regNameCtrl,
                                          label: AppStrings.displayNameLabel,
                                          hint: AppStrings.displayNameHint,
                                          icon: Icons.badge_outlined,
                                          validator:
                                              Validators.validateDisplayName,
                                        ),
                                        const SizedBox(height: 14),
                                        AuthTextField(
                                          controller:
                                              authProvider.regUserCtrl,
                                          label: AppStrings.usernameLabel,
                                          hint: AppStrings.usernameHint,
                                          icon: Icons.alternate_email_rounded,
                                          validator: Validators.validateUsername,
                                        ),
                                        const SizedBox(height: 14),
                                        AuthTextField(
                                          controller:
                                              authProvider.regEmailCtrl,
                                          label: AppStrings.emailAddressLabel,
                                          hint: AppStrings.emailHint,
                                          icon: Icons.mail_outline_rounded,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: Validators.validateEmail,
                                        ),
                                        const SizedBox(height: 14),
                                        AuthTextField(
                                          controller:
                                              authProvider.regPassCtrl,
                                          label: AppStrings.passwordLabel,
                                          hint: AppStrings.passwordHint,
                                          icon: Icons.lock_outline_rounded,
                                          obscureText:
                                              data.regHidePassword,
                                          validator: Validators.validatePassword,
                                          suffixIcon: AuthVisibilityToggle(
                                            isObscure:
                                                data.regHidePassword,
                                            onTap: authProvider
                                                .toggleRegisterPasswordVisibility,
                                          ),
                                        ),

                                        if (data.error != null) ...[
                                          const SizedBox(height: 16),
                                          AuthErrorBanner(
                                              message:
                                                  data.error!),
                                        ],

                                        const SizedBox(height: 24),

                                        AppButton(
                                          label: AppStrings.signUpButton,
                                          isLoading: data.loading,
                                          style: AppButtonStyle.primary,
                                          onPressed: () =>
                                              _submit(context, authProvider),
                                        ),

                                        const SizedBox(height: 16),

                                        const AppText(
                                          AppStrings.authTermsMessage,
                                          textAlign: TextAlign.center,
                                          fontSize: 11.5,
                                          isSecondary: true,
                                          height: 1.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            AuthFooterLink(
                              question: AppStrings.alreadyHaveAccount,
                              actionLabel: AppStrings.signInButton,
                              onTap: () {
                                authProvider.resetForms();
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
