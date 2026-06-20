import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/comment/domain/repositories/comment_repository.dart';
import 'package:social_media/features/comment/domain/entities/comment_entity.dart';

class AddCommentParams {
  final String postId;
  final String authorId;
  final String authorName;
  final String authorPic;
  final String content;

  const AddCommentParams({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorPic,
    required this.content,
  });
}

class AddCommentUseCase implements UseCase<CommentEntity, AddCommentParams> {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<CommentEntity> call(AddCommentParams params) {
    return repository.addComment(
      postId: params.postId,
      authorId: params.authorId,
      authorName: params.authorName,
      authorPic: params.authorPic,
      content: params.content,
    );
  }
}
