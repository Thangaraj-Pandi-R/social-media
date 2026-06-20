import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/shared_widgets/custom_loader.dart';
import 'package:social_media/core/shared_widgets/empty_state.dart';
import 'package:social_media/core/shared_widgets/user_avatar.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/utils/string_constants.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:social_media/core/utils/datetime_utils.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/comment/presentation/providers/comment_provider.dart';
import 'package:social_media/features/post/presentation/providers/post_provider.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class CommentsSheet extends StatelessWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  Future<void> _submitComment(BuildContext context, CommentProvider commentProvider, AuthProvider authProvider) async {
    final text = commentProvider.commentCtrl.text.trim();
    if (text.isEmpty) return;

    final user = authProvider.user;
    if (user == null) return;

    FocusScope.of(context).unfocus();

    final success = await commentProvider.addComment(
      postId: postId,
      authorId: user.id,
      authorName: user.displayName,
      authorPic: user.profilePicUrl,
      content: text,
    );

    if (success) {
      if (context.mounted) {
        Provider.of<PostProvider>(context, listen: false).updatePostCommentCount(postId, 1);
      }
    } else {
      if (context.mounted) {
        ToastService.showError(context, commentProvider.error ?? AppStrings.failedToAddComment);
      }
    }
  }

  Future<void> _deleteComment(BuildContext context, CommentProvider commentProvider, String commentId) async {
    final success = await commentProvider.deleteComment(
      postId: postId,
      commentId: commentId,
    );

    if (success) {
      if (context.mounted) {
        Provider.of<PostProvider>(context, listen: false).updatePostCommentCount(postId, -1);
      }
    } else {
      if (context.mounted) {
        ToastService.showError(context, commentProvider.error ?? AppStrings.failedToDeleteComment);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final comments = commentProvider.getCommentsForPost(postId);

    return Selector<AuthProvider, UserEntity?>(
      selector: (_, provider) => provider.user,
      builder: (context, currentUser, _) {
        final currentUserId = currentUser?.id ?? '';
        final profilePicUrl = currentUser?.profilePicUrl ?? '';
        final authProviderNonListening = Provider.of<AuthProvider>(context, listen: false);

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollableController) {
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppText(
                          AppStrings.commentsTitle,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        AppText.body(
                          '${comments.length}${AppStrings.commentsCountSuffix}',
                          fontSize: 13,
                          isSecondary: true,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Expanded(
                    child: commentProvider.loading
                        ? const Center(child: CustomLoader())
                        : commentProvider.error != null
                            ? EmptyState(
                                title: AppStrings.failedToLoadComments,
                                message: commentProvider.error!,
                                icon: Icons.error_outline_rounded,
                              )
                            : comments.isEmpty
                                ? const EmptyState(
                                    title: AppStrings.commentsEmptyTitle,
                                    message: AppStrings.commentsEmptyMessage,
                                    icon: Icons.chat_bubble_outline_rounded,
                                  )
                                : ListView.separated(
                                controller: scrollableController,
                                padding: const EdgeInsets.all(16),
                                itemCount: comments.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  final isCommentOwner = comment.authorId == currentUserId;
                                  
                                  final time = DateTimeUtils.formatDateTime(comment.createdAt);

                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      UserAvatar(
                                        imageUrl: comment.authorPic,
                                        radius: 16,
                                        hasPlainBorder: true,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                AppText(
                                                  comment.authorName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  letterSpacing: 0.1,
                                                ),
                                                if (isCommentOwner) ...[
                                                  const SizedBox(width: 4),
                                                  const AppText(
                                                    AppStrings.youCommentBadge,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.primaryNeon,
                                                  ),
                                                ],
                                                const SizedBox(width: 8),
                                                AppText.caption(
                                                  time,
                                                  fontSize: 10.5,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? (isCommentOwner ? AppTheme.primaryNeon.withValues(alpha: 0.12) : const Color(0xFF1E293B).withValues(alpha: 0.4))
                                                    : (isCommentOwner ? AppTheme.primaryNeon.withValues(alpha: 0.08) : const Color(0xFFF1F5F9)),
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.zero,
                                                  topRight: Radius.circular(16),
                                                  bottomLeft: Radius.circular(16),
                                                  bottomRight: Radius.circular(16),
                                                ),
                                                border: Border.all(
                                                  color: isDark
                                                      ? (isCommentOwner ? AppTheme.primaryNeon.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04))
                                                      : (isCommentOwner ? AppTheme.primaryNeon.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02)),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: AppText.body(
                                                comment.content,
                                                fontSize: 13.5,
                                                height: 1.35,
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isCommentOwner)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                          splashRadius: 18,
                                          onPressed: () => _deleteComment(context, commentProvider, comment.id),
                                        )
                                    ],
                                  );
                                },
                              ),
                  ),

                  const Divider(height: 1),

                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                        top: 8,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          UserAvatar(
                            imageUrl: profilePicUrl,
                            radius: 16,
                            hasPlainBorder: true,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: commentProvider.commentCtrl,
                              textCapitalization: TextCapitalization.sentences,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: AppStrings.writeCommentPlaceholder,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                                    width: 0.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(color: AppTheme.primaryNeon, width: 1.0),
                                ),
                                fillColor: isDark ? const Color(0xFF0F1420) : const Color(0xFFF1F5F9),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          commentProvider.adding
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.send_rounded, color: AppTheme.primaryNeon),
                                  onPressed: () => _submitComment(context, commentProvider, authProviderNonListening),
                                ),
                        ],
                      ),
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
