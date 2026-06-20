import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/profile/domain/repositories/profile_repository.dart';

class FollowParams {
  final String currentUserId;
  final String targetUserId;

  const FollowParams({required this.currentUserId, required this.targetUserId});
}

class FollowUserUseCase implements UseCase<void, FollowParams> {
  final ProfileRepository repository;

  FollowUserUseCase(this.repository);

  @override
  Future<void> call(FollowParams params) {
    return repository.followUser(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );
  }
}
