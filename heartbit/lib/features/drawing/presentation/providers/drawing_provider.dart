import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';
import 'package:heartbit/features/drawing/domain/repositories/drawing_repository.dart';
import 'package:heartbit/features/drawing/data/datasources/drawing_remote_datasource.dart';
import 'package:heartbit/features/drawing/data/repositories/drawing_repository_impl.dart';

part 'drawing_provider.g.dart';

// --- DI ---
@riverpod
DrawingRemoteDataSource drawingRemoteDataSource(DrawingRemoteDataSourceRef ref) {
  return DrawingRemoteDataSourceImpl(firestore: ref.watch(firebaseFirestoreProvider));
}

@riverpod
DrawingRepository drawingRepository(DrawingRepositoryRef ref) {
  return DrawingRepositoryImpl(remoteDataSource: ref.watch(drawingRemoteDataSourceProvider));
}

// --- State ---

/// Active drawing session for the current couple (if any)
@riverpod
Stream<DrawingSession?> activeDrawingSession(ActiveDrawingSessionRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) {
        print('[DrawingGame] activeDrawingSession: couple is null');
        return const Stream.empty();
      }
      print('[DrawingGame] activeDrawingSession: watching coupleId=${couple.id}');
      return ref.watch(drawingRepositoryProvider).watchActiveSession(couple.id).map((session) {
        print('[DrawingGame] activeDrawingSession stream emitted: ${session?.id ?? "null"}, status: ${session?.status ?? "N/A"}');
        return session;
      });
    },
    loading: () {
      print('[DrawingGame] activeDrawingSession: couple is loading');
      return const Stream.empty();
    },
    error: (e, __) {
      print('[DrawingGame] activeDrawingSession: couple error: $e');
      return const Stream.empty();
    },
  );
}

// --- Logic ---

const _words = ['Kedi', 'Köpek', 'Ev', 'Araba', 'Güneş', 'Pizza', 'Dondurma', 'Kalp', 'Ağaç', 'Çiçek', 'Balık', 'Yıldız', 'Telefon', 'Gözlük', 'Kitap'];

@riverpod
class DrawingGameController extends _$DrawingGameController {
  @override
  FutureOr<void> build() {}

  /// Start a new game - if previousDrawerId is provided, the other person becomes the drawer
  Future<void> startGame({String? previousDrawerId}) async {
    // Guard: prevent concurrent calls
    if (state is AsyncLoading) {
      print('[DrawingGame] startGame: Already in progress, skipping');
      return;
    }

    // Guard: check if there's already an active session (avoid race condition)
    final existingSession = ref.read(activeDrawingSessionProvider).valueOrNull;
    if (existingSession != null && existingSession.status != 'solved' && existingSession.status != 'cancelled') {
      print('[DrawingGame] startGame: Active session already exists (${existingSession.id}), skipping');
      return;
    }

    final couple = ref.read(coupleStateProvider).valueOrNull;
    final userId = ref.read(authUserIdProvider);
    
    // Debug logging
    print('[DrawingGame] startGame called with previousDrawerId: $previousDrawerId');
    print('[DrawingGame] couple: $couple');
    print('[DrawingGame] userId: $userId');
    
    if (couple == null) {
      print('[DrawingGame] ERROR: couple is null!');
      state = AsyncError('Çift bilgisi bulunamadı. Lütfen tekrar deneyin.', StackTrace.current);
      return;
    }
    
    if (userId == null) {
      print('[DrawingGame] ERROR: userId is null!');
      state = AsyncError('Kullanıcı girişi gerekli.', StackTrace.current);
      return;
    }

    // Determine the new drawer - swap roles from previous game
    String newDrawerId;
    if (previousDrawerId != null) {
      // The person who was NOT the drawer last time becomes the drawer
      if (previousDrawerId == couple.user1Id) {
        newDrawerId = couple.user2Id;
      } else {
        newDrawerId = couple.user1Id;
      }
    } else {
      // First game - current user is the drawer
      newDrawerId = userId;
    }
    
    print('[DrawingGame] New drawer will be: $newDrawerId');

    state = const AsyncLoading();
    
    // Pick random word
    final word = _words[Random().nextInt(_words.length)];
    print('[DrawingGame] Creating session with word: $word, coupleId: ${couple.id}, skipPending: ${previousDrawerId != null}');

    try {
      await ref.read(drawingRepositoryProvider).createSession(
        coupleId: couple.id,
        drawerId: newDrawerId,
        secretWord: word,
        skipPending: previousDrawerId != null, // Skip pending phase for continued games
      );
      print('[DrawingGame] Session created successfully!');
      state = const AsyncData(null);
    } catch (e, st) {
      print('[DrawingGame] ERROR creating session: $e');
      state = AsyncError(e, st);
    }
  }

  /// Update drawing (throttled ideally, but direct for now)
  Future<void> updateDrawing(String sessionId, List<DrawingPoint> points) async {
    // Only update firebase periodically or on end of stroke to save writes
    // For simplicity: Update entirely on every stroke endpoint? 
    // Let's assume the UI calls this intelligently.
    try {
      await ref.read(drawingRepositoryProvider).updateDrawing(
        sessionId: sessionId,
        points: points,
      );
    } catch (_) {
      // Ignore transient errors
    }
  }

  Future<void> finishDrawing(String sessionId) async {
    await ref.read(drawingRepositoryProvider).finishDrawing(sessionId);
  }

  /// Submit guess
  Future<bool> submitGuess(String sessionId, String guess) async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(drawingRepositoryProvider).submitGuess(
        sessionId: sessionId,
        guess: guess,
      );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> cancelSession(String sessionId) async {
    await ref.read(drawingRepositoryProvider).cancelSession(sessionId);
  }

  Future<void> acceptSession(String sessionId) async {
    await ref.read(drawingRepositoryProvider).acceptSession(sessionId);
  }
}
