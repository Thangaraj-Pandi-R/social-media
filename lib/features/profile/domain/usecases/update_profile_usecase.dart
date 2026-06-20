import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class UpdateProfileParams {
  final String userId;
  final String? displayName;
  final String? bio;
  final dynamic file;

  const UpdateProfileParams({
    required this.userId,
    this.displayName,
    this.bio,
    this.file,
  });
}

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<UserEntity> call(UpdateProfileParams params) async {
    String? profilePicUrl;
    if (params.file != null) {
      profilePicUrl = await repository.uploadProfilePicture(params.userId, params.file);
    }
    return repository.updateProfile(
      userId: params.userId,
      displayName: params.displayName,
      bio: params.bio,
      profilePicUrl: profilePicUrl,
    );
  }
}
