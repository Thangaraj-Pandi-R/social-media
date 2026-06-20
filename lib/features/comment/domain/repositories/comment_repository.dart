import 'package:social_media/features/comment/domain/entities/comment_entity.dart';

abstract class CommentRepository {
  Future<CommentEntity> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String authorPic,
    required String content,
  });
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
  Future<List<CommentEntity>> getComments(String postId);
}
