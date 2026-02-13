
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/storage_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final StorageRemoteDataSource _storageDataSource;

  UserRepositoryImpl({
    required UserRemoteDataSource remoteDataSource,
    required StorageRemoteDataSource storageDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _storageDataSource = storageDataSource;

  @override
  Stream<UserProfile?> watchUser(String uid) {
    return _remoteDataSource.watchUser(uid);
  }

  @override
  Future<UserProfile?> getUser(String uid) {
    return _remoteDataSource.getUser(uid);
  }

  @override
  Future<void> updateStatus(String uid, String status) {
    return _remoteDataSource.updateStatus(uid, status);
  }

  @override
  Future<void> updateDisplayName(String uid, String displayName) {
    return _remoteDataSource.updateDisplayName(uid, displayName);
  }

  @override
  Future<void> updateLastSeen(String uid) {
    return _remoteDataSource.updateLastSeen(uid);
  }

  @override
  Future<String> uploadProfileImage(String uid, String filePath) {
    return _storageDataSource.uploadProfilePhoto(uid, filePath);
  }

  @override
  Future<void> updateProfilePhoto(String uid, String photoUrl) {
    return _remoteDataSource.updatePhotoUrl(uid, photoUrl);
  }

  @override
  Future<void> updateInteraction(String uid) {
    return _remoteDataSource.updateInteraction(uid);
  }
}
