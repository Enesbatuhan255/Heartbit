import 'package:heartbit/features/games/word_chain/domain/entities/word_chain_session.dart';

abstract class WordChainRepository {
  Stream<WordChainSession?> watchSession(String coupleId);

  Future<void> enterGame({
    required String coupleId,
    required String userId,
    required String partnerId,
    required WordChainMode mode,
    String? category,
  });

  Future<bool> startGame(String sessionId);

  Future<bool> submitWord({
    required String sessionId,
    required String userId,
    required String word,
  });

  Future<bool> useJoker({
    required String sessionId,
    required String userId,
  });

  Future<void> timeoutCurrentTurn(String sessionId);

  Future<void> leaveGame({
    required String sessionId,
    required String userId,
  });

  Future<void> restartGame({
    required String sessionId,
    required String userId,
    required WordChainMode mode,
    String? category,
  });
}
