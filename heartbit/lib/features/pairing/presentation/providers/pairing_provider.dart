import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/domain/repositories/pairing_repository.dart';
import 'package:heartbit/features/pairing/data/datasources/pairing_remote_datasource.dart';
import 'package:heartbit/features/pairing/data/repositories/pairing_repository_impl.dart';
import 'package:heartbit/features/pairing/domain/usecases/generate_pairing_code_usecase.dart';
import 'package:heartbit/features/pairing/domain/usecases/join_with_code_usecase.dart';
import 'package:heartbit/features/pairing/domain/usecases/watch_couple_usecase.dart';
import 'package:heartbit/features/pairing/domain/entities/couple_entity.dart';

part 'pairing_provider.g.dart';

// --- Data Layer Providers ---

@riverpod
PairingRemoteDataSource pairingRemoteDataSource(PairingRemoteDataSourceRef ref) {
  return PairingRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
PairingRepository pairingRepository(PairingRepositoryRef ref) {
  return PairingRepositoryImpl(
    remoteDataSource: ref.watch(pairingRemoteDataSourceProvider),
  );
}

// --- Domain Layer Providers (Use Cases) ---

@riverpod
GeneratePairingCodeUseCase generatePairingCodeUseCase(GeneratePairingCodeUseCaseRef ref) {
  return GeneratePairingCodeUseCase(ref.watch(pairingRepositoryProvider));
}

@riverpod
JoinWithCodeUseCase joinWithCodeUseCase(JoinWithCodeUseCaseRef ref) {
  return JoinWithCodeUseCase(ref.watch(pairingRepositoryProvider));
}

@riverpod
WatchCoupleUseCase watchCoupleUseCase(WatchCoupleUseCaseRef ref) {
  return WatchCoupleUseCase(ref.watch(pairingRepositoryProvider));
}

// --- Presentation Layer Providers (Controllers & State) ---

@riverpod
Stream<CoupleEntity?> coupleState(CoupleStateRef ref) {
  final user = ref.watch(authUserIdProvider); // We need current user ID
  if (user == null) return const Stream.empty();
  
  return ref.watch(watchCoupleUseCaseProvider)(user);
}

@riverpod
class PairingController extends _$PairingController {
  @override
  FutureOr<String?> build() {
    return null; // No code initially
  }

  Future<void> generateCode() async {
    state = const AsyncLoading();
    final userId = ref.read(authUserIdProvider);
    if (userId == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    try {
      final code = await ref.read(generatePairingCodeUseCaseProvider)(userId);
      state = AsyncData(code);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> joinWithCode(String code) async {
    state = const AsyncLoading();
    final userId = ref.read(authUserIdProvider);
    
    if (userId == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    try {
      await ref.read(joinWithCodeUseCaseProvider).call(
        currentUserId: userId,
        code: code,
      );
      // On success, we don't change state to code, maybe navigate away or show success
      // Ideally we should return a state indicating success
      state = const AsyncData(null); 
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
