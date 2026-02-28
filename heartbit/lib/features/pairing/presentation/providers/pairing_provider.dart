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

@Riverpod(keepAlive: true)
Stream<CoupleEntity?> coupleState(CoupleStateRef ref) {
  ref.keepAlive();
  final user = ref.watch(authUserIdProvider); // We need current user ID
  if (user == null) return Stream.value(null);
  
  return ref.watch(watchCoupleUseCaseProvider)(user);
}

@riverpod
class PairingController extends _$PairingController {
  @override
  FutureOr<String?> build() {
    return null; // No code initially
  }

  /// Ensures user is logged in (anonymous auth), returns userId or null
  Future<String?> _ensureAuth() async {
    var userId = ref.read(authUserIdProvider);
    if (userId != null) return userId;

    // Auto sign-in anonymously
    await ref.read(authControllerProvider.notifier).signInAnonymously();
    
    // Poll for auth state propagation with timeout (up to 3 seconds)
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      userId = ref.read(authUserIdProvider);
      if (userId != null) return userId;
    }
    return null;
  }

  Future<void> generateCode() async {
    state = const AsyncLoading();

    try {
      final userId = await _ensureAuth();
      if (userId == null) {
        state = AsyncError('Giriş yapılamadı. Lütfen tekrar deneyin.', StackTrace.current);
        return;
      }

      final code = await ref.read(generatePairingCodeUseCaseProvider)(userId);
      state = AsyncData(code);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> joinWithCode(String code) async {
    state = const AsyncLoading();

    try {
      final userId = await _ensureAuth();
      if (userId == null) {
        state = AsyncError('Giriş yapılamadı. Lütfen tekrar deneyin.', StackTrace.current);
        return;
      }

      await ref.read(joinWithCodeUseCaseProvider).call(
        currentUserId: userId,
        code: code,
      );
      state = const AsyncData(null); 
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
