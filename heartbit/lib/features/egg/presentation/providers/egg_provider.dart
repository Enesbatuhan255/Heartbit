
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/egg/data/datasources/egg_remote_datasource.dart';
import 'package:heartbit/features/egg/data/repositories/egg_repository_impl.dart';
import 'package:heartbit/features/egg/domain/repositories/egg_repository.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';

part 'egg_provider.g.dart';

// --- Data Layer ---

@riverpod
EggRemoteDataSource eggRemoteDataSource(EggRemoteDataSourceRef ref) {
  return EggRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
EggRepository eggRepository(EggRepositoryRef ref) {
  return EggRepositoryImpl(
    remoteDataSource: ref.watch(eggRemoteDataSourceProvider),
  );
}

// --- Controller ---

@riverpod
class EggController extends _$EggController {
  @override
  FutureOr<void> build() {
    // Initial state is void
  }

  Future<void> warmEgg(int amount) async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    
    final coupleId = coupleAsync.value!.id;

    state = const AsyncLoading();
    try {
      await ref.read(eggRepositoryProvider).incrementWarmth(coupleId, amount);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
