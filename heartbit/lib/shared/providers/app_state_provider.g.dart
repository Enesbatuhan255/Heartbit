// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bootTimeoutHash() => r'ea396405e47bc1d3967771b561a44f8ff625ea1a';

/// Timeout provider: emits false initially, then true after 5 seconds.
/// This prevents the app from being stuck on the loading screen forever
/// if Firestore is slow to connect (e.g., cold start on Pixel 9).
///
/// Copied from [BootTimeout].
@ProviderFor(BootTimeout)
final bootTimeoutProvider = NotifierProvider<BootTimeout, bool>.internal(
  BootTimeout.new,
  name: r'bootTimeoutProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bootTimeoutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BootTimeout = Notifier<bool>;
String _$appBootstrapHash() => r'dde13abf253209cb2c1f9e0142158776c22a42b3';

/// See also [AppBootstrap].
@ProviderFor(AppBootstrap)
final appBootstrapProvider =
    AutoDisposeNotifierProvider<AppBootstrap, AppState>.internal(
  AppBootstrap.new,
  name: r'appBootstrapProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appBootstrapHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppBootstrap = AutoDisposeNotifier<AppState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
