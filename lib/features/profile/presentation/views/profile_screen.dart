import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/core/shared_widgets/custom_loader.dart';
import 'package:social_media/core/shared_widgets/empty_state.dart';
import 'package:social_media/core/shared_widgets/error_layout.dart';
import 'package:social_media/core/shared_widgets/user_avatar.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/shared_widgets/app_button.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/utils/string_constants.dart';
import 'package:social_media/core/services/toast_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';
import 'package:social_media/features/profile/presentation/providers/profile_provider.dart';
import 'package:social_media/features/profile/presentation/views/edit_profile_screen.dart';
import 'package:social_media/features/post/presentation/providers/post_provider.dart';
import 'package:social_media/features/post/presentation/views/widgets/post_card.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';

class HeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 60,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PostDetailScreen extends StatelessWidget {
  final PostEntity post;
  final UserEntity? currentUser;
  final bool showDeleteButton;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUser,
    required this.showDeleteButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Post', fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PostCard(
          post: post,
          currentUser: currentUser,
          showDeleteButton: showDeleteButton,
          heroTagSuffix: 'detail',
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _loadedUserId;
  bool _showAllVertical = false;
  UserEntity? _profile;
  bool _isLoading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoad();
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadedUserId = null;
      _checkAndLoad();
    }
  }

  void _checkAndLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (!isCurrent) return;

      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (_loadedUserId != widget.userId) {
        _loadedUserId = widget.userId;
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.user?.id ?? '';
        
        if (widget.userId == currentUserId) {
          setState(() {
            _profile = authProvider.user;
            _error = null;
            _isLoading = false;
          });
          postProvider.fetchUserPosts(widget.userId);
        } else {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          
          final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
          postProvider.fetchUserPosts(widget.userId);
          
          profileProvider.getUserProfileDirectly(widget.userId).then((profile) {
            if (mounted && _loadedUserId == widget.userId) {
              setState(() {
                _profile = profile;
                _error = null;
                _isLoading = false;
              });
            }
          }).catchError((error) {
            if (mounted && _loadedUserId == widget.userId) {
              setState(() {
                _error = error.toString();
                _isLoading = false;
              });
            }
          });
        }
      }
    });
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1420) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.035),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 20),
                const AppText(
                  AppStrings.logoutConfirmTitle,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const AppText(
                  AppStrings.logoutConfirmMessage,
                  fontSize: 14,
                  isSecondary: true,
                  textAlign: TextAlign.center,
                  height: 1.4,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: AppStrings.cancel,
                        style: AppButtonStyle.secondary,
                        height: 42,
                        borderRadius: 20,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: AppStrings.logout,
                        style: AppButtonStyle.danger,
                        height: 42,
                        borderRadius: 20,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await authProvider.logout();
    }
  }

  void _showUsersList(BuildContext context, String title, List<String> ids) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 600),
      builder: (_) => UsersListSheet(title: title, userIds: ids),
    );
  }

  Widget _buildWorkCard(BuildContext context, PostEntity post, UserEntity? currentUser, bool isDark, bool isSelf) {
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;

    Widget childContent;
    if (hasImage) {
      childContent = CachedNetworkImage(
        imageUrl: post.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
          child: const Icon(Icons.error_outline_rounded, size: 20),
        ),
      );
    } else {
      childContent = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E1B4B), const Color(0xFF31102F)]
                : [const Color(0xFFFEE2E2), const Color(0xFFFFFEDD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: AppText(
          post.content,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          maxLines: 6,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          color: isDark ? Colors.white : const Color(0xFF991B1B),
        ),
      );
    }

    String contentTitle = '';
    final trimmed = post.content.trim();
    if (trimmed.isNotEmpty) {
      final words = trimmed.split(RegExp(r'\s+'));
      contentTitle = words.take(2).join(' ');
      if (words.length > 2) contentTitle += '...';
    } else {
      contentTitle = 'Post';
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(
              post: post,
              currentUser: currentUser,
              showDeleteButton: isSelf,
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            childContent,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 90,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    contentTitle,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 11),
                      const SizedBox(width: 3),
                      Text(
                        '${post.likes.length}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chat_bubble_rounded, color: Colors.white70, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        '${post.commentCount}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBySideActions(
    BuildContext context,
    UserEntity user,
    bool isSelf,
    String currentUserId,
    Color roseAccent,
  ) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isFollowing = user.followers.contains(currentUserId);

    if (isSelf) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: AppButton(
          label: 'EDIT PROFILE',
          style: AppButtonStyle.primary,
          height: 38,
          borderRadius: 19,
          fontSize: 13.5,
          onPressed: () {
            profileProvider.initEditForm(authProvider.user);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditProfileScreen()),
            );
          },
        ),
      );
    }

    final solidButton = AppButton(
      label: isFollowing ? 'UNFOLLOW' : 'FOLLOW',
      style: isFollowing ? AppButtonStyle.secondary : AppButtonStyle.primary,
      height: 38,
      borderRadius: 19,
      fontSize: 13.5,
      onPressed: () => profileProvider.changeFollowState(
        currentUserId: currentUserId,
        targetUserId: user.id,
      ).then((_) {
        final updatedFollowing = List<String>.from(authProvider.user!.following);
        if (isFollowing) {
          updatedFollowing.remove(user.id);
        } else {
          updatedFollowing.add(user.id);
        }
        authProvider.updateCurrentUser(
          authProvider.user!.copyWith(following: updatedFollowing),
        );
        if (!isSelf && mounted) {
          setState(() {
            final updatedFollowers = List<String>.from(_profile!.followers);
            if (isFollowing) {
              updatedFollowers.remove(currentUserId);
            } else {
              updatedFollowers.add(currentUserId);
            }
            _profile = _profile!.copyWith(followers: updatedFollowers);
          });
        }
      }),
    );

    final outlineButton = AppButton(
      label: 'MESSAGE',
      style: AppButtonStyle.outline,
      height: 38,
      borderRadius: 19,
      fontSize: 13.5,
      onPressed: () {
        ToastService.showInfo(context, 'Messaging ${user.displayName} is coming soon!');
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        children: [
          Expanded(
            child: solidButton,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: outlineButton,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int postsCount, UserEntity user, Color roseAccent) {
    Widget statItem({
      required String value,
      required String label,
      VoidCallback? onTap,
    }) {
      final child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            value,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          AppText.caption(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ],
      );

      if (onTap != null) {
        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: child,
        );
      }
      return child;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: statItem(
              value: postsCount.toString(),
              label: 'PHOTOS',
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: roseAccent.withValues(alpha: 0.25),
          ),
          Expanded(
            child: statItem(
              value: user.followers.length.toString(),
              label: 'FOLLOWERS',
              onTap: () => _showUsersList(context, AppStrings.statsFollowers, user.followers),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: roseAccent.withValues(alpha: 0.25),
          ),
          Expanded(
            child: statItem(
              value: user.following.length.toString(),
              label: 'FOLLOWING',
              onTap: () => _showUsersList(context, AppStrings.statsFollowing, user.following),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalListView(List<PostEntity> posts, UserEntity? currentUser, bool isDark, bool isSelf) {
    if (posts.isEmpty) {
      return Container(
        height: 240,
        alignment: Alignment.center,
        child: const EmptyState(
          title: AppStrings.noPostsYetTitle,
          message: AppStrings.noPostsYetMessage,
          icon: Icons.border_color_rounded,
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildWorkCard(context, posts[index], currentUser, isDark, isSelf);
        },
      ),
    );
  }

  Widget _buildVerticalListView(List<PostEntity> posts, UserEntity? currentUser, bool isSelf) {
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: EmptyState(
          title: AppStrings.noPostsYetTitle,
          message: AppStrings.noPostsYetMessage,
          icon: Icons.border_color_rounded,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: posts[index],
          currentUser: currentUser,
          showDeleteButton: isSelf,
          heroTagSuffix: 'profile',
        );
      },
    );
  }

  Widget _buildErrorPlaceholder(PostProvider postProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 32,
          ),
          const SizedBox(height: 12),
          AppText(
            postProvider.errorMessage!,
            textAlign: TextAlign.center,
            fontSize: 14,
          ),
          const SizedBox(height: 16),
          Center(
            child: AppButton(
              label: AppStrings.tryAgain,
              width: 120,
              height: 36,
              fontSize: 13,
              style: AppButtonStyle.secondary,
              onPressed: () => postProvider.loadUserPosts(widget.userId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaGrid(BuildContext context, String username, bool isDark) {
    final roseAccent = const Color(0xFFE11D48);

    Widget socialCard({
      required IconData icon,
      required String prefix,
      required String handle,
      required String url,
    }) {
      return GestureDetector(
        onTap: () {
          ToastService.showInfo(context, 'Opening $url...');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF101625) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: roseAccent.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$prefix$handle',
                  style: TextStyle(
                     color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.share_rounded, color: roseAccent, size: 16),
              const SizedBox(width: 8),
              AppText(
                'Social media',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: roseAccent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.2,
            children: [
              socialCard(
                icon: Icons.camera_alt_rounded,
                prefix: '@',
                handle: username,
                url: 'instagram.com/$username',
              ),
              socialCard(
                icon: Icons.alternate_email_rounded,
                prefix: '@',
                handle: username,
                url: 'twitter.com/$username',
              ),
              socialCard(
                icon: Icons.facebook_rounded,
                prefix: '/',
                handle: username,
                url: 'facebook.com/$username',
              ),
              socialCard(
                icon: Icons.language_rounded,
                prefix: 'github.com/',
                handle: username,
                url: 'github.com/$username',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _checkAndLoad();
    final postProvider = Provider.of<PostProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Selector<AuthProvider, UserEntity?>(
      selector: (_, provider) => provider.user,
      builder: (context, currentUser, _) {
        final currentUserId = currentUser?.id ?? '';
        final isSelf = widget.userId == currentUserId;

        final profileData = isSelf ? currentUser : _profile;

        final showLoading = _error == null && (profileData == null || (_isLoading && !isSelf));

        if (showLoading) {
          return const Scaffold(
            body: CustomLoader(),
          );
        }

        if (_error != null) {
          return Scaffold(
            body: ErrorLayout(
              message: _error!,
              onRetry: () {
                _loadedUserId = null;
                _checkAndLoad();
              },
            ),
          );
        }

        final user = profileData!;
        final posts = postProvider.getUserPostsFor(widget.userId);
        final roseAccent = const Color(0xFFE11D48);

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (isSelf) {
                final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                await profileProvider.fetchUserProfile(widget.userId);
                if (profileProvider.profile != null) {
                  authProvider.updateCurrentUser(profileProvider.profile!);
                  if (mounted) {
                    setState(() {
                      _profile = authProvider.user;
                    });
                  }
                }
              } else {
                final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                final freshProfile = await profileProvider.getUserProfileDirectly(widget.userId);
                if (mounted) {
                  setState(() {
                    _profile = freshProfile;
                  });
                }
              }
              await postProvider.fetchUserPosts(widget.userId);
            },
            color: roseAccent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      ClipPath(
                        clipper: HeaderCurveClipper(),
                        child: Container(
                          height: 230,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFFD54F),
                                Color(0xFFFC8181),
                                Color(0xFFE11D48),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Navigator.of(context).canPop()
                                  ? Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                                        onPressed: () => Navigator.of(context).pop(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    )
                                  : const SizedBox(width: 38),
                              const AppText(
                                'PROFILE',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                              const SizedBox(width: 38),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppTheme.darkBg : Colors.white,
                              width: 4.5,
                            ),
                          ),
                          child: UserAvatar(
                            imageUrl: user.profilePicUrl,
                            radius: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Builder(
                    builder: (context) {
                      final bioLines = user.bio.split('\n');
                      final hasMultipleBioLines = bioLines.length > 1;
                      final tagline = user.bio.isNotEmpty ? bioLines[0] : "Creative Developer";
                      final bioBody = hasMultipleBioLines ? bioLines.skip(1).join('\n') : "";

                      return Column(
                        children: [
                          AppText(
                            user.displayName,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: roseAccent,
                            letterSpacing: 0.1,
                          ),
                          const SizedBox(height: 4),
                          AppText(
                            tagline,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black45,
                            letterSpacing: 0.2,
                          ),
                          if (bioBody.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40.0),
                              child: AppText.body(
                                bioBody,
                                textAlign: TextAlign.center,
                                fontSize: 14,
                                height: 1.45,
                                isSecondary: true,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildSideBySideActions(context, user, isSelf, currentUserId, roseAccent),
                  
                  const SizedBox(height: 28),
                  
                  _buildStatsRow(posts.length, user, roseAccent),
                  
                  const SizedBox(height: 28),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          _showAllVertical ? 'Publications' : 'My works',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: roseAccent,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showAllVertical = !_showAllVertical;
                            });
                          },
                          child: AppText(
                            _showAllVertical ? 'View Horizontal' : 'View all',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.accentNeon : AppTheme.secondaryNeon,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  postProvider.loadingUserPosts
                      ? const CustomLoader()
                      : postProvider.error != null
                          ? _buildErrorPlaceholder(postProvider)
                          : _showAllVertical
                              ? _buildVerticalListView(posts, currentUser, isSelf)
                              : _buildHorizontalListView(posts, currentUser, isDark, isSelf),
                  
                  const SizedBox(height: 28),
                  
                  _buildSocialMediaGrid(context, user.username, isDark),
                  
                  if (isSelf) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: AppButton(
                        label: 'LOG OUT',
                        style: AppButtonStyle.outline,
                        height: 40,
                        width: 220,
                        borderRadius: 20,
                        icon: Icons.logout_rounded,
                        onPressed: () => _logout(context, Provider.of<AuthProvider>(context, listen: false)),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class UsersListSheet extends StatelessWidget {
  final String title;
  final List<String> userIds;

  const UsersListSheet({
    super.key,
    required this.title,
    required this.userIds,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                    AppText(
                      title,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    AppText.body(
                      '${userIds.length}${AppStrings.usersSuffix}',
                      fontSize: 13,
                      isSecondary: true,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: userIds.isEmpty
                    ? const EmptyState(
                        title: AppStrings.searchNoResultsTitle,
                        message: AppStrings.noUsersFoundMessage,
                        icon: Icons.people_outline_rounded,
                      )
                    : ListView.separated(
                        controller: scrollableController,
                        padding: const EdgeInsets.all(16),
                        itemCount: userIds.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return UserListTile(userId: userIds[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserListTile extends StatelessWidget {
  final String userId;

  const UserListTile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    return FutureBuilder<UserEntity>(
      future: profileProvider.getUserProfileDirectly(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            title: AppText(AppStrings.loading, fontSize: 13),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data!;
        return RepaintBoundary(
          child: Container(
            decoration: AppTheme.glassCardDecoration(context),
            child: ListTile(
              leading: UserAvatar(
                imageUrl: user.profilePicUrl,
                radius: 20,
              ),
              title: AppText(
                user.displayName,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              subtitle: AppText.caption(
                '@${user.username}',
                fontSize: 12,
              ),
              onTap: () {
                Navigator.of(context).pop();
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
    );
  }
}
