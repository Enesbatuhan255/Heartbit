
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
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
