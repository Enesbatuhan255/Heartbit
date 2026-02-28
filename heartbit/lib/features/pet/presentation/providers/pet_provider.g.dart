// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$petRemoteDataSourceHash() =>
    r'14982045fcc547441089e2efee94dcbca85d3005';

/// See also [petRemoteDataSource].
@ProviderFor(petRemoteDataSource)
final petRemoteDataSourceProvider =
    AutoDisposeProvider<PetRemoteDataSource>.internal(
  petRemoteDataSource,
  name: r'petRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetRemoteDataSourceRef = AutoDisposeProviderRef<PetRemoteDataSource>;
String _$petRepositoryHash() => r'a6f5fbc76ace7c546d059c451b4174687d4d2808';

/// See also [petRepository].
@ProviderFor(petRepository)
final petRepositoryProvider = AutoDisposeProvider<PetRepository>.internal(
  petRepository,
  name: r'petRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetRepositoryRef = AutoDisposeProviderRef<PetRepository>;
String _$petStateHash() => r'e76a184345b28b532b7138b477ce02c363e1e236';

/// See also [petState].
@ProviderFor(petState)
final petStateProvider = StreamProvider<Pet?>.internal(
  petState,
  name: r'petStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$petStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PetStateRef = StreamProviderRef<Pet?>;
String _$petControllerHash() => r'11bf798fd3e2f6afcd0842ad5e431e7667a21a6c';

/// See also [PetController].
@ProviderFor(PetController)
final petControllerProvider =
    AutoDisposeAsyncNotifierProvider<PetController, void>.internal(
  PetController.new,
  name: r'petControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$petControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PetController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
