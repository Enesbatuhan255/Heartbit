import 'dart:async';
import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/games/emoji_game/domain/entities/emoji_game_session.dart';
import 'package:heartbit/features/games/emoji_game/data/datasources/emoji_game_remote_datasource.dart';

part 'emoji_game_provider.g.dart';

// --- DI ---
@riverpod
EmojiGameRemoteDataSource emojiGameDataSource(EmojiGameDataSourceRef ref) {
  return EmojiGameRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

// --- State ---

/// Active emoji game session for the current couple
@riverpod
Stream<EmojiGameSession?> activeEmojiGameSession(ActiveEmojiGameSessionRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream.empty();
      return ref.watch(emojiGameDataSourceProvider).watchActiveSession(couple.id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

// --- Controller ---

@riverpod
class EmojiGameController extends _$EmojiGameController {
  @override
  FutureOr<void> build() {}

  /// Create or join a game session (enters waiting room)
  Future<void> enterGame() async {
    if (state is AsyncLoading) return;

    final couple = ref.read(coupleStateProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (couple == null || userId == null) {
      state = AsyncError('Çift bilgisi bulunamadı.', StackTrace.current);
      return;
    }

    final partnerId = userId == couple.user1Id ? couple.user2Id : couple.user1Id;

    state = const AsyncLoading();
    try {
      await ref.read(emojiGameDataSourceProvider).createSession(
        coupleId: couple.id,
        startingUserId: userId,
        partnerId: partnerId,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      developer.log('[EmojiGame] enterGame error: $e');
      state = AsyncError(e, st);
    }
  }

  /// Called when both users are ready - starts the game
  Future<void> startGame() async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;
    if (session != null && session.bothReady && session.status == 'waiting') {
      await ref.read(emojiGameDataSourceProvider).startGame(session.id);
    }
  }

  /// Send emojis for the current round
  Future<void> sendEmojis(String emojis) async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;
    if (session == null) return;

    await ref.read(emojiGameDataSourceProvider).sendEmojis(
      sessionId: session.id,
      emojis: emojis,
    );
  }

  /// Submit a guess
  Future<bool> submitGuess(String guess) async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;
    if (session == null) return false;

    return await ref.read(emojiGameDataSourceProvider).submitGuess(
      sessionId: session.id,
      guess: guess,
    );
  }

  /// Skip current round
  Future<void> skipRound() async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;
    if (session == null) return;

    await ref.read(emojiGameDataSourceProvider).skipRound(session.id);
  }

  /// Move to next round (swap roles)
  Future<void> nextRound() async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;
    if (session == null) return;

    if (session.round >= session.maxRounds) {
      // Game over
      await ref.read(emojiGameDataSourceProvider).endGame(session.id);
      return;
    }

    // Swap roles
    await ref.read(emojiGameDataSourceProvider).nextRound(
      sessionId: session.id,
      newSenderId: session.guesserId,
      newGuesserId: session.senderId,
    );
  }

  /// Leave/cancel the game
  Future<void> leaveGame() async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;
    if (session != null) {
      await ref.read(emojiGameDataSourceProvider).cancelSession(session.id);
    }
  }

  /// Restart the game (Play Again)
  Future<void> restartGame() async {
    final session = ref.read(activeEmojiGameSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (session != null && userId != null) {
      await ref.read(emojiGameDataSourceProvider).resetSession(
        sessionId: session.id,
        userId: userId,
      );
    }
  }
}
