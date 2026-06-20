import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';

class EditPostParams {
  final String postId;
  final String content;

  const EditPostParams({required this.postId, required this.content});
}

class EditPostUseCase implements UseCase<PostEntity, EditPostParams> {
  final PostRepository repository;

  EditPostUseCase(this.repository);

  @override
  Future<PostEntity> call(EditPostParams params) {
    return repository.updatePost(postId: params.postId, content: params.content);
  }
}
