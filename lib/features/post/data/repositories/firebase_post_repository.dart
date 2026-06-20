import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/core/errors/failure.dart';
import 'package:social_media/core/utils/constants.dart';
import 'package:social_media/core/services/firebase_storage_service.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';
import 'package:social_media/features/post/data/models/post_model.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';

class FirebasePostRepository implements PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<PostEntity> createPost({
    required String authorId,
    required String authorName,
    required String authorPic,
    required String content,
    dynamic imageFile,
  }) async {
    try {
      String? imageUrl;
      final postId = _firestore.collection(AppConstants.postsCollection).doc().id;

      if (imageFile is File) {
        imageUrl = await FirebaseStorageService.uploadFile(
          path: 'posts/$postId/post_image.jpg',
          file: imageFile,
        );
      }

      final post = PostModel(
        id: postId,
        authorId: authorId,
        authorName: authorName,
        authorPic: authorPic,
        content: content,
        imageUrl: imageUrl,
        likes: [],
        commentCount: 0,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .set(post.toFirestoreMap());

      return post;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .update({'content': content});

      final doc = await _firestore.collection(AppConstants.postsCollection).doc(postId).get();
      return PostModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(AppConstants.postsCollection).doc(postId).delete();

      final commentsQuery = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('postId', isEqualTo: postId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in commentsQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await FirebaseStorageService.deleteFile('posts/$postId/post_image.jpg');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> likePost({required String postId, required String userId}) async {
    try {
      await _firestore.collection(AppConstants.postsCollection).doc(postId).update({
        'likes': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> unlikePost({required String postId, required String userId}) async {
    try {
      await _firestore.collection(AppConstants.postsCollection).doc(postId).update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<PostEntity>> getFeedPosts({
    required String userId,
    int limit = 10,
    String? lastPostId,
  }) async {
    try {
      final userDoc = await _firestore.collection(AppConstants.usersCollection).doc(userId).get();
      final following = List<String>.from(userDoc.data()?['following'] ?? []);
      final feedIds = [userId, ...following];

      Query query = _firestore.collection(AppConstants.postsCollection);
      query = query.orderBy('createdAt', descending: true);

      if (lastPostId != null) {
        final lastDoc = await _firestore.collection(AppConstants.postsCollection).doc(lastPostId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.limit(limit * 20).get();
      final rawDocs = snapshot.docs.map((doc) => {'id': doc.id, 'data': doc.data()}).toList();

      final filteredPosts = await compute(_parseAndFilterPosts, {
        'rawDocs': rawDocs,
        'feedIds': feedIds,
        'limit': limit,
        'lastPostId': lastPostId,
      });

      return filteredPosts;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<PostEntity>> getUserPosts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .where('authorId', isEqualTo: userId)
          .get();

      final rawDocs = snapshot.docs.map((doc) => {'id': doc.id, 'data': doc.data()}).toList();

      return await compute(_parseUserPostsList, rawDocs);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

List<PostEntity> _parseAndFilterPosts(Map<String, dynamic> params) {
  final rawDocs = params['rawDocs'] as List<dynamic>;
  final feedIds = params['feedIds'] as List<String>;
  final limit = params['limit'] as int;
  final lastPostId = params['lastPostId'] as String?;

  final allPosts = rawDocs.map((docMap) {
    final map = docMap as Map<String, dynamic>;
    final id = map['id'] as String;
    final data = map['data'] as Map<String, dynamic>;
    return PostModel.fromMap(data, id);
  }).toList();

  final filteredPosts = allPosts.where((p) => feedIds.contains(p.authorId)).take(limit).toList();

  if ((filteredPosts.isEmpty || feedIds.length <= 1) && lastPostId == null) {
    return List<PostEntity>.from(allPosts.take(limit));
  }

  return List<PostEntity>.from(filteredPosts);
}

List<PostEntity> _parseUserPostsList(List<dynamic> rawDocs) {
  final list = rawDocs.map((docMap) {
    final map = docMap as Map<String, dynamic>;
    final id = map['id'] as String;
    final data = map['data'] as Map<String, dynamic>;
    return PostModel.fromMap(data, id);
  }).toList();

  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return List<PostEntity>.from(list);
}
