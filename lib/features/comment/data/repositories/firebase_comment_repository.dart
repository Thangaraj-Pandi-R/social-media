import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/core/errors/failure.dart';
import 'package:social_media/core/utils/constants.dart';
import 'package:social_media/features/comment/domain/repositories/comment_repository.dart';
import 'package:social_media/features/comment/data/models/comment_model.dart';
import 'package:social_media/features/comment/domain/entities/comment_entity.dart';

class FirebaseCommentRepository implements CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorPic,
    required String content,
  }) async {
    try {
      final commentId = _firestore.collection(AppConstants.commentsCollection).doc().id;

      final comment = CommentModel(
        id: commentId,
        postId: postId,
        authorId: authorId,
        authorName: authorName,
        authorPic: authorPic,
        content: content,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      
      final commentRef = _firestore.collection(AppConstants.commentsCollection).doc(commentId);
      final postRef = _firestore.collection(AppConstants.postsCollection).doc(postId);

      batch.set(commentRef, comment.toFirestoreMap());
      batch.update(postRef, {
        'commentCount': FieldValue.increment(1),
      });

      await batch.commit();
      return comment;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final batch = _firestore.batch();
      
      final commentRef = _firestore.collection(AppConstants.commentsCollection).doc(commentId);
      final postRef = _firestore.collection(AppConstants.postsCollection).doc(postId);

      batch.delete(commentRef);
      batch.update(postRef, {
        'commentCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CommentEntity>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.commentsCollection)
          .where('postId', isEqualTo: postId)
          .get();

      final rawDocs = snapshot.docs.map((doc) => {'id': doc.id, 'data': doc.data()}).toList();

      return await compute(_parseCommentsList, rawDocs);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

List<CommentEntity> _parseCommentsList(List<dynamic> rawDocs) {
  final list = rawDocs.map((docMap) {
    final map = docMap as Map<String, dynamic>;
    final id = map['id'] as String;
    final data = map['data'] as Map<String, dynamic>;
    return CommentModel.fromMap(data, id);
  }).toList();
  list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return List<CommentEntity>.from(list);
}
