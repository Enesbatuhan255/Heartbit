import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/domain/entities/user_entity.dart';
import 'package:heartbit/features/auth/domain/repositories/auth_repository.dart';
import 'package:heartbit/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:heartbit/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:heartbit/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:heartbit/features/auth/data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

// --- Data Layer Providers ---

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

// --- Domain Layer Providers (Use Cases) ---

@riverpod
SignInAnonymouslyUseCase signInAnonymouslyUseCase(SignInAnonymouslyUseCaseRef ref) {
  return SignInAnonymouslyUseCase(ref.watch(authRepositoryProvider));
}

@riverpod
SignOutUseCase signOutUseCase(SignOutUseCaseRef ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}

// --- Presentation Layer Providers ---

@riverpod
Stream<UserEntity?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
String? authUserId(AuthUserIdRef ref) {
  return ref.watch(authStateProvider).value?.uid;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // nothing to init
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      await ref.read(signInAnonymouslyUseCaseProvider).call();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(signOutUseCaseProvider).call();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

