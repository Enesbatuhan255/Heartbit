// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$draftSessionDataSourceHash() =>
    r'84dbafaff2135cd46222ceb39ee0b07a6146c232';

/// See also [draftSessionDataSource].
@ProviderFor(draftSessionDataSource)
final draftSessionDataSourceProvider =
    AutoDisposeProvider<DraftSessionDataSource>.internal(
  draftSessionDataSource,
  name: r'draftSessionDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$draftSessionDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DraftSessionDataSourceRef
    = AutoDisposeProviderRef<DraftSessionDataSource>;
String _$sharedDraftSessionHash() =>
    r'c63d26fb4299a84df2d3180f85fc7df76c8edc7f';

/// See also [sharedDraftSession].
@ProviderFor(sharedDraftSession)
final sharedDraftSessionProvider =
    AutoDisposeStreamProvider<DraftSession?>.internal(
  sharedDraftSession,
  name: r'sharedDraftSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedDraftSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedDraftSessionRef = AutoDisposeStreamProviderRef<DraftSession?>;
String _$draftSessionControllerHash() =>
    r'383a3a8465b3d28315d9e41e4a6a32d76291d7d0';

/// See also [DraftSessionController].
@ProviderFor(DraftSessionController)
final draftSessionControllerProvider =
    AutoDisposeAsyncNotifierProvider<DraftSessionController, void>.internal(
  DraftSessionController.new,
  name: r'draftSessionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$draftSessionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DraftSessionController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
