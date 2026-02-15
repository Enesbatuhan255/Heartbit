// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stack_tower_invite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$stackTowerInvitesHash() => r'6f9d6129e0fa1b6cb825e68cff743c12c68f99cf';

/// Watches for Stack Tower invitations for the current user
///
/// Copied from [stackTowerInvites].
@ProviderFor(stackTowerInvites)
final stackTowerInvitesProvider =
    AutoDisposeStreamProvider<List<StackTowerInvite>>.internal(
  stackTowerInvites,
  name: r'stackTowerInvitesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$stackTowerInvitesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StackTowerInvitesRef
    = AutoDisposeStreamProviderRef<List<StackTowerInvite>>;
String _$dismissStackTowerInviteHash() =>
    r'f0d883fb2862e12788ad7694b0f35cf3d48e32e6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Marks a Stack Tower invite as dismissed/read
///
/// Copied from [dismissStackTowerInvite].
@ProviderFor(dismissStackTowerInvite)
const dismissStackTowerInviteProvider = DismissStackTowerInviteFamily();

/// Marks a Stack Tower invite as dismissed/read
///
/// Copied from [dismissStackTowerInvite].
class DismissStackTowerInviteFamily extends Family<AsyncValue<void>> {
  /// Marks a Stack Tower invite as dismissed/read
  ///
  /// Copied from [dismissStackTowerInvite].
  const DismissStackTowerInviteFamily();

  /// Marks a Stack Tower invite as dismissed/read
  ///
  /// Copied from [dismissStackTowerInvite].
  DismissStackTowerInviteProvider call(
    String inviteId,
  ) {
    return DismissStackTowerInviteProvider(
      inviteId,
    );
  }

  @override
  DismissStackTowerInviteProvider getProviderOverride(
    covariant DismissStackTowerInviteProvider provider,
  ) {
    return call(
      provider.inviteId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dismissStackTowerInviteProvider';
}

/// Marks a Stack Tower invite as dismissed/read
///
/// Copied from [dismissStackTowerInvite].
class DismissStackTowerInviteProvider extends AutoDisposeFutureProvider<void> {
  /// Marks a Stack Tower invite as dismissed/read
  ///
  /// Copied from [dismissStackTowerInvite].
  DismissStackTowerInviteProvider(
    String inviteId,
  ) : this._internal(
          (ref) => dismissStackTowerInvite(
            ref as DismissStackTowerInviteRef,
            inviteId,
          ),
          from: dismissStackTowerInviteProvider,
          name: r'dismissStackTowerInviteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dismissStackTowerInviteHash,
          dependencies: DismissStackTowerInviteFamily._dependencies,
          allTransitiveDependencies:
              DismissStackTowerInviteFamily._allTransitiveDependencies,
          inviteId: inviteId,
        );

  DismissStackTowerInviteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inviteId,
  }) : super.internal();

  final String inviteId;

  @override
  Override overrideWith(
    FutureOr<void> Function(DismissStackTowerInviteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DismissStackTowerInviteProvider._internal(
        (ref) => create(ref as DismissStackTowerInviteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inviteId: inviteId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _DismissStackTowerInviteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DismissStackTowerInviteProvider &&
        other.inviteId == inviteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inviteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DismissStackTowerInviteRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `inviteId` of this provider.
  String get inviteId;
}

class _DismissStackTowerInviteProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with DismissStackTowerInviteRef {
  _DismissStackTowerInviteProviderElement(super.provider);

  @override
  String get inviteId => (origin as DismissStackTowerInviteProvider).inviteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
