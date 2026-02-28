import 'dart:developer' as developer;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/features/games/emoji_game/domain/entities/emoji_game_session.dart';

/// Word list — popular movies, TV shows & cultural references
const emojiGameWords = [
  // 🎬 Dünyaca ünlü filmler
  'Titanic', 'Harry Potter', 'Yüzüklerin Efendisi', 'Star Wars',
  'Matrix', 'Joker', 'Inception', 'Forrest Gump',
  'Jurassic Park', 'Avatar', 'Interstellar', 'Gladyatör',
  'Buz Devri', 'Aslan Kral', 'Yıldız Savaşları', 'Örümcek Adam',
  'Batman', 'Superman', 'Iron Man', 'Avengers',
  'Kayıp Balık Nemo', 'Yukarı Bak', 'Coco', 'Ratatouille',
  'Shrek', 'Kung Fu Panda', 'Madagaskar', 'Toy Story',
  'Passengers', 'Gravity', 'Uzay Yolu', 'Terminatör',
  'Rocky', 'Rambo', 'Mission Impossible', 'James Bond',
  'Fast and Furious', 'Transformers', 'Godzilla', 'King Kong',
  'Korkunç Film', 'Altıncı His', 'Sessiz Bir Yer', 'It',
  'Matriks', 'Yağmur Adam', 'Yeşil Yol', 'Esaretin Bedeli',

  // 📺 Popüler diziler
  'Stranger Things', 'Breaking Bad', 'Game of Thrones',
  'Money Heist', 'Squid Game', 'Wednesday', 'The Witcher',
  'Friends', 'The Office', 'Peaky Blinders',
  'Dark', 'Black Mirror', 'Narcos', 'Vikings',
  'The Walking Dead', 'Lost', 'Prison Break', 'Lucifer',
  'Sherlock', 'Mr. Robot', 'Dexter', 'Hannibal',

  // 🇹🇷 Türk dizileri & filmleri
  'Kurtlar Vadisi', 'Hababam Sınıfı', 'Recep İvedik',
  'Ezel', 'Çukur', 'Muhteşem Yüzyıl', 'Diriliş Ertuğrul',
  'Avrupa Yakası', 'Leyla ile Mecnun', 'Behzat Ç',
  'Arka Sokaklar', 'İçerde', 'Adını Feriha Koydum',
  'Babam ve Oğlum', 'Ayla', 'Kış Uykusu', 'Nuri Bilge Ceylan',
  'G.O.R.A.', 'A.R.O.G.', 'Dağ', 'Müslüm',
  'Organize İşler', 'Kolpaçino', 'Eyyvah Eyvah',
];


abstract class EmojiGameRemoteDataSource {
  Future<EmojiGameSession> createSession({
    required String coupleId,
    required String startingUserId,
    required String partnerId,
  });

  Future<void> startGame(String sessionId);

  Future<void> sendEmojis({
    required String sessionId,
    required String emojis,
  });

  Future<bool> submitGuess({
    required String sessionId,
    required String guess,
  });

  Future<void> nextRound({
    required String sessionId,
    required String newSenderId,
    required String newGuesserId,
  });

  Future<void> endGame(String sessionId);

  Stream<EmojiGameSession?> watchActiveSession(String coupleId);

  Future<void> cancelSession(String sessionId);

  Future<void> resetSession({
    required String sessionId,
    required String userId,
  });

  Future<void> skipRound(String sessionId);
}

class EmojiGameRemoteDataSourceImpl implements EmojiGameRemoteDataSource {
  final FirebaseFirestore _firestore;
  final _random = Random();

  EmojiGameRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _sessionsRef() {
    return _firestore.collection('emoji_game_sessions');
  }

  String _pickRandomWord() {
    return emojiGameWords[_random.nextInt(emojiGameWords.length)];
  }

  @override
  Future<EmojiGameSession> createSession({
    required String coupleId,
    required String startingUserId,
    required String partnerId,
  }) async {
    developer.log('[EmojiGame] createSession - coupleId: $coupleId, userId: $startingUserId');

    // Check for existing active session
    final existing = await _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final data = doc.data();

      if (data['status'] == 'waiting') {
        final currentReady = List<String>.from(data['readyUsers'] ?? []);
        if (!currentReady.contains(startingUserId)) {
          await doc.reference.update({
            'readyUsers': FieldValue.arrayUnion([startingUserId]),
          });

          // Notify partner
          final waitingUserId = currentReady.isNotEmpty ? currentReady.first : partnerId;
          if (waitingUserId != startingUserId) {
            await _firestore.collection('notifications').add({
              'targetUserId': waitingUserId,
              'fromUserId': startingUserId,
              'type': 'emoji_game_partner_joined',
              'title': 'Emoji Tahmin 🧩',
              'body': 'Partnerin oyuna katıldı! Oyun başlıyor...',
              'coupleId': coupleId,
              'sessionId': doc.id,
              'createdAt': FieldValue.serverTimestamp(),
              'sent': false,
            });
          }
        }
        final freshDoc = await doc.reference.get();
        return EmojiGameSession.fromMap(freshDoc.id, freshDoc.data()!);
      }

      if (data['status'] == 'sending' || data['status'] == 'guessing') {
        final freshDoc = await doc.reference.get();
        return EmojiGameSession.fromMap(freshDoc.id, freshDoc.data()!);
      }

      // Deactivate old completed sessions
      await doc.reference.update({'active': false});
    }

