import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media/app_config.dart';
import 'package:social_media/core/theme/theme.dart';
import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_media/features/auth/domain/usecases/login_usecase.dart';
import 'package:social_media/features/auth/domain/usecases/register_usecase.dart';
import 'package:social_media/features/auth/domain/usecases/logout_usecase.dart';
import 'package:social_media/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

part 'auth_provider_mixin.dart';

class NotificationItem {
  final String title;
  final String body;
  final DateTime time;
  final IconData icon;
  final Color color;
  final String authorPic;
  final String targetId;
  final String type;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    required this.authorPic,
    required this.targetId,
    required this.type,
  });
}

class AuthProvider extends ChangeNotifier with AuthProviderMixin {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _authRepository;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _authRepository = authRepository {
    _init();
  }

  void _init() {
    _authSub = _authRepository.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        getNotifications(user.id);
      } else {
        _notifs = [];
        _unreadNotifs = false;
      }
      notifyListeners();
    });

    _getCurrentUserUseCase(const NoParams()).then((user) {
      _user = user;
      _starting = false;
      if (user != null) {
        getNotifications(user.id);
      }
      notifyListeners();
    }).catchError((_) {
      _starting = false;
      notifyListeners();
    });
  }

  Future<void> getNotifications(String userId) async {
    _loadingNotifs = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTimeIso = prefs.getString('last_read_notifications_time_$userId');
      if (savedTimeIso != null) {
        _lastReadAt = DateTime.parse(savedTimeIso);
      } else {
        _lastReadAt = null;
      }

      _notifs = await getNotificationsList(userId);
      if (_notifs.isNotEmpty) {
        final newestTime = _notifs.first.time;
        if (_lastReadAt == null || newestTime.isAfter(_lastReadAt!)) {
          _unreadNotifs = true;
        } else {
          _unreadNotifs = false;
        }
      } else {
        _unreadNotifs = false;
      }
    } catch (_) {
    } finally {
      _loadingNotifs = false;
      notifyListeners();
    }
  }

  Future<void> loadNotifications(String userId) => getNotifications(userId);

  Future<List<NotificationItem>> getNotificationsList(String currentUserId) async {
    final profileRepo = AppConfig.profileRepository;
    final postRepo = AppConfig.postRepository;
    final commentRepo = AppConfig.commentRepository;

    final List<NotificationItem> list = [];

    try {
      final profile = await profileRepo.getUserProfile(currentUserId);
      for (final followerId in profile.followers) {
        if (followerId == currentUserId) continue;
        try {
          final follower = await profileRepo.getUserProfile(followerId);
          list.add(NotificationItem(
            title: follower.displayName,
            body: 'started following you',
            time: profile.createdAt.add(const Duration(minutes: 30)),
            icon: Icons.person_add_rounded,
            color: AppTheme.primaryNeon,
            authorPic: follower.profilePicUrl,
            targetId: follower.id,
            type: 'follow',
          ));
        } catch (_) {}
      }
    } catch (_) {}

    try {
      final posts = await postRepo.getUserPosts(currentUserId);
      for (final post in posts) {
        for (final likerId in post.likes) {
          if (likerId == currentUserId) continue;
          try {
            final liker = await profileRepo.getUserProfile(likerId);
            list.add(NotificationItem(
              title: liker.displayName,
              body: 'liked your post: "${post.content.length > 25 ? '${post.content.substring(0, 25)}...' : post.content}"',
              time: post.createdAt.add(const Duration(hours: 2)),
              icon: Icons.favorite_rounded,
              color: AppTheme.accentNeon,
              authorPic: liker.profilePicUrl,
              targetId: liker.id,
              type: 'like',
            ));
          } catch (_) {}
        }

        try {
          final comments = await commentRepo.getComments(post.id);
          for (final comment in comments) {
            if (comment.authorId == currentUserId) continue;
            list.add(NotificationItem(
              title: comment.authorName,
              body: 'commented: "${comment.content.length > 25 ? '${comment.content.substring(0, 25)}...' : comment.content}"',
              time: comment.createdAt,
              icon: Icons.comment_rounded,
              color: AppTheme.secondaryNeon,
              authorPic: comment.authorPic,
              targetId: comment.authorId,
              type: 'comment',
            ));
          }
        } catch (_) {}
      }
    } catch (_) {}

    final sortedList = await compute(_sortNotifications, list);
    return sortedList;
  }

  Future<List<NotificationItem>> fetchNotificationItems(String currentUserId) => getNotificationsList(currentUserId);

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _loginUseCase(LoginParams(email: email, password: password));
      resetForms();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _user = await _registerUseCase(RegisterParams(
        email: email,
        password: password,
        username: username,
        displayName: displayName,
      ));
      resetForms();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();
    try {
      await _logoutUseCase(const NoParams());
      _user = null;
      _navIdx = 0;
      resetForms();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
}

List<NotificationItem> _sortNotifications(List<NotificationItem> items) {
  items.sort((a, b) => b.time.compareTo(a.time));
  return items;
}
