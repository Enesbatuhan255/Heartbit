// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rhythm_copy_invite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rhythmCopyInvitesHash() => r'38c1e9b5a99218e36138aedfb52460aecf3571d8';

/// Watches for Rhythm Copy invitations for the current user
///
/// Copied from [rhythmCopyInvites].
@ProviderFor(rhythmCopyInvites)
final rhythmCopyInvitesProvider =
    AutoDisposeStreamProvider<List<RhythmCopyInvite>>.internal(
  rhythmCopyInvites,
  name: r'rhythmCopyInvitesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rhythmCopyInvitesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RhythmCopyInvitesRef
    = AutoDisposeStreamProviderRef<List<RhythmCopyInvite>>;
String _$dismissRhythmCopyInviteHash() =>
    r'e9e8ccf85ae73614d2043abea9cd5c6d32e62c33';

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

/// Marks a Rhythm Copy invite as dismissed/read
///
/// Copied from [dismissRhythmCopyInvite].
@ProviderFor(dismissRhythmCopyInvite)
const dismissRhythmCopyInviteProvider = DismissRhythmCopyInviteFamily();

/// Marks a Rhythm Copy invite as dismissed/read
///
/// Copied from [dismissRhythmCopyInvite].
class DismissRhythmCopyInviteFamily extends Family<AsyncValue<void>> {
  /// Marks a Rhythm Copy invite as dismissed/read
  ///
  /// Copied from [dismissRhythmCopyInvite].
  const DismissRhythmCopyInviteFamily();

  /// Marks a Rhythm Copy invite as dismissed/read
  ///
  /// Copied from [dismissRhythmCopyInvite].
  DismissRhythmCopyInviteProvider call(
    String inviteId,
  ) {
    return DismissRhythmCopyInviteProvider(
      inviteId,
    );
  }

  @override
  DismissRhythmCopyInviteProvider getProviderOverride(
    covariant DismissRhythmCopyInviteProvider provider,
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
  String? get name => r'dismissRhythmCopyInviteProvider';
}

/// Marks a Rhythm Copy invite as dismissed/read
///
/// Copied from [dismissRhythmCopyInvite].
class DismissRhythmCopyInviteProvider extends AutoDisposeFutureProvider<void> {
  /// Marks a Rhythm Copy invite as dismissed/read
  ///
  /// Copied from [dismissRhythmCopyInvite].
  DismissRhythmCopyInviteProvider(
    String inviteId,
  ) : this._internal(
          (ref) => dismissRhythmCopyInvite(
            ref as DismissRhythmCopyInviteRef,
            inviteId,
          ),
          from: dismissRhythmCopyInviteProvider,
          name: r'dismissRhythmCopyInviteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dismissRhythmCopyInviteHash,
          dependencies: DismissRhythmCopyInviteFamily._dependencies,
          allTransitiveDependencies:
              DismissRhythmCopyInviteFamily._allTransitiveDependencies,
          inviteId: inviteId,
        );

  DismissRhythmCopyInviteProvider._internal(
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
    FutureOr<void> Function(DismissRhythmCopyInviteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DismissRhythmCopyInviteProvider._internal(
        (ref) => create(ref as DismissRhythmCopyInviteRef),
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
    return _DismissRhythmCopyInviteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DismissRhythmCopyInviteProvider &&
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
mixin DismissRhythmCopyInviteRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `inviteId` of this provider.
  String get inviteId;
}

class _DismissRhythmCopyInviteProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with DismissRhythmCopyInviteRef {
  _DismissRhythmCopyInviteProviderElement(super.provider);

  @override
  String get inviteId => (origin as DismissRhythmCopyInviteProvider).inviteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
