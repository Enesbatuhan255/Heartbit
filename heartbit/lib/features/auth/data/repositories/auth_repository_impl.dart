
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<UserEntity> signInAnonymously() async {
    final model = await _remoteDataSource.signInAnonymously();
    return model.toEntity();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((model) => model?.toEntity());
  }

  @override
  UserEntity? get currentUser {
    return _remoteDataSource.currentUser?.toEntity();
  }
}
