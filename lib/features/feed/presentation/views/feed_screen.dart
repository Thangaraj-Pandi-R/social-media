import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/shared_widgets/custom_loader.dart';
import 'package:social_media/core/shared_widgets/empty_state.dart';
import 'package:social_media/core/shared_widgets/error_layout.dart';
import 'package:social_media/core/shared_widgets/brand_title.dart';
import 'package:social_media/core/shared_widgets/user_avatar.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/post/presentation/providers/post_provider.dart';
import 'package:social_media/features/post/presentation/views/widgets/post_card.dart';
import 'package:social_media/features/profile/presentation/views/profile_screen.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';
import 'package:social_media/core/utils/datetime_utils.dart';
import 'package:social_media/core/utils/string_constants.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  Future<void> _refresh(BuildContext context, String currentUserId) async {
    await Provider.of<PostProvider>(context, listen: false).fetchFeed(currentUserId, isRefresh: true);
    if (!context.mounted) return;
    await Provider.of<AuthProvider>(context, listen: false).getNotifications(currentUserId);
  }

  void _onNotificationPressed(BuildContext context, AuthProvider authProvider) {
    authProvider.readNotifications();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProviderNonListening = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final posts = postProvider.posts;

    return Selector<AuthProvider, ({UserEntity? user, bool unreadNotifs})>(
      selector: (_, provider) => (
        user: provider.user,
        unreadNotifs: provider.unreadNotifs,
      ),
      builder: (context, authData, _) {
        final currentUserId = authData.user?.id ?? '';
        final hasUnread = authData.unreadNotifs;
        final profilePicUrl = authData.user?.profilePicUrl ?? '';

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            centerTitle: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 8),
                const BrandTitle(),
              ],
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.035),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, size: 22),
                      tooltip: AppStrings.notificationsTitle,
                      onPressed: () => _onNotificationPressed(context, authProviderNonListening),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              UserAvatar(
                imageUrl: profilePicUrl,
                radius: 17,
                hasThinBorder: true,
                onTap: () => authProviderNonListening.changeNavIdx(2),
              ),
              const SizedBox(width: 20),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                height: 1,
              ),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => _refresh(context, currentUserId),
            color: Theme.of(context).colorScheme.primary,
            child: (postProvider.activeUid != currentUserId || (postProvider.loadingFeed && posts.isEmpty))
                ? const CustomLoader()
                : postProvider.error != null && posts.isEmpty
                    ? ErrorLayout(
                        message: postProvider.error!,
                        onRetry: () => _refresh(context, currentUserId),
                      )
                    : posts.isEmpty
                        ? const EmptyState(
                            title: AppStrings.feedEmptyTitle,
                            message: AppStrings.feedEmptyMessage,
                            icon: Icons.rss_feed_rounded,
                          )
                        : ListView.builder(
                            controller: postProvider.scrollCtrl,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                            itemCount: posts.length + (postProvider.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == posts.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: CustomLoader(size: 24),
                                );
                              }
                              return PostCard(
                                post: posts[index],
                                currentUser: authData.user,
                                heroTagSuffix: 'feed',
                              );
                            },
                          ),
          ),
        );
      },
    );
  }
}

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProviderNonListening = Provider.of<AuthProvider>(context, listen: false);

    return Selector<AuthProvider, ({
      List<NotificationItem> notifs,
      bool loadingNotifs,
      String? error,
      String currentUserId,
    })>(
      selector: (_, provider) => (
        notifs: provider.notifs,
        loadingNotifs: provider.loadingNotifs,
        error: provider.error,
        currentUserId: provider.user?.id ?? '',
      ),
      builder: (context, data, _) {
        final notifications = data.notifs;
        final isLoading = data.loadingNotifs;
        final error = data.error;
        final currentUserId = data.currentUserId;

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBg : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.heading(
                          AppStrings.notificationsTitle,
                          fontSize: 18,
                          letterSpacing: 0.1,
                        ),
                        if (!isLoading && notifications.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryNeon.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AppText(
                              '${notifications.length}${AppStrings.totalNotificationsSuffix}',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNeon,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 16, thickness: 0.5),

                  Expanded(
                    child: isLoading
                        ? const Center(child: CustomLoader())
                        : error != null && notifications.isEmpty
                            ? ErrorLayout(
                                message: error,
                                onRetry: () => authProviderNonListening.getNotifications(currentUserId),
                              )
                            : notifications.isEmpty
                                ? const EmptyState(
                                    title: AppStrings.notificationsEmptyTitle,
                                    message: AppStrings.notificationsEmptyMessage,
                                    icon: Icons.notifications_none_rounded,
                                  )
                                : ListView.builder(
                                    controller: scrollController,
                                    itemCount: notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification = notifications[index];
                                      final timeStr = DateTimeUtils.formatTimeAgo(notification.time);

                                      return ListTile(
                                        leading: UserAvatar(
                                          imageUrl: notification.authorPic,
                                          radius: 20,
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: AppText(
                                                notification.title,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            AppText.caption(
                                              timeStr,
                                              fontSize: 11,
                                            ),
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: AppText.body(
                                            notification.body,
                                            fontSize: 13,
                                            isSecondary: true,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ProfileScreen(userId: notification.targetId),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
