import 'package:equatable/equatable.dart';

/// Represents an Emoji Tahmin game session between two partners.
///
/// One partner (sender) describes a secret word using emojis,
/// and the other partner (guesser) tries to guess the word.
class EmojiGameSession extends Equatable {
  final String id;
  final String coupleId;

  /// The user who sends emojis this round
  final String senderId;

  /// The user who guesses this round
  final String guesserId;

  /// The secret word to describe with emojis
  final String secretWord;

  /// The emojis sent by the sender
  final String emojis;

  /// Game status: 'waiting', 'sending', 'guessing', 'roundEnd', 'gameover'
  final String status;

  /// Total score (correct guesses)
  final int score;

  /// Current round (1-based)
  final int round;

  /// Maximum rounds
  final int maxRounds;

  /// List of user IDs who have joined and are ready
  final List<String> readyUsers;

  /// Whether the session is active
  final bool active;

  /// When the session was created
  final DateTime createdAt;

  /// Previous guesses for current round
  final List<String> guesses;

  /// Who got the last correct guess
  final String? lastCorrectBy;

  /// Whether the last round was correct
  final bool? lastRoundCorrect;

  const EmojiGameSession({
    required this.id,
    required this.coupleId,
    required this.senderId,
    required this.guesserId,
    required this.secretWord,
    required this.emojis,
    required this.status,
    required this.score,
    required this.round,
    this.maxRounds = 5,
    this.readyUsers = const [],
    this.active = true,
    required this.createdAt,
    this.guesses = const [],
    this.lastCorrectBy,
    this.lastRoundCorrect,
  });

  /// Check if both users are ready
  bool get bothReady => readyUsers.length >= 2;

  Map<String, dynamic> toMap() => {
    'id': id,
    'coupleId': coupleId,
    'senderId': senderId,
    'guesserId': guesserId,
    'secretWord': secretWord,
    'emojis': emojis,
    'status': status,
    'score': score,
    'round': round,
    'maxRounds': maxRounds,
    'readyUsers': readyUsers,
    'active': active,
    'guesses': guesses,
    'lastCorrectBy': lastCorrectBy,
    'lastRoundCorrect': lastRoundCorrect,
  };

  factory EmojiGameSession.fromMap(String id, Map<String, dynamic> data) {
    return EmojiGameSession(
      id: id,
      coupleId: data['coupleId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      guesserId: data['guesserId'] as String? ?? '',
      secretWord: data['secretWord'] as String? ?? '',
      emojis: data['emojis'] as String? ?? '',
      status: data['status'] as String? ?? 'waiting',
      score: data['score'] as int? ?? 0,
      round: data['round'] as int? ?? 1,
      maxRounds: data['maxRounds'] as int? ?? 5,
      readyUsers: List<String>.from(data['readyUsers'] ?? []),
      active: data['active'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      guesses: List<String>.from(data['guesses'] ?? []),
      lastCorrectBy: data['lastCorrectBy'] as String?,
      lastRoundCorrect: data['lastRoundCorrect'] as bool?,
    );
  }

  @override
  List<Object?> get props => [
    id, coupleId, senderId, guesserId, secretWord, emojis,
    status, score, round, maxRounds, readyUsers, active,
    createdAt, guesses, lastCorrectBy, lastRoundCorrect,
  ];
}
