import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class GetUserProfileUseCase implements UseCase<UserEntity, String> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<UserEntity> call(String userId) {
    return repository.getUserProfile(userId);
  }
}
