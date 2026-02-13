
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInAnonymously();
  Future<void> signOut();
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
}
