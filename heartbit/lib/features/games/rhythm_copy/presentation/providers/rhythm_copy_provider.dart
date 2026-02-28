import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/games/rhythm_copy/data/datasources/rhythm_copy_remote_datasource.dart';
import 'package:heartbit/features/games/rhythm_copy/domain/entities/rhythm_copy_session.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';

final rhythmCopyDataSourceProvider =
    Provider<RhythmCopyRemoteDataSource>((ref) {
  return RhythmCopyRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final activeRhythmCopySessionProvider =
    StreamProvider<RhythmCopySession?>((ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  final dataSource = ref.watch(rhythmCopyDataSourceProvider);

  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream<RhythmCopySession?>.empty();
      return dataSource.watchActiveSession(couple.id);
    },
    loading: () => const Stream<RhythmCopySession?>.empty(),
    error: (_, __) => const Stream<RhythmCopySession?>.empty(),
  );
});

class RhythmCopyController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> enterGame() async {
    if (state is AsyncLoading<void>) return;

    final couple = ref.read(coupleStateProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    if (couple == null || userId == null) {
      state = AsyncError('Couple info not found.', StackTrace.current);
      return;
    }

    final partnerId =
        userId == couple.user1Id ? couple.user2Id : couple.user1Id;

    state = const AsyncLoading();
    try {
      await ref.read(rhythmCopyDataSourceProvider).createSession(
            coupleId: couple.id,
            startingUserId: userId,
            partnerId: partnerId,
          );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      developer.log('[RhythmCopy] enterGame error: $error',
          stackTrace: stackTrace);
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> startGame() async {
    final session = ref.read(activeRhythmCopySessionProvider).valueOrNull;
    if (session == null) return;
    if (!session.bothReady || session.status != 'waiting') return;
    await ref.read(rhythmCopyDataSourceProvider).startGame(session.id);
  }

  Future<void> submitPattern(
      List<int> pattern, List<int> patternTimingsMs) async {
    final session = ref.read(activeRhythmCopySessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;
    await ref.read(rhythmCopyDataSourceProvider).submitPattern(
          sessionId: session.id,
          composerId: userId,
          pattern: pattern,
          patternTimingsMs: patternTimingsMs,
        );
  }

  Future<void> submitCopy(
      List<int> copyInput, List<int> copyInputTimingsMs) async {
    final session = ref.read(activeRhythmCopySessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;
    await ref.read(rhythmCopyDataSourceProvider).submitCopy(
          sessionId: session.id,
          copyUserId: userId,
          copyInput: copyInput,
          copyInputTimingsMs: copyInputTimingsMs,
        );
  }

  Future<void> nextRound() async {
    final session = ref.read(activeRhythmCopySessionProvider).valueOrNull;
    if (session == null) return;
    await ref.read(rhythmCopyDataSourceProvider).nextRound(session.id);
  }

  Future<void> sendReaction(String emoji) async {
    final session = ref.read(activeRhythmCopySessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;
    await ref.read(rhythmCopyDataSourceProvider).sendReaction(
          sessionId: session.id,
          userId: userId,
          emoji: emoji,
        );
  }

  Future<void> leaveGame() async {
    final session = ref.read(activeRhythmCopySessionProvider).valueOrNull;
    if (session == null) return;
    await ref.read(rhythmCopyDataSourceProvider).cancelSession(session.id);
  }

  Future<void> restartGame() async {
    final session = ref.read(activeRhythmCopySessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    if (session == null || userId == null) return;
    await ref.read(rhythmCopyDataSourceProvider).resetSession(
          sessionId: session.id,
          userId: userId,
        );
  }
}

final rhythmCopyControllerProvider =
    AsyncNotifierProvider<RhythmCopyController, void>(
  RhythmCopyController.new,
);
