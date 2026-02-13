import 'dart:async';
import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/games/stack_tower/domain/entities/stacked_block.dart';
import 'package:heartbit/features/games/stack_tower/data/datasources/stack_tower_remote_datasource.dart';

part 'stack_tower_provider.g.dart';

// --- DI ---
@riverpod
StackTowerRemoteDataSource stackTowerDataSource(StackTowerDataSourceRef ref) {
  return StackTowerRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

// --- State ---

/// Active stack tower session for the current couple
@riverpod
Stream<StackTowerSession?> activeStackTowerSession(ActiveStackTowerSessionRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream.empty();
      return ref.watch(stackTowerDataSourceProvider).watchActiveSession(couple.id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

// --- Controller ---

@riverpod
class StackTowerController extends _$StackTowerController {
  @override
  FutureOr<void> build() {}

  /// Create or join a game session (enters waiting room)
  Future<void> enterGame() async {
    if (state is AsyncLoading) {
      developer.log('[StackTower] enterGame() skipped - already loading');
      return;
    }

    final couple = ref.read(coupleStateProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);

    developer.log('[StackTower] enterGame() called - userId: $userId, couple: ${couple?.id}');

    if (couple == null || userId == null) {
      developer.log('[StackTower] enterGame() failed - couple or userId is null');
      state = AsyncError('Çift bilgisi bulunamadı.', StackTrace.current);
      return;
    }

    // Calculate partner ID
    final partnerId = userId == couple.user1Id ? couple.user2Id : couple.user1Id;

    state = const AsyncLoading();
    try {
      // CreateSession will either create new or join existing waiting session
      await ref.read(stackTowerDataSourceProvider).createSession(
        coupleId: couple.id,
        startingUserId: userId,
        partnerId: partnerId,
      );
      developer.log('[StackTower] enterGame() completed successfully');
      state = const AsyncData(null);
    } catch (e, st) {
      developer.log('[StackTower] enterGame() error: $e');
      state = AsyncError(e, st);
    }
  }

  /// Called when both users are ready - starts the game
  Future<void> startGame() async {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    if (session != null && session.bothReady && session.status == 'waiting') {
      await ref.read(stackTowerDataSourceProvider).startGame(session.id);
    }
  }

  /// Place a block at the current position
  Future<bool> placeBlock({
    required double leftRatio,
    required double widthRatio,
  }) async {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    final couple = ref.read(coupleStateProvider).valueOrNull;

    if (session == null || userId == null || couple == null) return false;

    // Verify it's this user's turn
    if (session.currentTurnUserId != userId) {
      return false;
    }

    // Get the top block
    final topBlock = session.blocks.last;

    // Calculate overlap
    final newRight = leftRatio + widthRatio;
    final topRight = topBlock.leftRatio + topBlock.widthRatio;
    
    final overlapLeft = leftRatio > topBlock.leftRatio ? leftRatio : topBlock.leftRatio;
    final overlapRight = newRight < topRight ? newRight : topRight;
    final overlapWidth = overlapRight - overlapLeft;

    if (overlapWidth <= 0.01) {
      // Complete miss - game over
      // Wait for animation to finish
      await Future.delayed(const Duration(seconds: 1));
      
      await ref.read(stackTowerDataSourceProvider).endGame(
        session.id,
        session.score,
      );
      return false;
    }

    // Create the new stacked block
    final newBlock = StackedBlock(
      leftRatio: overlapLeft,
      widthRatio: overlapWidth,
      index: session.blocks.length,
      placedBy: userId,
      colorIndex: session.blocks.length % 8,
    );

    // Switch turn to partner
    final nextTurn = userId == couple.user1Id ? couple.user2Id : couple.user1Id;
    
    // Increase speed
    final newSpeed = (session.speed + 0.08).clamp(1.0, 4.0);

    // Check if block is too small
    if (overlapWidth < 0.05) {
      // Too small - game over
      // Wait for animation to finish
      await Future.delayed(const Duration(seconds: 1));
      
      await ref.read(stackTowerDataSourceProvider).endGame(
        session.id,
        session.score + 1,
      );
      return false;
    }

    try {
      await ref.read(stackTowerDataSourceProvider).placeBlock(
        sessionId: session.id,
        block: newBlock,
        nextTurnUserId: nextTurn,
        newSpeed: newSpeed,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Leave/cancel the game - resets for both users
  Future<void> leaveGame() async {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    if (session != null) {
      await ref.read(stackTowerDataSourceProvider).cancelSession(session.id);
    }
  }

  /// Restart the game (Play Again) - keeps session active but resets state
  Future<void> restartGame() async {
    final session = ref.read(activeStackTowerSessionProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    
    if (session != null && userId != null) {
      await ref.read(stackTowerDataSourceProvider).resetSession(
        sessionId: session.id,
        userId: userId,
      );
    }
  }
}
