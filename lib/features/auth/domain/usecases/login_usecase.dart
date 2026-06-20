import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<UserEntity> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}
