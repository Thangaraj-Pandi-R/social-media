import 'package:social_media/core/usecases/usecase.dart';
import 'package:social_media/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_media/features/profile/domain/entities/user_entity.dart';

class RegisterParams {
  final String email;
  final String password;
  final String username;
  final String displayName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.username,
    required this.displayName,
  });
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      username: params.username,
      displayName: params.displayName,
    );
  }
}
