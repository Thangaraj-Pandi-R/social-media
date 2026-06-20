import 'package:social_media/features/profile/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getUserProfile(String userId);
  Future<UserEntity> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? profilePicUrl,
  });
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<List<UserEntity>> searchUsers(String query);
  Future<String> uploadProfilePicture(String userId, dynamic file);
}
