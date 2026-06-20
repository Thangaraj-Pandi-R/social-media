import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/services/image_picker_service.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:social_media/core/shared_widgets/custom_text_field.dart';
import 'package:social_media/core/shared_widgets/user_avatar.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/utils/validators.dart';
import 'package:social_media/core/utils/string_constants.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';
import 'package:social_media/features/profile/presentation/providers/profile_provider.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickAvatar(ProfileProvider profileProvider) async {
    final image = await ImagePickerService.pickImage(ImageSource.gallery);
    if (image != null) {
      profileProvider.setPickedAvatar(image);
    }
  }

  Future<void> _save(BuildContext context, ProfileProvider profileProvider, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = authProvider.user?.id ?? '';
    final selectedImage = profileProvider.pickedAvatar;

    dynamic filePayload;
    if (selectedImage != null) {
      filePayload = kIsWeb ? selectedImage.path : File(selectedImage.path);
    }

    final success = await profileProvider.saveProfile(
      userId: userId,
      displayName: profileProvider.nameCtrl.text.trim(),
      bio: profileProvider.bioCtrl.text.trim(),
      file: filePayload,
    );

    if (success && context.mounted) {
      if (profileProvider.profile != null) {
        authProvider.updateCurrentUser(profileProvider.profile!);
      }

      ToastService.showSuccess(context, AppStrings.profileUpdatedSuccess);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isMobile = screenWidth < 650;

    return Selector<AuthProvider, UserEntity?>(
      selector: (_, provider) => provider.user,
      builder: (context, user, _) {
        Widget buildAvatarEditor() {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                      width: 3.0,
                    ),
                  ),
                  child: UserAvatar(
                    imageUrl: user?.profilePicUrl ?? '',
                    radius: 54,
                    localImage: profileProvider.pickedAvatar != null
                        ? (kIsWeb || profileProvider.pickedAvatar!.path.startsWith('blob:')
                            ? NetworkImage(profileProvider.pickedAvatar!.path)
                            : FileImage(File(profileProvider.pickedAvatar!.path)) as ImageProvider)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _pickAvatar(profileProvider),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryNeon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        Widget buildFormFields() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: profileProvider.nameCtrl,
                label: AppStrings.displayNameLabel,
                hint: AppStrings.displayNameHintText,
                prefixIcon: Icons.badge_outlined,
                validator: Validators.validateDisplayName,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: profileProvider.bioCtrl,
                label: AppStrings.bioLabel,
                hint: AppStrings.bioHint,
                prefixIcon: Icons.short_text_rounded,
                validator: Validators.validateBio,
                maxLines: 3,
              ),
            ],
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
          appBar: AppBar(
            elevation: 0,
            title: const AppText(AppStrings.editProfile, fontWeight: FontWeight.bold, fontSize: 18),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: TextButton(
                  onPressed: profileProvider.working ? null : () => _save(context, profileProvider, authProvider),
                  child: profileProvider.working
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.primaryNeon)),
                        )
                      : const AppText(
                          AppStrings.saveButton,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNeon,
                        ),
                ),
              )
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isMobile ? 600 : 800),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isMobile) ...[
                        buildAvatarEditor(),
                        const SizedBox(height: 32),
                        Container(
                          padding: EdgeInsets.zero,
                          child: buildFormFields(),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: AppTheme.glassCardDecoration(context),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    buildAvatarEditor(),
                                    const SizedBox(height: 20),
                                    const AppText.caption(
                                      'Tap the camera icon to upload a new profile picture.',
                                      textAlign: TextAlign.center,
                                      fontSize: 12,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 3,
                                child: buildFormFields(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (profileProvider.error != null) ...[
                        const SizedBox(height: 20),
                        AppText(
                          profileProvider.error!,
                          textAlign: TextAlign.center,
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
