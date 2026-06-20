import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/shared_widgets/custom_loader.dart';
import 'package:social_media/core/shared_widgets/empty_state.dart';
import 'package:social_media/core/shared_widgets/user_avatar.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/shared_widgets/app_button.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/utils/string_constants.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/profile/presentation/providers/profile_provider.dart';
import 'package:social_media/features/profile/presentation/views/profile_screen.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Selector<AuthProvider, UserEntity?>(
      selector: (_, provider) => provider.user,
      builder: (context, currentUser, _) {
        final currentUserId = currentUser?.id ?? '';
        final results = profileProvider.searchList;

        return Scaffold(
          appBar: AppBar(
            title: const AppText(
              AppStrings.discoverTitle,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.1,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(66),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 14.0),
                child: TextField(
                  controller: profileProvider.searchCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: AppStrings.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: profileProvider.searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: profileProvider.resetSearch,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F1420) : const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryNeon,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: profileProvider.searching
              ? const CustomLoader()
              : results.isEmpty
                  ? EmptyState(
                      title: profileProvider.searchCtrl.text.isEmpty
                          ? AppStrings.searchEmptyTitle
                          : AppStrings.searchNoResultsTitle,
                      message: profileProvider.searchCtrl.text.isEmpty
                          ? AppStrings.searchEmptyMessage
                          : '${AppStrings.searchNoResultsPrefix}${profileProvider.searchCtrl.text}${AppStrings.searchNoResultsSuffix}',
                      icon: Icons.person_search_rounded,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = results[index];
                        final isSelf = user.id == currentUserId;
                        
                        final isFollowing = currentUser?.following.contains(user.id) ?? false;

                        return RepaintBoundary(
                          child: Container(
                            decoration: AppTheme.glassCardDecoration(context),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: UserAvatar(
                                imageUrl: user.profilePicUrl,
                                radius: 20,
                                hasPlainBorder: true,
                              ),
                              title: AppText(
                                user.displayName,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                letterSpacing: 0.1,
                              ),
                              subtitle: AppText.caption(
                                '@${user.username}',
                                fontSize: 12,
                                letterSpacing: 0.1,
                              ),
                              trailing: isSelf
                                  ? null
                                  : AppButton(
                                      label: isFollowing ? AppStrings.followingLabel : AppStrings.follow,
                                      style: isFollowing ? AppButtonStyle.secondary : AppButtonStyle.primary,
                                      height: 32,
                                      width: 92,
                                      fontSize: 12,
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => ProfileScreen(userId: user.id),
                                          ),
                                        );
                                      },
                                    ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(userId: user.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
