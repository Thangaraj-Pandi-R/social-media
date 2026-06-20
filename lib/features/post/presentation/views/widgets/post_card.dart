import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/services/share_service.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:social_media/core/utils/datetime_utils.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';
import 'package:social_media/features/post/presentation/providers/post_provider.dart';
import 'package:social_media/features/comment/presentation/providers/comment_provider.dart';
import 'package:social_media/features/comment/presentation/views/widgets/comments_sheet.dart';
import 'package:social_media/features/profile/presentation/views/profile_screen.dart';
import 'package:social_media/features/profile/presentation/providers/profile_provider.dart';
import 'package:social_media/core/shared_widgets/full_screen_image_viewer.dart';
import 'package:social_media/core/shared_widgets/user_avatar.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/shared_widgets/app_button.dart';
import 'package:social_media/core/utils/string_constants.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final UserEntity? currentUser;
  final bool showDeleteButton;
  final String? heroTagSuffix;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUser,
    this.showDeleteButton = false,
    this.heroTagSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    PostEntity activePost = this.post;
    final feedIndex = postProvider.posts.indexWhere((p) => p.id == this.post.id);
    if (feedIndex != -1) {
      activePost = postProvider.posts[feedIndex];
    } else {
      final userPosts = postProvider.getUserPostsFor(this.post.authorId);
      final userIndex = userPosts.indexWhere((p) => p.id == this.post.id);
      if (userIndex != -1) {
        activePost = userPosts[userIndex];
      }
    }
    final post = activePost;

    final currentUserId = currentUser?.id ?? '';
    final isLiked = post.likes.contains(currentUserId);
    final isOwner = post.authorId == currentUserId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: AppTheme.glassCardDecoration(context),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PostHeader(
              post: post,
              currentUser: currentUser,
              isOwner: isOwner && showDeleteButton,
              isDark: isDark,
              onEdit: () => _openEditPost(context, post),
              onDelete: () => _confirmDelete(context, postProvider),
            ),
    
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ExpandablePostText(
                text: post.content,
                isDark: isDark,
              ),
            ),
    
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              PostImage(
                path: post.imageUrl!,
                postId: post.id,
                heroTagSuffix: heroTagSuffix,
              ),
            ],
    
            PostActions(
              post: post,
              isLiked: isLiked,
              isDark: isDark,
              onLike: () {
                postProvider.toggleLike(
                  postId: post.id,
                  userId: currentUserId,
                ).catchError((error) {
                  if (!context.mounted) return;
                  ToastService.showError(
                    context,
                    error.toString().contains('connection')
                        ? AppStrings.noInternetConnectionShort
                        : '${AppStrings.failedToUpdateLike}${error.toString()}',
                  );
                });
              },
              onComment: () => _openComments(context),
              onShare: () {
                ShareService.sharePost(
                  authorName: post.authorName,
                  content: post.content,
                  imageUrl: post.imageUrl,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openComments(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    commentProvider.clearCommentsForPost(post.id);
    commentProvider.loadComments(post.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) => CommentsSheet(postId: post.id),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PostProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AppText(AppStrings.deletePostTitle, fontWeight: FontWeight.bold),
        content: const AppText(AppStrings.deletePostMessage),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: AppStrings.cancel,
                  style: AppButtonStyle.secondary,
                  height: 40,
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: AppStrings.delete,
                  style: AppButtonStyle.danger,
                  height: 40,
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await provider.removePost(post.id);
      if (success && context.mounted) {
        if (heroTagSuffix == 'detail') {
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _openEditPost(BuildContext context, PostEntity currentPost) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final textController = TextEditingController(text: currentPost.content);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBg : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Edit Post',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: AppTheme.glassCardDecoration(ctx),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: textController,
                    maxLines: 6,
                    minLines: 2,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? const Color(0xFFE8EFF8) : const Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Edit your post content...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'SAVE CHANGES',
                  style: AppButtonStyle.primary,
                  onPressed: () async {
                    final newContent = textController.text.trim();
                    if (newContent.isEmpty) return;
                    Navigator.of(ctx).pop();

                    final success = await postProvider.updatePost(post.id, newContent);
                    if (success && context.mounted) {
                      ToastService.showSuccess(context, 'Post updated successfully');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PostHeader extends StatelessWidget {
  final PostEntity post;
  final UserEntity? currentUser;
  final bool isOwner;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const PostHeader({
    super.key,
    required this.post,
    required this.currentUser,
    required this.isOwner,
    required this.isDark,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    final user = currentUser;
    final isFollowing = user?.following.contains(post.authorId) ?? false;
    final isSelf = user != null && post.authorId == user.id;
    final showFollowButton = user != null && !isSelf && !isFollowing;

    final formattedTime = DateTimeUtils.formatDateTime(post.createdAt);

    void handleFollow() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id ?? '';
      profileProvider.changeFollowState(
        currentUserId: currentUserId,
        targetUserId: post.authorId,
        isFollowingOverride: false,
      ).then((_) {
        final updatedFollowing = List<String>.from(authProvider.user!.following);
        if (!updatedFollowing.contains(post.authorId)) {
          updatedFollowing.add(post.authorId);
        }
        authProvider.updateCurrentUser(
          authProvider.user!.copyWith(following: updatedFollowing),
        );
        if (!context.mounted) return;
        ToastService.showSuccess(context, '${AppStrings.followingUserPrefix}${post.authorName}');
      }).catchError((error) {
        if (!context.mounted) return;
        ToastService.showError(
          context,
          error.toString().contains('connection')
              ? AppStrings.noInternetConnectionShort
              : AppStrings.failedToFollowUser,
        );
      });
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 14.0, top: 14.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(
            imageUrl: post.authorPic,
            radius: 20,
            hasPlainBorder: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(userId: post.authorId),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(userId: post.authorId),
                            ),
                          );
                        },
                        child: AppText(
                          post.authorName,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          overflow: TextOverflow.ellipsis,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    if (showFollowButton) ...[
                      const SizedBox(width: 6),
                      const AppText(
                        '•',
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: handleFollow,
                        child: const AppText(
                          AppStrings.follow,
                          color: AppTheme.primaryNeon,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                AppText(
                  formattedTime,
                  fontSize: 11.5,
                  isSecondary: true,
                  letterSpacing: 0.1,
                ),
              ],
            ),
          ),
          if (isOwner) ...[
            if (onEdit != null) ...[
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryNeon, size: 20),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
              ),
              const SizedBox(width: 12),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }
}

class PostActions extends StatelessWidget {
  final PostEntity post;
  final bool isLiked;
  final bool isDark;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostActions({
    super.key,
    required this.post,
    required this.isLiked,
    required this.isDark,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final activeIconColor = isLiked ? AppTheme.accentNeon : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));
    final inactiveIconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final countColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: isLiked ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: activeIconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      '${post.likes.length}',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: countColor,
                      letterSpacing: 0.1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              GestureDetector(
                onTap: onComment,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: inactiveIconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    AppText(
                      '${post.commentCount}',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: countColor,
                      letterSpacing: 0.1,
                    ),
                  ],
                ),
              ),
            ],
          ),

          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.share_outlined,
              color: inactiveIconColor,
              size: 20,
            ),
            splashRadius: 20,
            onPressed: onShare,
          ),
        ],
      ),
    );
  }
}