    // Create new session
    final docRef = _sessionsRef().doc();
    final word = _pickRandomWord();

    final sessionData = {
      'id': docRef.id,
      'coupleId': coupleId,
      'senderId': startingUserId,
      'guesserId': partnerId,
      'secretWord': word,
      'emojis': '',
      'status': 'waiting',
      'score': 0,
      'round': 1,
      'maxRounds': 5,
      'readyUsers': [startingUserId],
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'guesses': <String>[],
      'lastCorrectBy': null,
      'lastRoundCorrect': null,
    };

    await docRef.set(sessionData);

    // Send notification to partner
    await _firestore.collection('notifications').add({
      'targetUserId': partnerId,
      'fromUserId': startingUserId,
      'type': 'emoji_game_invite',
      'title': 'Emoji Tahmin 🧩',
      'body': 'Partnerin seni Emoji Tahmin oynamaya çağırıyor!',
      'coupleId': coupleId,
      'sessionId': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });

    return EmojiGameSession(
      id: docRef.id,
      coupleId: coupleId,
      senderId: startingUserId,
      guesserId: partnerId,
      secretWord: word,
      emojis: '',
      status: 'waiting',
      score: 0,
      round: 1,
      maxRounds: 5,
      readyUsers: [startingUserId],
      active: true,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> startGame(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'sending',
    });
  }

  @override
  Future<void> sendEmojis({
    required String sessionId,
    required String emojis,
  }) async {
    await _sessionsRef().doc(sessionId).update({
      'emojis': emojis,
      'status': 'guessing',
      'guesses': <String>[],
    });
  }

  @override
  Future<bool> submitGuess({
    required String sessionId,
    required String guess,
  }) async {
    final doc = await _sessionsRef().doc(sessionId).get();
    final data = doc.data()!;
    final secretWord = _normalize(data['secretWord'] as String);
    final normalizedGuess = _normalize(guess);

    final isCorrect = normalizedGuess == secretWord;

    if (isCorrect) {
      await _sessionsRef().doc(sessionId).update({
        'guesses': FieldValue.arrayUnion([guess]),
        'status': 'roundEnd',
        'score': FieldValue.increment(1),
        'lastRoundCorrect': true,
        'lastCorrectBy': data['guesserId'],
      });
    } else {
      await _sessionsRef().doc(sessionId).update({
        'guesses': FieldValue.arrayUnion([guess]),
      });
    }

    return isCorrect;
  }

  /// Turkish-aware case-insensitive normalization
  String _normalize(String input) {
    return input
        .trim()
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı')
        .replaceAll('Ğ', 'ğ')
        .replaceAll('Ü', 'ü')
        .replaceAll('Ş', 'ş')
        .replaceAll('Ö', 'ö')
        .replaceAll('Ç', 'ç')
        .toLowerCase();
  }

  @override
  Future<void> nextRound({
    required String sessionId,
    required String newSenderId,
    required String newGuesserId,
  }) async {
    final word = _pickRandomWord();

    await _sessionsRef().doc(sessionId).update({
      'senderId': newSenderId,
      'guesserId': newGuesserId,
      'secretWord': word,
      'emojis': '',
      'status': 'sending',
      'round': FieldValue.increment(1),
      'guesses': <String>[],
      'lastRoundCorrect': null,
      'lastCorrectBy': null,
    });
  }

  @override
  Future<void> skipRound(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'roundEnd',
      'lastRoundCorrect': false,
      'lastCorrectBy': null,
    });
  }

  @override
  Future<void> endGame(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'status': 'gameover',
    });
  }

  @override
  Stream<EmojiGameSession?> watchActiveSession(String coupleId) {
    return _sessionsRef()
        .where('coupleId', isEqualTo: coupleId)
        .where('active', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return EmojiGameSession.fromMap(doc.id, doc.data());
    });
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    await _sessionsRef().doc(sessionId).update({
      'active': false,
      'status': 'cancelled',
    });
  }

  @override
  Future<void> resetSession({
    required String sessionId,
    required String userId,
  }) async {
    final word = _pickRandomWord();

    await _sessionsRef().doc(sessionId).update({
      'status': 'waiting',
      'secretWord': word,
      'emojis': '',
      'score': 0,
      'round': 1,
      'active': true,
      'readyUsers': [userId],
      'guesses': <String>[],
      'lastCorrectBy': null,
      'lastRoundCorrect': null,
    });
  }

}
