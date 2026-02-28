import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/word_chain/data/repositories/word_chain_repository_impl.dart';
import 'package:heartbit/features/games/word_chain/domain/entities/word_chain_session.dart';
import 'package:heartbit/features/games/word_chain/domain/repositories/word_chain_repository.dart';
import 'package:heartbit/features/games/word_chain/domain/utils/word_chain_validator.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';

final wordChainRepositoryProvider = Provider<WordChainRepository>((ref) {
  return WordChainRepositoryImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final activeWordChainSessionProvider =
    StreamProvider.autoDispose<WordChainSession?>((ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  final repository = ref.watch(wordChainRepositoryProvider);

  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream<WordChainSession?>.empty();
      return repository.watchSession(couple.id);
    },
    loading: () => const Stream<WordChainSession?>.empty(),
    error: (_, __) => const Stream<WordChainSession?>.empty(),
  );
});

class WordChainController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> enterGame(WordChainMode mode, {String? category}) async {
    if (state is AsyncLoading<void>) return;

    final couple = ref.read(coupleStateProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (couple == null || userId == null) {
      state = AsyncError('Cift bilgisi bulunamadi.', StackTrace.current);
      return;
    }

    final partnerId =
        userId == couple.user1Id ? couple.user2Id : couple.user1Id;

    state = const AsyncLoading();
    try {
      await ref.read(wordChainRepositoryProvider).enterGame(
            coupleId: couple.id,
            userId: userId,
            partnerId: partnerId,
            mode: mode,
            category: category,
          );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> startGame() async {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;
    if (session == null) return;

    await ref.read(wordChainRepositoryProvider).startGame(session.id);
  }

  Future<String?> submitWord(String word) async {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (session == null || userId == null) return 'Oyun bulunamadi';

    if (session.status != WordChainStatus.playing) {
      return 'Su an kelime gonderilemez';
    }

    if (session.currentTurnUserId != userId) {
      return 'Sira sende degil';
    }

    final validation = WordChainValidator.validate(word, session);
    if (validation != null) return validation;

    final success = await ref.read(wordChainRepositoryProvider).submitWord(
          sessionId: session.id,
          userId: userId,
          word: word,
        );

    if (!success) {
      return 'Kelime kabul edilmedi. Oyun bitmis olabilir.';
    }

    return null;
  }

  Future<String?> useJoker() async {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (session == null || userId == null) return 'Oyun bulunamadi';

    if (session.status != WordChainStatus.playing) {
      return 'Joker su an kullanilamaz';
    }

    if (session.currentTurnUserId != userId) {
      return 'Joker sadece kendi turunda kullanilabilir';
    }

    final remaining = session.jokersRemaining[userId] ?? 0;
    if (remaining <= 0) {
      return 'Joker hakkin kalmadi';
    }

    final success = await ref.read(wordChainRepositoryProvider).useJoker(
          sessionId: session.id,
          userId: userId,
        );

    if (!success) {
      return 'Joker kullanilamadi. Oyun durumu degismis olabilir.';
    }

    return null;
  }

  Future<void> timeoutCurrentTurn() async {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;
    if (session == null) return;

    await ref.read(wordChainRepositoryProvider).timeoutCurrentTurn(session.id);
  }

  Future<void> leaveGame() async {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;

    await ref.read(wordChainRepositoryProvider).leaveGame(
          sessionId: session.id,
          userId: userId,
        );
  }

  Future<void> restartGame(WordChainMode mode, {String? category}) async {
    final session = ref.read(activeWordChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;

    await ref.read(wordChainRepositoryProvider).restartGame(
          sessionId: session.id,
          userId: userId,
          mode: mode,
          category: category,
        );
  }
}

final wordChainControllerProvider =
    AsyncNotifierProvider<WordChainController, void>(WordChainController.new);
