import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/story_chain/data/repositories/story_chain_repository_impl.dart';
import 'package:heartbit/features/games/story_chain/domain/entities/story_chain_session.dart';
import 'package:heartbit/features/games/story_chain/domain/repositories/story_chain_repository.dart';
import 'package:heartbit/features/games/story_chain/domain/utils/story_chain_validator.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';

final storyChainRepositoryProvider = Provider<StoryChainRepository>((ref) {
  return StoryChainRepositoryImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final activeStoryChainSessionProvider =
    StreamProvider.autoDispose<StoryChainSession?>((ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  final repository = ref.watch(storyChainRepositoryProvider);

  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream<StoryChainSession?>.empty();
      return repository.watchSession(couple.id);
    },
    loading: () => const Stream<StoryChainSession?>.empty(),
    error: (_, __) => const Stream<StoryChainSession?>.empty(),
  );
});

class StoryChainController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> enterGame(StoryMode mode) async {
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
      await ref.read(storyChainRepositoryProvider).enterGame(
            coupleId: couple.id,
            userId: userId,
            partnerId: partnerId,
            mode: mode,
          );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> startGame() async {
    final session = ref.read(activeStoryChainSessionProvider).valueOrNull;
    if (session == null) return;

    await ref.read(storyChainRepositoryProvider).startGame(session.id);
  }

  Future<String?> submitTurn(String text) async {
    final session = ref.read(activeStoryChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (session == null || userId == null) return 'Oyun bulunamadi';

    if (session.status != StoryStatus.playing) {
      return 'Su an metin gonderilemez';
    }

    if (session.currentTurnUserId != userId) {
      return 'Sira sende degil';
    }

    final validation = StoryChainValidator.validateTurn(text, session);
    if (validation != null) return validation;

    final success = await ref.read(storyChainRepositoryProvider).submitTurn(
          sessionId: session.id,
          userId: userId,
          text: text,
        );

    if (!success) {
      return 'Metin kaydedilemedi. Oyun durumu degismis olabilir.';
    }

    return null;
  }

  Future<String?> passTurn() async {
    final session = ref.read(activeStoryChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (session == null || userId == null) return 'Oyun bulunamadi';

    if (session.status != StoryStatus.playing) {
      return 'Pas su an kullanilamaz';
    }

    if (session.currentTurnUserId != userId) {
      return 'Pas sadece kendi turunda kullanilabilir';
    }

    final success = await ref.read(storyChainRepositoryProvider).passTurn(
          sessionId: session.id,
          userId: userId,
        );

    if (!success) {
      return 'Pas gecilemedi. Oyun durumu degismis olabilir.';
    }

    return null;
  }

  Future<String?> endGame() async {
    final session = ref.read(activeStoryChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (session == null || userId == null) return 'Oyun bulunamadi';

    if (session.status != StoryStatus.playing &&
        session.status != StoryStatus.waiting) {
      return 'Oyun zaten tamamlandi';
    }

    final success = await ref.read(storyChainRepositoryProvider).endGame(
          sessionId: session.id,
          userId: userId,
        );

    if (!success) {
      return 'Oyun bitirilemedi. Tekrar dene.';
    }

    return null;
  }

  Future<void> leaveGame() async {
    final session = ref.read(activeStoryChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;

    await ref.read(storyChainRepositoryProvider).leaveGame(
          sessionId: session.id,
          userId: userId,
        );
  }

  Future<void> restartGame(StoryMode mode) async {
    final session = ref.read(activeStoryChainSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;

    await ref.read(storyChainRepositoryProvider).restartGame(
          sessionId: session.id,
          userId: userId,
          mode: mode,
        );
  }
}

final storyChainControllerProvider =
    AsyncNotifierProvider<StoryChainController, void>(StoryChainController.new);
