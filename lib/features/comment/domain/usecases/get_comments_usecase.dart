import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/comment/domain/repositories/comment_repository.dart';
import 'package:social_media/features/comment/domain/entities/comment_entity.dart';

class GetCommentsUseCase implements UseCase<List<CommentEntity>, String> {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  @override
  Future<List<CommentEntity>> call(String postId) {
    return repository.getComments(postId);
  }
}
