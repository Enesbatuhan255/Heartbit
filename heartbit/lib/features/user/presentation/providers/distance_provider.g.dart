// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partnerDistanceHash() => r'cc4dd7cd51ed69021e79c57d88b43965f9a8cf5e';

/// Calculates the distance (in km) between the current user and their partner.
/// Reuses the existing partnerStateProvider and current user's profile stream.
///
/// Copied from [partnerDistance].
@ProviderFor(partnerDistance)
final partnerDistanceProvider = AutoDisposeStreamProvider<double?>.internal(
  partnerDistance,
  name: r'partnerDistanceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$partnerDistanceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PartnerDistanceRef = AutoDisposeStreamProviderRef<double?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
