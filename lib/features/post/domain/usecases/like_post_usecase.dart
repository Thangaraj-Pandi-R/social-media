import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';

class LikePostParams {
  final String postId;
  final String userId;
  final bool isLike;

  const LikePostParams({
    required this.postId,
    required this.userId,
    required this.isLike,
  });
}

class LikePostUseCase implements UseCase<void, LikePostParams> {
  final PostRepository repository;

  LikePostUseCase(this.repository);

  @override
  Future<void> call(LikePostParams params) {
    if (params.isLike) {
      return repository.likePost(postId: params.postId, userId: params.userId);
    } else {
      return repository.unlikePost(postId: params.postId, userId: params.userId);
    }
  }
}
