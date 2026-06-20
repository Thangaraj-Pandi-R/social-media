import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_media/features/profile/domain/usecases/follow_user_usecase.dart';

class UnfollowUserUseCase implements UseCase<void, FollowParams> {
  final ProfileRepository repository;

  UnfollowUserUseCase(this.repository);

  @override
  Future<void> call(FollowParams params) {
    return repository.unfollowUser(
      currentUserId: params.currentUserId,
      targetUserId: params.targetUserId,
    );
  }
}
