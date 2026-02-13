// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nudge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nudgeStateHash() => r'4822ec32bde70db69804888a8ba49aa8d634dfa0';

/// Watch for incoming nudges
///
/// Copied from [nudgeState].
@ProviderFor(nudgeState)
final nudgeStateProvider =
    AutoDisposeStreamProvider<Map<String, dynamic>?>.internal(
  nudgeState,
  name: r'nudgeStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$nudgeStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NudgeStateRef = AutoDisposeStreamProviderRef<Map<String, dynamic>?>;
String _$nudgeControllerHash() => r'c836471165951c56ebfc3977d2a6866762a51001';

/// Controller for sending nudges
///
/// Copied from [NudgeController].
@ProviderFor(NudgeController)
final nudgeControllerProvider =
    AutoDisposeAsyncNotifierProvider<NudgeController, void>.internal(
  NudgeController.new,
  name: r'nudgeControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nudgeControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NudgeController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
