// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRemoteDataSourceHash() =>
    r'e57eb2732f2790446eb98a38714f6330644599bd';

/// See also [authRemoteDataSource].
@ProviderFor(authRemoteDataSource)
final authRemoteDataSourceProvider =
    AutoDisposeProvider<AuthRemoteDataSource>.internal(
  authRemoteDataSource,
  name: r'authRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRemoteDataSourceRef = AutoDisposeProviderRef<AuthRemoteDataSource>;
String _$authRepositoryHash() => r'571ed5da8d84c80603a93178ad3ee568cf1dc67e';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$signInAnonymouslyUseCaseHash() =>
    r'48ccdbb4cbd97e003296cc622e7df52f5d0fee8f';

/// See also [signInAnonymouslyUseCase].
@ProviderFor(signInAnonymouslyUseCase)
final signInAnonymouslyUseCaseProvider =
    AutoDisposeProvider<SignInAnonymouslyUseCase>.internal(
  signInAnonymouslyUseCase,
  name: r'signInAnonymouslyUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signInAnonymouslyUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignInAnonymouslyUseCaseRef
    = AutoDisposeProviderRef<SignInAnonymouslyUseCase>;
String _$signOutUseCaseHash() => r'3e06d6c315dc4710dd995e6114538ae28f4c3336';

/// See also [signOutUseCase].
@ProviderFor(signOutUseCase)
final signOutUseCaseProvider = AutoDisposeProvider<SignOutUseCase>.internal(
  signOutUseCase,
  name: r'signOutUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signOutUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SignOutUseCaseRef = AutoDisposeProviderRef<SignOutUseCase>;
String _$authStateHash() => r'8f78b85758a292d04835a308fb5377fcea46b69c';

/// See also [authState].
@ProviderFor(authState)
final authStateProvider = AutoDisposeStreamProvider<UserEntity?>.internal(
  authState,
  name: r'authStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateRef = AutoDisposeStreamProviderRef<UserEntity?>;
String _$authUserIdHash() => r'50f784444edb50f14a98213451e7ce3b4c30885d';

/// See also [authUserId].
@ProviderFor(authUserId)
final authUserIdProvider = AutoDisposeProvider<String?>.internal(
  authUserId,
  name: r'authUserIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthUserIdRef = AutoDisposeProviderRef<String?>;
String _$authControllerHash() => r'a399ad03dd21bfe98cf5687b6241dde9ad75336b';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AutoDisposeAsyncNotifierProvider<AuthController, void>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
