// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$drawingRemoteDataSourceHash() =>
    r'fe44cad9a475dc20b346b00cd8f7bdf58eb5402f';

/// See also [drawingRemoteDataSource].
@ProviderFor(drawingRemoteDataSource)
final drawingRemoteDataSourceProvider =
    AutoDisposeProvider<DrawingRemoteDataSource>.internal(
  drawingRemoteDataSource,
  name: r'drawingRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$drawingRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DrawingRemoteDataSourceRef
    = AutoDisposeProviderRef<DrawingRemoteDataSource>;
String _$drawingRepositoryHash() => r'e22b3f764d7f570105e80a5c889e1722ca0eea7b';

/// See also [drawingRepository].
@ProviderFor(drawingRepository)
final drawingRepositoryProvider =
    AutoDisposeProvider<DrawingRepository>.internal(
  drawingRepository,
  name: r'drawingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$drawingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DrawingRepositoryRef = AutoDisposeProviderRef<DrawingRepository>;
String _$activeDrawingSessionHash() =>
    r'dc457888a72949da3bc9dd6c4dfc8494c718b121';

/// Active drawing session for the current couple (if any)
///
/// Copied from [activeDrawingSession].
@ProviderFor(activeDrawingSession)
final activeDrawingSessionProvider =
    AutoDisposeStreamProvider<DrawingSession?>.internal(
  activeDrawingSession,
  name: r'activeDrawingSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeDrawingSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveDrawingSessionRef = AutoDisposeStreamProviderRef<DrawingSession?>;
String _$drawingGameControllerHash() =>
    r'6940989954572215d2848011c863b463330cedfb';

/// See also [DrawingGameController].
@ProviderFor(DrawingGameController)
final drawingGameControllerProvider =
    AutoDisposeAsyncNotifierProvider<DrawingGameController, void>.internal(
  DrawingGameController.new,
  name: r'drawingGameControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$drawingGameControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DrawingGameController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
