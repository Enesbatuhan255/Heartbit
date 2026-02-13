
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInAnonymouslyUseCase {
  final AuthRepository _repository;

  SignInAnonymouslyUseCase(this._repository);

  Future<UserEntity> call() {
    return _repository.signInAnonymously();
  }
}
