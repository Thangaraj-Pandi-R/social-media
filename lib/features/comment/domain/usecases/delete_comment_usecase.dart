import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/comment/domain/repositories/comment_repository.dart';

class DeleteCommentParams {
  final String postId;
  final String commentId;

  const DeleteCommentParams({required this.postId, required this.commentId});
}

class DeleteCommentUseCase implements UseCase<void, DeleteCommentParams> {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  @override
  Future<void> call(DeleteCommentParams params) {
    return repository.deleteComment(
      postId: params.postId,
      commentId: params.commentId,
    );
  }
}
