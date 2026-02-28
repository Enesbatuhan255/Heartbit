import 'package:heartbit/features/games/story_chain/domain/entities/story_chain_session.dart';

abstract class StoryChainRepository {
  Stream<StoryChainSession?> watchSession(String coupleId);

  Future<void> enterGame({
    required String coupleId,
    required String userId,
    required String partnerId,
    required StoryMode mode,
  });

  Future<bool> startGame(String sessionId);

  Future<bool> submitTurn({
    required String sessionId,
    required String userId,
    required String text,
  });

  Future<bool> passTurn({
    required String sessionId,
    required String userId,
  });

  Future<bool> endGame({
    required String sessionId,
    required String userId,
  });

  Future<void> leaveGame({
    required String sessionId,
    required String userId,
  });

  Future<void> restartGame({
    required String sessionId,
    required String userId,
    required StoryMode mode,
  });
}
