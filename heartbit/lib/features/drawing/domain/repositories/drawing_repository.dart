import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';

abstract class DrawingRepository {
  /// Start a new game session
  /// If skipPending is true, start directly in 'drawing' status (for continued games)
  Future<DrawingSession> createSession({
    required String coupleId,
    required String drawerId,
    required String secretWord,
    bool skipPending = false,
  });

  /// Submit drawing points (updates the session)
  Future<void> updateDrawing({
    required String sessionId,
    required List<DrawingPoint> points,
  });

  /// Marks drawing as finished
  Future<void> finishDrawing(String sessionId);

  /// Watch active session for a couple
  Stream<DrawingSession?> watchActiveSession(String coupleId);

  /// Submit a guess
  Future<bool> submitGuess({
    required String sessionId,
    required String guess,
  });
  
  /// End/Skip session
  /// End/Skip session
  Future<void> endSession(String sessionId);

  /// Cancel/Abort session
  Future<void> cancelSession(String sessionId);

  /// Accept invitation
  Future<void> acceptSession(String sessionId);
}
