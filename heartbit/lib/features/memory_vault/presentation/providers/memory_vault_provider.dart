import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

import '../../domain/entities/memory.dart';
import '../../domain/repositories/memory_repository.dart';
import '../../data/datasources/memory_remote_datasource.dart';
import '../../data/repositories/memory_repository_impl.dart';

part 'memory_vault_provider.g.dart';

// --- Data Layer Providers ---

@riverpod
MemoryRemoteDataSource memoryRemoteDataSource(MemoryRemoteDataSourceRef ref) {
  return MemoryRemoteDataSource(
    firestore: ref.watch(firebaseFirestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
  );
}

@riverpod
MemoryRepository memoryRepository(MemoryRepositoryRef ref) {
  return MemoryRepositoryImpl(
    remoteDataSource: ref.watch(memoryRemoteDataSourceProvider),
  );
}

// --- Memory Data Providers ---

/// All memories for the current couple
@riverpod
Stream<List<Memory>> memories(MemoriesRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);

  if (!coupleAsync.hasValue || coupleAsync.value == null) {
    return const Stream.empty();
  }

  return ref.watch(memoryRepositoryProvider)
      .watchMemories(coupleAsync.value!.id);
}

// --- Memory Controller ---

@riverpod
class MemoryController extends _$MemoryController {
  @override
  FutureOr<void> build() {}

  Future<Memory?> addMemory({
    required String imagePath,
    required DateTime date,
    required String description,
    String? title,
  }) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final userId = ref.read(authUserIdProvider);

    if (!coupleAsync.hasValue || coupleAsync.value == null || userId == null) {
      throw Exception('Kullanıcı veya partner bilgisi bulunamadı.');
    }

    final coupleId = coupleAsync.value!.id;
    final repo = ref.read(memoryRepositoryProvider);

    try {
      // Check quota (Max 50 memories)
      final currentCount = await repo.getMemoryCount(coupleId);
      if (currentCount >= 50) {
        throw Exception('Anı kutusu doldu! (Limit: 50 anı). Yeni anı eklemek için eskileri silmelisin.');
      }

      // Upload image first
      final imageUrl = await repo.uploadImage(coupleId, imagePath);

      // Create memory
      final memory = Memory(
        id: '', // Will be set by Firestore
        coupleId: coupleId,
        imageUrl: imageUrl,
        date: date,
        description: description,
        title: title,
        createdBy: userId,
      );

      final result = await repo.addMemory(memory);
      return result;
    } catch (e) {
      rethrow; // Rethrow so UI can catch it
    }
  }

  Future<void> deleteMemory(String memoryId) async {
    final coupleAsync = ref.read(coupleStateProvider);

    if (!coupleAsync.hasValue || coupleAsync.value == null) {
      return;
    }

    final coupleId = coupleAsync.value!.id;
    final repo = ref.read(memoryRepositoryProvider) as MemoryRepositoryImpl;

    try {
      await repo.deleteMemoryWithCoupleId(coupleId, memoryId);
    } catch (e) {
      rethrow;
    }
  }
}
