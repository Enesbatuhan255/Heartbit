// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$emojiGameDataSourceHash() =>
    r'e497173acb0ab3acf44de9aec4d276d57e350e4f';

/// See also [emojiGameDataSource].
@ProviderFor(emojiGameDataSource)
final emojiGameDataSourceProvider =
    AutoDisposeProvider<EmojiGameRemoteDataSource>.internal(
  emojiGameDataSource,
  name: r'emojiGameDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emojiGameDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmojiGameDataSourceRef
    = AutoDisposeProviderRef<EmojiGameRemoteDataSource>;
String _$activeEmojiGameSessionHash() =>
    r'1eb04dc022f14a7b43e7f61b2dc6deb55681c602';

/// Active emoji game session for the current couple
///
/// Copied from [activeEmojiGameSession].
@ProviderFor(activeEmojiGameSession)
final activeEmojiGameSessionProvider =
    AutoDisposeStreamProvider<EmojiGameSession?>.internal(
  activeEmojiGameSession,
  name: r'activeEmojiGameSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeEmojiGameSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveEmojiGameSessionRef
    = AutoDisposeStreamProviderRef<EmojiGameSession?>;
String _$emojiGameControllerHash() =>
    r'8cc20528bae454aed5e9ae5ecc0dacbd525ed924';

/// See also [EmojiGameController].
@ProviderFor(EmojiGameController)
final emojiGameControllerProvider =
    AutoDisposeAsyncNotifierProvider<EmojiGameController, void>.internal(
  EmojiGameController.new,
  name: r'emojiGameControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emojiGameControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EmojiGameController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
