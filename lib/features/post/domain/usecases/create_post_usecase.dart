import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/post/domain/repositories/post_repository.dart';
import 'package:social_media/features/post/domain/entities/post_entity.dart';

class CreatePostParams {
  final String authorId;
  final String authorName;
  final String authorPic;
  final String content;
  final dynamic imageFile;

  const CreatePostParams({
    required this.authorId,
    required this.authorName,
    required this.authorPic,
    required this.content,
    this.imageFile,
  });
}

class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  @override
  Future<PostEntity> call(CreatePostParams params) {
    return repository.createPost(
      authorId: params.authorId,
      authorName: params.authorName,
      authorPic: params.authorPic,
      content: params.content,
      imageFile: params.imageFile,
    );
  }
}
