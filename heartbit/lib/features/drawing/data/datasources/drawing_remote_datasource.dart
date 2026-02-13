import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/features/drawing/domain/entities/drawing_session.dart';

abstract class DrawingRemoteDataSource {
  Future<DrawingSession> createSession({
    required String coupleId,
    required String drawerId,
    required String secretWord,
    bool skipPending = false,
  });

  Future<void> updateDrawing({
    required String sessionId,
    required List<DrawingPoint> points,
  });
  
  /// Marks drawing as finished, moving to guessing phase
  Future<void> finishDrawing(String sessionId);

  Stream<DrawingSession?> watchActiveSession(String coupleId);

  Future<bool> submitGuess({
    required String sessionId,
    required String guess,
  });
  
  Future<void> endSession(String sessionId);
  
  /// Cancel session explicitly (e.g. user left screen)
  Future<void> cancelSession(String sessionId);

  /// Accept session
  Future<void> acceptSession(String sessionId);
}

class DrawingRemoteDataSourceImpl implements DrawingRemoteDataSource {
  final FirebaseFirestore _firestore;

  DrawingRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _sessionsRef() {
    return _firestore.collection('drawing_sessions');
  }

  @override
  Future<DrawingSession> createSession({
    required String coupleId,
    required String drawerId,
    required String secretWord,
    bool skipPending = false,
  }) async {
    // GUARD 1: Check for any recent session (within 5 seconds) to prevent rapid creation
    // Using active=true filter instead of orderBy to avoid composite index requirement
    final recentSessions = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();
    
    if (recentSessions.docs.isNotEmpty) {
      final recentDoc = recentSessions.docs.first;
      final recentData = recentDoc.data();
      final createdAt = (recentData['createdAt'] as Timestamp?)?.toDate();
      
      if (createdAt != null) {
        final secondsSinceCreation = DateTime.now().difference(createdAt).inSeconds;
        // If session was created less than 5 seconds ago, return it (don't create new)
        if (secondsSinceCreation < 5) {
          print('[DrawingGame] createSession: Recent session exists (${recentDoc.id}, ${secondsSinceCreation}s ago), returning it');
          return DrawingSession(
            id: recentDoc.id,
            coupleId: recentData['coupleId'],
            drawerId: recentData['drawerId'],
            secretWord: recentData['secretWord'],
            status: recentData['status'],
            points: (recentData['points'] as List).map((p) => DrawingPoint.fromMap(p)).toList(),
            createdAt: createdAt,
            attempts: (recentData['attempts'] as List?)?.map((e) => e.toString()).toList() ?? [],
          );
        }
      }
    }
    
    // GUARD 2: Check if there's already an active non-solved, non-cancelled session
    final existingActive = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();
    
    if (existingActive.docs.isNotEmpty) {
      final existingDoc = existingActive.docs.first;
      final existingData = existingDoc.data();
      final existingStatus = existingData['status'] as String;
      
      // If there's an active session that's not solved/cancelled, return it
      if (existingStatus != 'solved' && existingStatus != 'cancelled') {
        print('[DrawingGame] createSession: Active session already exists (${existingDoc.id}, status=$existingStatus), returning existing');
        return DrawingSession(
          id: existingDoc.id,
          coupleId: existingData['coupleId'],
          drawerId: existingData['drawerId'],
          secretWord: existingData['secretWord'],
          status: existingStatus,
          points: (existingData['points'] as List).map((p) => DrawingPoint.fromMap(p)).toList(),
          createdAt: (existingData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          attempts: (existingData['attempts'] as List?)?.map((e) => e.toString()).toList() ?? [],
        );
      }
      
      // Deactivate solved/cancelled sessions
      await existingDoc.reference.update({'active': false});
    }
    
    final docRef = _sessionsRef().doc(); // Auto ID
    final now = DateTime.now();
    
    final initialStatus = skipPending ? 'drawing' : 'pending';
    
    final session = DrawingSession(
      id: docRef.id,
      coupleId: coupleId,
      drawerId: drawerId,
      secretWord: secretWord,
      status: initialStatus,
      points: const [],
      createdAt: now,
    );

    await docRef.set({
      'id': session.id,
      'coupleId': session.coupleId,
      'drawerId': session.drawerId,
      'secretWord': session.secretWord,
      'status': session.status,
      'points': [],
      'createdAt': FieldValue.serverTimestamp(),
      'attempts': [],
      'active': true, 
    });

    print('[DrawingGame] createSession: Created new session ${session.id} with word ${session.secretWord}');
    return session;
  }

  @override
  Future<void> updateDrawing({
    required String sessionId,
    required List<DrawingPoint> points,
  }) async {
    final pointsData = points.map((p) => p.toMap()).toList();
    await _sessionsRef().doc(sessionId).update({
      'points': pointsData,
    });
  }

  @override
  Future<void> finishDrawing(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'guessing',
      'drawingCompletedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<DrawingSession?> watchActiveSession(String coupleId) {
    print('[DrawingGame] watchActiveSession: Starting watch for coupleId=$coupleId');
    return _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .snapshots()
        .handleError((error) {
          print('[DrawingGame] watchActiveSession ERROR: $error');
        })
        .map((snapshot) {
          print('[DrawingGame] watchActiveSession: Got ${snapshot.docs.length} docs');
          if (snapshot.docs.isEmpty) {
            print('[DrawingGame] watchActiveSession: No active session found');
            return null;
          }
          final doc = snapshot.docs.first;
          final data = doc.data();
          print('[DrawingGame] watchActiveSession: Found session ${doc.id}, status=${data['status']}');
          
          return DrawingSession(
            id: doc.id,
            coupleId: data['coupleId'],
            drawerId: data['drawerId'],
            secretWord: data['secretWord'],
            status: data['status'],
            points: (data['points'] as List).map((p) => DrawingPoint.fromMap(p)).toList(),
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            attempts: (data['attempts'] as List?)?.map((e) => e.toString()).toList() ?? [],
            drawingCompletedAt: (data['drawingCompletedAt'] as Timestamp?)?.toDate(),
          );
        });
  }

  @override
  Future<bool> submitGuess({
    required String sessionId,
    required String guess,
  }) async {
    return _firestore.runTransaction((tx) async {
      final docRef = _sessionsRef().doc(sessionId);
      
      // ===== ALL READS FIRST =====
      final snapshot = await tx.get(docRef);
      
      if (!snapshot.exists) {
        print('[DrawingGame] submitGuess: session not found');
        return false;
      }
      
      final data = snapshot.data()!;
      if (data['status'] == 'solved') {
        print('[DrawingGame] submitGuess: already solved');
        return true; 
      }
      
      // Pre-read pet document in case we need it
      final coupleId = data['coupleId'];
      final petRef = _firestore.collection('pets').doc(coupleId);
      final petSnap = await tx.get(petRef);
      
      // Normalization Helper for Turkish Characters
      String normalize(String input) {
        return input.toLowerCase()
            .trim()
            // Lowercase Turkish
            .replaceAll('ı', 'i')
            .replaceAll('ğ', 'g')
            .replaceAll('ü', 'u')
            .replaceAll('ş', 's')
            .replaceAll('ö', 'o')
            .replaceAll('ç', 'c')
            // Uppercase Turkish (in case toLowerCase didn't handle them)
            .replaceAll('İ', 'i')
            .replaceAll('I', 'i')
            .replaceAll('Ğ', 'g')
            .replaceAll('Ü', 'u')
            .replaceAll('Ş', 's')
            .replaceAll('Ö', 'o')
            .replaceAll('Ç', 'c');
      }

      final secret = normalize(data['secretWord'] as String);
      final userGuess = normalize(guess);
      
      print('[DrawingGame] submitGuess: secret="$secret", userGuess="$userGuess", match=${secret == userGuess}');
      
      // ===== ALL WRITES AFTER READS =====
      if (secret == userGuess) {
        print('[DrawingGame] submitGuess: CORRECT! Updating status to solved');
        // Keep active=true so solved screen can be shown
        // Will be set to false when new game starts
        tx.update(docRef, {
          'status': 'solved',
        });
        
        if (petSnap.exists) {
          final curXp = petSnap.data()?['experience'] ?? 0;
          tx.update(petRef, {'experience': curXp + 50});
        }
        
        return true;
      } else {
        print('[DrawingGame] submitGuess: WRONG! Adding to attempts');
        tx.update(docRef, {
          'attempts': FieldValue.arrayUnion([guess]),
        });
        return false;
      }
    });
  }
  
  @override
  Future<void> endSession(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({'active': false});
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'active': false, // Deactivate so new games can start fresh
      'status': 'cancelled',
    });
  }

  @override
  Future<void> acceptSession(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'drawing',
    });
  }
}
