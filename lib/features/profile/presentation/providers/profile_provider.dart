import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';
import 'package:social_media/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/follow_user_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:social_media/features/profile/domain/usecases/search_users_usecase.dart';

part 'profile_provider_mixin.dart';

class ProfileProvider extends ChangeNotifier with ProfileProviderMixin {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final FollowUserUseCase _followUserUseCase;
  final UnfollowUserUseCase _unfollowUserUseCase;
  final SearchUsersUseCase _searchUsersUseCase;

  ProfileProvider({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required FollowUserUseCase followUserUseCase,
    required UnfollowUserUseCase unfollowUserUseCase,
    required SearchUsersUseCase searchUsersUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _followUserUseCase = followUserUseCase,
        _unfollowUserUseCase = unfollowUserUseCase,
        _searchUsersUseCase = searchUsersUseCase {
    _initSearchListener();
  }

  void _initSearchListener() {
    searchCtrl.addListener(() {
      findUsers(searchCtrl.text);
    });
  }

  Future<void> fetchUserProfile(String userId) async {
    _loadingProfile = true;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'No internet connection. Running offline.';
      _loadingProfile = false;
      notifyListeners();
      return;
    }

    try {
      _profile = await _getUserProfileUseCase(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile(String userId) => fetchUserProfile(userId);

  Future<bool> saveProfile({
    required String userId,
    String? displayName,
    String? bio,
    dynamic file,
  }) async {
    _working = true;
    _error = null;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot update profile: No internet connection.';
      _working = false;
      notifyListeners();
      return false;
    }

    try {
      final updated = await _updateProfileUseCase(UpdateProfileParams(
        userId: userId,
        displayName: displayName,
        bio: bio,
        file: file,
      ));
      _profile = updated;
      resetEditForm();
      _working = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _working = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    dynamic file,
  }) => saveProfile(
    userId: userId,
    displayName: displayName,
    bio: bio,
    file: file,
  );

  Future<void> changeFollowState({
    required String currentUserId,
    required String targetUserId,
    bool isFollowingOverride = false,
  }) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'Cannot follow/unfollow: No internet connection.';
      notifyListeners();
      throw Exception('No internet connection');
    }

    final hasProfile = _profile != null && _profile!.id == targetUserId;
    final isFollowing = hasProfile
        ? _profile!.followers.contains(currentUserId)
        : isFollowingOverride;
    
    if (hasProfile) {
      final updatedFollowers = List<String>.from(_profile!.followers);
      if (isFollowing) {
        updatedFollowers.remove(currentUserId);
      } else {
        updatedFollowers.add(currentUserId);
      }
      _profile = _profile!.copyWith(followers: updatedFollowers);
      notifyListeners();
    }

    try {
      if (isFollowing) {
        await _unfollowUserUseCase(FollowParams(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        ));
      } else {
        await _followUserUseCase(FollowParams(
          currentUserId: currentUserId,
          targetUserId: targetUserId,
        ));
      }
    } catch (e) {
      if (hasProfile) {
        final revertedFollowers = List<String>.from(_profile!.followers);
        if (isFollowing) {
          revertedFollowers.add(currentUserId);
        } else {
          revertedFollowers.remove(currentUserId);
        }
        _profile = _profile!.copyWith(followers: revertedFollowers);
      }
      _error = 'Failed to update follow status.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFollow({
    required String currentUserId,
    required String targetUserId,
    bool isFollowingOverride = false,
  }) => changeFollowState(
    currentUserId: currentUserId,
    targetUserId: targetUserId,
    isFollowingOverride: isFollowingOverride,
  );

  Future<void> findUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchList = [];
      notifyListeners();
      return;
    }

    _searching = true;
    notifyListeners();

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _error = 'No internet connection.';
      _searching = false;
      notifyListeners();
      return;
    }

    try {
      _searchList = await _searchUsersUseCase(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query) => findUsers(query);

  Future<UserEntity> getUserProfileDirectly(String userId) {
    return _getUserProfileUseCase(userId);
  }
}
