import '../entities/memory.dart';

abstract class MemoryRepository {
  Stream<List<Memory>> watchMemories(String coupleId);
  Future<List<Memory>> getMemories(String coupleId);
  Future<int> getMemoryCount(String coupleId);
  Future<Memory> addMemory(Memory memory);
  Future<void> deleteMemory(String memoryId);
  Future<String> uploadImage(String coupleId, String filePath);
}
