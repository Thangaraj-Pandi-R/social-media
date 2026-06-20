import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/profile/domain/repositories/profile_repository.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class SearchUsersUseCase implements UseCase<List<UserEntity>, String> {
  final ProfileRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<List<UserEntity>> call(String query) {
    return repository.searchUsers(query);
  }
}
