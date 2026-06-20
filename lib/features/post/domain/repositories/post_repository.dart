import 'package:social_media/features/post/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<PostEntity> createPost({
    required String authorId,
    required String authorName,
    required String authorPic,
    required String content,
    dynamic imageFile,
  });
  Future<PostEntity> updatePost({
    required String postId,
    required String content,
  });
  Future<void> deletePost(String postId);
  Future<void> likePost({required String postId, required String userId});
  Future<void> unlikePost({required String postId, required String userId});
  Future<List<PostEntity>> getFeedPosts({
    required String userId,
    int limit = 10,
    String? lastPostId,
  });
  Future<List<PostEntity>> getUserPosts(String userId);
}
