import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';

class DeletePostUseCase implements UseCase<void, String> {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  @override
  Future<void> call(String postId) {
    return repository.deletePost(postId);
  }
}
