// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_game_invite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$emojiGameInvitesHash() => r'a7ee4e8f2f5782945f7f33da1d62dcd9cbe033a6';

/// Watches for Emoji Game invitations for the current user
///
/// Copied from [emojiGameInvites].
@ProviderFor(emojiGameInvites)
final emojiGameInvitesProvider =
    AutoDisposeStreamProvider<List<EmojiGameInvite>>.internal(
  emojiGameInvites,
  name: r'emojiGameInvitesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emojiGameInvitesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmojiGameInvitesRef
    = AutoDisposeStreamProviderRef<List<EmojiGameInvite>>;
String _$dismissEmojiGameInviteHash() =>
    r'35634b3081ddf541779589fef6b3cec51df400ba';

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

/// Marks an Emoji Game invite as dismissed/read
///
/// Copied from [dismissEmojiGameInvite].
@ProviderFor(dismissEmojiGameInvite)
const dismissEmojiGameInviteProvider = DismissEmojiGameInviteFamily();

/// Marks an Emoji Game invite as dismissed/read
///
/// Copied from [dismissEmojiGameInvite].
class DismissEmojiGameInviteFamily extends Family<AsyncValue<void>> {
  /// Marks an Emoji Game invite as dismissed/read
  ///
  /// Copied from [dismissEmojiGameInvite].
  const DismissEmojiGameInviteFamily();

  /// Marks an Emoji Game invite as dismissed/read
  ///
  /// Copied from [dismissEmojiGameInvite].
  DismissEmojiGameInviteProvider call(
    String inviteId,
  ) {
    return DismissEmojiGameInviteProvider(
      inviteId,
    );
  }

  @override
  DismissEmojiGameInviteProvider getProviderOverride(
    covariant DismissEmojiGameInviteProvider provider,
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
  String? get name => r'dismissEmojiGameInviteProvider';
}

/// Marks an Emoji Game invite as dismissed/read
///
/// Copied from [dismissEmojiGameInvite].
class DismissEmojiGameInviteProvider extends AutoDisposeFutureProvider<void> {
  /// Marks an Emoji Game invite as dismissed/read
  ///
  /// Copied from [dismissEmojiGameInvite].
  DismissEmojiGameInviteProvider(
    String inviteId,
  ) : this._internal(
          (ref) => dismissEmojiGameInvite(
            ref as DismissEmojiGameInviteRef,
            inviteId,
          ),
          from: dismissEmojiGameInviteProvider,
          name: r'dismissEmojiGameInviteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dismissEmojiGameInviteHash,
          dependencies: DismissEmojiGameInviteFamily._dependencies,
          allTransitiveDependencies:
              DismissEmojiGameInviteFamily._allTransitiveDependencies,
          inviteId: inviteId,
        );

  DismissEmojiGameInviteProvider._internal(
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
    FutureOr<void> Function(DismissEmojiGameInviteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DismissEmojiGameInviteProvider._internal(
        (ref) => create(ref as DismissEmojiGameInviteRef),
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
    return _DismissEmojiGameInviteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DismissEmojiGameInviteProvider &&
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
mixin DismissEmojiGameInviteRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `inviteId` of this provider.
  String get inviteId;
}

class _DismissEmojiGameInviteProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with DismissEmojiGameInviteRef {
  _DismissEmojiGameInviteProviderElement(super.provider);

  @override
  String get inviteId => (origin as DismissEmojiGameInviteProvider).inviteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
