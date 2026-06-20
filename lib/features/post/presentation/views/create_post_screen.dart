import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/services/image_picker_service.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/post/presentation/providers/post_provider.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';
import 'package:social_media/core/utils/validators.dart';
import 'package:social_media/core/shared_widgets/user_avatar.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/shared_widgets/app_button.dart';
import 'package:social_media/core/utils/string_constants.dart';

class CreatePostScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  CreatePostScreen({super.key});

  Future<void> _pickImage(BuildContext context, PostProvider postProvider, ImageSource source) async {
    final image = await ImagePickerService.pickImage(source);
    if (image != null) {
      postProvider.setPickedImage(image);
    }
  }

  Future<void> _submit(BuildContext context, PostProvider postProvider, AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = authProvider.user;
    if (currentUser == null) return;

    dynamic filePayload;
    final selectedImage = postProvider.pickedImage;
    if (selectedImage != null) {
      filePayload = kIsWeb ? selectedImage.path : File(selectedImage.path);
    }

    final success = await postProvider.publishPost(
      authorId: currentUser.id,
      authorName: currentUser.displayName,
      authorPic: currentUser.profilePicUrl,
      content: postProvider.contentCtrl.text.trim(),
      imageFile: filePayload,
    );

    if (success && context.mounted) {
      ToastService.showSuccess(context, AppStrings.postPublishedSuccess);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isMobile = screenWidth < 650;

    return Selector<AuthProvider, UserEntity?>(
      selector: (_, provider) => provider.user,
      builder: (context, currentUser, _) {
        return Scaffold(
          backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
          appBar: AppBar(
            elevation: 0,
            title: const AppText(
              AppStrings.createPostTitle,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: AppButton(
                    label: AppStrings.sharePost,
                    height: 32,
                    width: 80,
                    fontSize: 13,
                    style: AppButtonStyle.primary,
                    isLoading: postProvider.working,
                    onPressed: () => _submit(context, postProvider, authProvider),
                  ),
                ),
              ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (postProvider.error != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D0E0E) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppText(
                                  postProvider.error!,
                                  color: isDark ? const Color(0xFFFF8080) : const Color(0xFF991B1B),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (currentUser != null)
                        Container(
                          decoration: isMobile
                              ? null
                              : AppTheme.glassCardDecoration(context),
                          padding: isMobile ? EdgeInsets.zero : const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  UserAvatar(
                                    imageUrl: currentUser.profilePicUrl,
                                    radius: 24,
                                    hasThinBorder: true,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          currentUser.displayName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        const SizedBox(height: 2),
                                        AppText.caption(
                                          '@${currentUser.username}',
                                          fontSize: 13,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: postProvider.contentCtrl,
                                maxLines: null,
                                minLines: 6,
                                textCapitalization: TextCapitalization.sentences,
                                validator: Validators.validatePostContent,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: isDark ? const Color(0xFFE8EFF8) : const Color(0xFF0F172A),
                                ),
                                decoration: InputDecoration(
                                  hintText: AppStrings.writePostPlaceholder,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ImagePreview(
                                image: postProvider.pickedImage,
                                onRemove: () => postProvider.setPickedImage(null),
                              ),
                              const SizedBox(height: 24),
                              Divider(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                height: 1,
                                thickness: 1,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  AppText.body(
                                    AppStrings.addToPost,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    isSecondary: true,
                                  ),
                                  const Spacer(),
                                  _MediaOptionButton(
                                    icon: Icons.photo_library_rounded,
                                    color: AppTheme.primaryNeon,
                                    onPressed: () => _pickImage(context, postProvider, ImageSource.gallery),
                                    tooltip: AppStrings.choosePhotoGallery,
                                  ),
                                  const SizedBox(width: 8),
                                  _MediaOptionButton(
                                    icon: Icons.camera_alt_rounded,
                                    color: AppTheme.secondaryNeon,
                                    onPressed: () => _pickImage(context, postProvider, ImageSource.camera),
                                    tooltip: AppStrings.takePhotoCamera,
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    height: 20,
                                    width: 1,
                                    color: isDark ? Colors.white24 : Colors.black12,
                                  ),
                                  const SizedBox(width: 12),
                                  ValueListenableBuilder<TextEditingValue>(
                                    valueListenable: postProvider.contentCtrl,
                                    builder: (context, value, child) {
                                      final count = value.text.length;
                                      return AppText(
                                        '$count/500',
                                        fontSize: 12,
                                        color: count > 450
                                            ? Colors.redAccent
                                            : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                        fontWeight: FontWeight.bold,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

class _MediaOptionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const _MediaOptionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePreview extends StatelessWidget {
  final XFile? image;
  final VoidCallback onRemove;

  const ImagePreview({
    super.key,
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          kIsWeb || image!.path.startsWith('blob:')
              ? Image.network(image!.path, fit: BoxFit.cover)
              : Image.file(File(image!.path), fit: BoxFit.cover),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
