
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/user/domain/entities/user_profile.dart';
import 'package:heartbit/features/user/domain/repositories/user_repository.dart';
import 'package:heartbit/features/user/data/datasources/user_remote_datasource.dart';
import 'package:heartbit/features/user/data/datasources/storage_remote_datasource.dart';
import 'package:heartbit/features/user/data/repositories/user_repository_impl.dart';

part 'user_provider.g.dart';

@riverpod
UserRemoteDataSource userRemoteDataSource(UserRemoteDataSourceRef ref) {
  return UserRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
StorageRemoteDataSource storageRemoteDataSource(StorageRemoteDataSourceRef ref) {
  return StorageRemoteDataSourceImpl(
    storage: ref.watch(firebaseStorageProvider),
  );
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.watch(userRemoteDataSourceProvider),
    storageDataSource: ref.watch(storageRemoteDataSourceProvider),
  );
}

@riverpod
class UserProfileController extends _$UserProfileController {
  @override
  FutureOr<void> build() {}

  Future<void> updateSleepStatus(String uid, bool isSleeping) async {
    state = const AsyncLoading();
    try {
      await ref.read(userRepositoryProvider).updateSleepStatus(uid, isSleeping);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

@riverpod
Stream<UserProfile?> userProfileStream(UserProfileStreamRef ref, String uid) {
  return ref.watch(userRepositoryProvider).watchUser(uid);
}
