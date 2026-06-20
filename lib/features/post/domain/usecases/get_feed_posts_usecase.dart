import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';

class GetFeedPostsParams {
  final String userId;
  final int limit;
  final String? lastPostId;

  const GetFeedPostsParams({
    required this.userId,
    this.limit = 10,
    this.lastPostId,
  });
}

class GetFeedPostsUseCase implements UseCase<List<PostEntity>, GetFeedPostsParams> {
  final PostRepository repository;

  GetFeedPostsUseCase(this.repository);

  @override
  Future<List<PostEntity>> call(GetFeedPostsParams params) {
    return repository.getFeedPosts(
      userId: params.userId,
      limit: params.limit,
      lastPostId: params.lastPostId,
    );
  }
}
