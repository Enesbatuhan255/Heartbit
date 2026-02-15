import '../../domain/entities/memory.dart';
import '../../domain/repositories/memory_repository.dart';
import '../datasources/memory_remote_datasource.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryRemoteDataSource _remoteDataSource;

  MemoryRepositoryImpl({required MemoryRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Stream<List<Memory>> watchMemories(String coupleId) {
    return _remoteDataSource.watchMemories(coupleId);
  }

  @override
  Future<List<Memory>> getMemories(String coupleId) {
    return _remoteDataSource.getMemories(coupleId);
  }

  @override
  Future<int> getMemoryCount(String coupleId) {
    return _remoteDataSource.getMemoryCount(coupleId);
  }

  @override
  Future<Memory> addMemory(Memory memory) {
    return _remoteDataSource.addMemory(memory);
  }

  @override
  Future<void> deleteMemory(String memoryId) async {
    // Note: We need coupleId for deletion, this should be handled at controller level
    throw UnimplementedError('Use deleteMemoryWithCoupleId instead');
  }

  Future<void> deleteMemoryWithCoupleId(String coupleId, String memoryId) async {
    return _remoteDataSource.deleteMemory(coupleId, memoryId);
  }

  @override
  Future<String> uploadImage(String coupleId, String filePath) {
    return _remoteDataSource.uploadImage(coupleId, filePath);
  }
}
