
import '../../domain/repositories/egg_repository.dart';
import '../datasources/egg_remote_datasource.dart';

class EggRepositoryImpl implements EggRepository {
  final EggRemoteDataSource _remoteDataSource;

  EggRepositoryImpl({required EggRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<void> incrementWarmth(String coupleId, int amount) {
    return _remoteDataSource.incrementWarmth(coupleId, amount);
  }

  @override
  Future<void> setHatched(String coupleId) {
    return _remoteDataSource.setHatched(coupleId);
  }
}
