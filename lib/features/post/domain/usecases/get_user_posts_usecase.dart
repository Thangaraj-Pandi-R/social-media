import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';

class GetUserPostsUseCase implements UseCase<List<PostEntity>, String> {
  final PostRepository repository;

  GetUserPostsUseCase(this.repository);

  @override
  Future<List<PostEntity>> call(String userId) {
    return repository.getUserPosts(userId);
  }
}