class ExpandablePostText extends StatelessWidget {
  final String text;
  final bool isDark;

  const ExpandablePostText({super.key, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final threshold = 120;
    final shouldTruncate = text.length > threshold;
    final isExpanded = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (context, expanded, child) {
        final textColor = isDark ? AppTheme.textDarkPrimary : AppTheme.textLightPrimary;
        if (!shouldTruncate || expanded) {
          return AppText.body(
            text,
            fontSize: 14.5,
            height: 1.45,
            letterSpacing: 0.1,
          );
        }

        final truncatedText = '${text.substring(0, threshold)}... ';
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: truncatedText,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: textColor,
                  letterSpacing: 0.1,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () => isExpanded.value = true,
                  child: const AppText(
                    'more',
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNeon,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PostImage extends StatelessWidget {
  final String path;
  final String postId;
  final String? heroTagSuffix;
  const PostImage({
    super.key,
    required this.path,
    required this.postId,
    this.heroTagSuffix,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = heroTagSuffix != null ? '${postId}_image_$heroTagSuffix' : '${postId}_image';
    final imageWidget = (path.startsWith('http') || path.startsWith('blob:') || kIsWeb)
        ? CachedNetworkImage(
            imageUrl: path,
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.black.withValues(alpha: 0.05),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => const SizedBox.shrink(),
          )
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenImageViewer(imageUrl: path, heroTag: heroTag),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 460,
            minHeight: 200,
          ),
          child: Hero(
            tag: heroTag,
            child: imageWidget,
          ),
        ),
      ),
    );
  }
}
