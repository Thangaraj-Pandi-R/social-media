import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/app_config.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/utils/constants.dart';
import 'package:social_media/core/services/connectivity_provider.dart';
import 'package:social_media/core/shared_widgets/brand_title.dart';
import 'package:social_media/core/shared_widgets/app_text.dart';
import 'package:social_media/core/utils/string_constants.dart';

import 'package:social_media/features/auth/domain/usecases/login_usecase.dart';
import 'package:social_media/features/auth/domain/usecases/register_usecase.dart';
import 'package:social_media/features/auth/domain/usecases/logout_usecase.dart';
import 'package:social_media/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:social_media/features/auth/presentation/providers/auth_provider.dart';

import 'package:social_media/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/follow_user_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/search_users_usecase.dart';
import 'package:social_media/features/profile/presentation/providers/profile_provider.dart';

import 'package:social_media/features/post/domain/usecases/create_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/edit_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/like_post_usecase.dart';
import 'package:social_media/features/post/domain/usecases/get_feed_posts_usecase.dart';
import 'package:social_media/features/post/domain/usecases/get_user_posts_usecase.dart';
import 'package:social_media/features/post/presentation/providers/post_provider.dart';

import 'package:social_media/features/comment/domain/usecases/get_comments_usecase.dart';
import 'package:social_media/features/comment/domain/usecases/add_comment_usecase.dart';
import 'package:social_media/features/comment/domain/usecases/delete_comment_usecase.dart';
import 'package:social_media/features/comment/presentation/providers/comment_provider.dart';

import 'package:social_media/features/auth/presentation/views/login_screen.dart';
import 'package:social_media/features/feed/presentation/views/main_navigation_layout.dart';

void main() async {
  await AppConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AppConfig.authRepository;
    final profileRepo = AppConfig.profileRepository;
    final postRepo = AppConfig.postRepository;
    final commentRepo = AppConfig.commentRepository;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityProvider>(
          lazy: true,
          create: (_) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          lazy: true,
          create: (_) => AuthProvider(
            loginUseCase: LoginUseCase(authRepo),
            registerUseCase: RegisterUseCase(authRepo),
            logoutUseCase: LogoutUseCase(authRepo),
            getCurrentUserUseCase: GetCurrentUserUseCase(authRepo),
            authRepository: authRepo,
          ),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          lazy: true,
          create: (_) => ProfileProvider(
            getUserProfileUseCase: GetUserProfileUseCase(profileRepo),
            updateProfileUseCase: UpdateProfileUseCase(profileRepo),
            followUserUseCase: FollowUserUseCase(profileRepo),
            unfollowUserUseCase: UnfollowUserUseCase(profileRepo),
            searchUsersUseCase: SearchUsersUseCase(profileRepo),
          ),
        ),
        ChangeNotifierProvider<PostProvider>(
          lazy: true,
          create: (_) => PostProvider(
            createPostUseCase: CreatePostUseCase(postRepo),
            editPostUseCase: EditPostUseCase(postRepo),
            deletePostUseCase: DeletePostUseCase(postRepo),
            likePostUseCase: LikePostUseCase(postRepo),
            getFeedPostsUseCase: GetFeedPostsUseCase(postRepo),
            getUserPostsUseCase: GetUserPostsUseCase(postRepo),
          ),
        ),
        ChangeNotifierProvider<CommentProvider>(
          lazy: true,
          create: (_) => CommentProvider(
            getCommentsUseCase: GetCommentsUseCase(commentRepo),
            addCommentUseCase: AddCommentUseCase(commentRepo),
            deleteCommentUseCase: DeleteCommentUseCase(commentRepo),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, ({bool starting, bool isAuthenticated})>(
      selector: (_, provider) => (
        starting: provider.starting,
        isAuthenticated: provider.isAuthenticated,
      ),
      builder: (context, data, _) {
        if (data.starting) {
          return const SplashScreen();
        }

        if (data.isAuthenticated) {
          return const MainNavigationLayout();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            const BrandTitle(fontSize: 40),
            const SizedBox(height: 10),
            const AppText(
              AppStrings.connectTagline,
              fontSize: 15,
              isSecondary: true,
              fontWeight: FontWeight.w500,
            ),
            const Spacer(flex: 2),
            const CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNeon),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
