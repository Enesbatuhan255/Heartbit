import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';
import 'package:heartbit/features/drawing/domain/repositories/drawing_repository.dart';
import 'package:heartbit/features/drawing/data/datasources/drawing_remote_datasource.dart';

class DrawingRepositoryImpl implements DrawingRepository {
  final DrawingRemoteDataSource _remoteDataSource;

  DrawingRepositoryImpl({required DrawingRemoteDataSource remoteDataSource}) 
      : _remoteDataSource = remoteDataSource;

  @override
  Future<DrawingSession> createSession({
    required String coupleId,
    required String drawerId,
    required String secretWord,
    bool skipPending = false,
  }) {
    return _remoteDataSource.createSession(
      coupleId: coupleId,
      drawerId: drawerId,
      secretWord: secretWord,
      skipPending: skipPending,
    );
  }

  @override
  Future<void> updateDrawing({
    required String sessionId,
    required List<DrawingPoint> points,
  }) {
    return _remoteDataSource.updateDrawing(
      sessionId: sessionId,
      points: points,
    );
  }

  @override
  Future<void> finishDrawing(String sessionId) {
    return _remoteDataSource.finishDrawing(sessionId);
  }

  @override
  Stream<DrawingSession?> watchActiveSession(String coupleId) {
    return _remoteDataSource.watchActiveSession(coupleId);
  }

  @override
  Future<bool> submitGuess({
    required String sessionId,
    required String guess,
  }) {
    return _remoteDataSource.submitGuess(
      sessionId: sessionId,
      guess: guess,
    );
  }
  
  @override
  Future<void> endSession(String sessionId) {
    return _remoteDataSource.endSession(sessionId);
  }

  @override
  Future<void> cancelSession(String sessionId) {
    return _remoteDataSource.cancelSession(sessionId);
  }

  @override
  Future<void> acceptSession(String sessionId) {
    return _remoteDataSource.acceptSession(sessionId);
  }
}
