import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/core/errors/failure.dart';
import 'package:social_media/core/utils/constants.dart';
import 'package:social_media/core/services/firebase_storage_service.dart';
import 'package:social_media/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_media/features/profile/data/models/user_model.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw const ServerFailure('Profile not found.');
      }

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? profilePicUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (profilePicUrl != null) updates['profilePicUrl'] = profilePicUrl;

      if (updates.isEmpty) {
        return getUserProfile(userId);
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);

      if (displayName != null || profilePicUrl != null) {
        _updateDenormalizedPostInfo(userId, displayName, profilePicUrl);
      }

      return getUserProfile(userId);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<void> _updateDenormalizedPostInfo(
    String userId,
    String? displayName,
    String? profilePicUrl,
  ) async {
    try {
      final batch = _firestore.batch();
      final postsQuery = await _firestore
          .collection(AppConstants.postsCollection)
          .where('authorId', isEqualTo: userId)
          .get();

      for (var doc in postsQuery.docs) {
        final postUpdates = <String, dynamic>{};
        if (displayName != null) postUpdates['authorName'] = displayName;
        if (profilePicUrl != null) postUpdates['authorPic'] = profilePicUrl;
        batch.update(doc.reference, postUpdates);
      }

      await batch.commit();
    } catch (_) {
    }
  }

  @override
  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();
      final currentUserRef = _firestore.collection(AppConstants.usersCollection).doc(currentUserId);
      final targetUserRef = _firestore.collection(AppConstants.usersCollection).doc(targetUserId);

      batch.update(currentUserRef, {
        'following': FieldValue.arrayUnion([targetUserId])
      });

      batch.update(targetUserRef, {
        'followers': FieldValue.arrayUnion([currentUserId])
      });

      await batch.commit();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();
      final currentUserRef = _firestore.collection(AppConstants.usersCollection).doc(currentUserId);
      final targetUserRef = _firestore.collection(AppConstants.usersCollection).doc(targetUserId);

      batch.update(currentUserRef, {
        'following': FieldValue.arrayRemove([targetUserId])
      });

      batch.update(targetUserRef, {
        'followers': FieldValue.arrayRemove([currentUserId])
      });

      await batch.commit();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      final normalized = query.trim().toLowerCase();

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isGreaterThanOrEqualTo: normalized)
          .where('username', isLessThanOrEqualTo: '$normalized\uf8ff')
          .limit(10)
          .get();

      final rawDocs = snapshot.docs.map((doc) => {'id': doc.id, 'data': doc.data()}).toList();

      return await compute(_parseUsersList, rawDocs);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> uploadProfilePicture(String userId, dynamic file) async {
    if (file is! File) {
      throw const StorageFailure('Invalid file type for Firebase upload.');
    }
    return FirebaseStorageService.uploadFile(
      path: 'profiles/$userId/avatar.jpg',
      file: file,
    );
  }
}

List<UserEntity> _parseUsersList(List<dynamic> rawDocs) {
  final list = rawDocs.map((docMap) {
    final map = docMap as Map<String, dynamic>;
    final id = map['id'] as String;
    final data = map['data'] as Map<String, dynamic>;
    return UserModel.fromMap(data, id);
  }).toList();
  return List<UserEntity>.from(list);
}
