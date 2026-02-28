import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WordEntry extends Equatable {
  final String word;
  final String userId;
  final int timestamp;

  const WordEntry({
    required this.word,
    required this.userId,
    required this.timestamp,
  });

  factory WordEntry.fromMap(Map<String, dynamic> map) {
    return WordEntry(
      word: (map['word'] as String? ?? '').trim(),
      userId: map['userId'] as String? ?? '',
      timestamp: map['timestamp'] is int
          ? map['timestamp'] as int
          : int.tryParse(map['timestamp']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'userId': userId,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [word, userId, timestamp];
}

enum WordChainMode { lastLetter, category, free }

enum WordChainStatus { waiting, playing, gameover, cancelled }

class WordChainSession extends Equatable {
  static const int stageOneWordThreshold = 5;
  static const int stageTwoWordThreshold = 10;

  static const int stageOneSuffixLength = 1;
  static const int stageTwoSuffixLength = 2;
  static const int stageThreeSuffixLength = 3;

  static const int stageOneTurnSeconds = 15;
  static const int stageTwoTurnSeconds = 12;
  static const int stageThreeTurnSeconds = 10;

  final String id;
  final String coupleId;
  final WordChainStatus status;
  final WordChainMode mode;
  final String? category;
  final List<WordEntry> words;
  final String? currentTurnUserId;
  final List<String> readyUsers;
  final DateTime? turnDeadline;
  final String? winnerUserId;
  final String? loserReason;
  final List<String> participants;
  final int requiredSuffixLength;
  final Map<String, int> jokersRemaining;
  final int turnSeconds;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WordChainSession({
    required this.id,
    required this.coupleId,
    required this.status,
    required this.mode,
    this.category,
    required this.words,
    this.currentTurnUserId,
    required this.readyUsers,
    this.turnDeadline,
    this.winnerUserId,
    this.loserReason,
    required this.participants,
    required this.requiredSuffixLength,
    required this.jokersRemaining,
    required this.turnSeconds,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  static bool isProgressiveMode(WordChainMode mode) {
    return mode == WordChainMode.lastLetter || mode == WordChainMode.free;
  }

  static int suffixLengthForWordCount(int wordCount) {
    if (wordCount >= stageTwoWordThreshold) return stageThreeSuffixLength;
    if (wordCount >= stageOneWordThreshold) return stageTwoSuffixLength;
    return stageOneSuffixLength;
  }

  static int turnSecondsForSuffixLength(int suffixLength) {
    if (suffixLength >= stageThreeSuffixLength) return stageThreeTurnSeconds;
    if (suffixLength >= stageTwoSuffixLength) return stageTwoTurnSeconds;
    return stageOneTurnSeconds;
  }

  bool get bothReady => readyUsers.length >= 2;

  int get currentStage {
    final safe = requiredSuffixLength.clamp(1, 3);
    return safe;
  }

  String? get expectedPrefix {
    if (words.isEmpty) return null;
    final last = words.last.word.trim().toUpperCase();
    if (last.isEmpty) return null;

    final needed = requiredSuffixLength.clamp(1, last.length);
    return last.substring(last.length - needed);
  }

  String? get expectedFirstLetter {
    final prefix = expectedPrefix;
    if (prefix == null || prefix.isEmpty) return null;
    return prefix[prefix.length - 1];
  }

  Set<String> get usedWords =>
      words.map((e) => e.word.toLowerCase().trim()).toSet();

  String? partnerOf(String userId) {
    for (final participant in participants) {
      if (participant != userId) return participant;
    }
    return null;
  }

  factory WordChainSession.fromMap(String id, Map<String, dynamic> data) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    WordChainStatus parseStatus(String raw) {
      switch (raw) {
        case 'playing':
          return WordChainStatus.playing;
        case 'gameover':
          return WordChainStatus.gameover;
        case 'cancelled':
          return WordChainStatus.cancelled;
        default:
          return WordChainStatus.waiting;
      }
    }

    WordChainMode parseMode(String raw) {
      switch (raw) {
        case 'category':
          return WordChainMode.category;
        case 'free':
          return WordChainMode.free;
        default:
          return WordChainMode.lastLetter;
      }
    }

    final wordsRaw = List<dynamic>.from(data['words'] ?? const []);
    final parsedWords = <WordEntry>[];
    for (final item in wordsRaw) {
      if (item is Map) {
        parsedWords.add(WordEntry.fromMap(Map<String, dynamic>.from(item)));
      }
    }

    final participants =
        List<String>.from(data['participants'] ?? const <String>[]);
    final mode = parseMode(data['mode'] as String? ?? 'last_letter');
    final progressive = isProgressiveMode(mode);

    final fallbackSuffix =
        progressive ? suffixLengthForWordCount(parsedWords.length) : 1;
    final requiredSuffixLength =
        parseInt(data['requiredSuffixLength'], fallbackSuffix).clamp(1, 3);

    final rawJokers =
        Map<String, dynamic>.from(data['jokersRemaining'] ?? const {});
    final jokers = <String, int>{};
    rawJokers.forEach((key, value) {
      jokers[key] = parseInt(value, 1).clamp(0, 1);
    });
    for (final participant in participants) {
      jokers.putIfAbsent(participant, () => 1);
    }

    final fallbackTurnSeconds = progressive
        ? turnSecondsForSuffixLength(requiredSuffixLength)
        : stageOneTurnSeconds;
    final turnSeconds = parseInt(data['turnSeconds'], fallbackTurnSeconds);

    return WordChainSession(
      id: id,
      coupleId: data['coupleId'] as String? ?? '',
      status: parseStatus(data['status'] as String? ?? 'waiting'),
      mode: mode,
      category: data['category'] as String?,
      words: parsedWords,
      currentTurnUserId: data['currentTurnUserId'] as String?,
      readyUsers: List<String>.from(data['readyUsers'] ?? const []),
      turnDeadline: parseNullableDate(data['turnDeadline']),
      winnerUserId: data['winnerUserId'] as String?,
      loserReason: data['loserReason'] as String?,
      participants: participants,
      requiredSuffixLength: requiredSuffixLength,
      jokersRemaining: jokers,
      turnSeconds: turnSeconds,
      active: data['active'] as bool? ?? true,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  static String modeToStorage(WordChainMode mode) {
    switch (mode) {
      case WordChainMode.category:
        return 'category';
      case WordChainMode.free:
        return 'free';
      case WordChainMode.lastLetter:
        return 'last_letter';
    }
  }

  static String statusToStorage(WordChainStatus status) {
    switch (status) {
      case WordChainStatus.playing:
        return 'playing';
      case WordChainStatus.gameover:
        return 'gameover';
      case WordChainStatus.cancelled:
        return 'cancelled';
      case WordChainStatus.waiting:
        return 'waiting';
    }
  }

  @override
  List<Object?> get props => [
        id,
        coupleId,
        status,
        mode,
        category,
        words,
        currentTurnUserId,
        readyUsers,
        turnDeadline,
        winnerUserId,
        loserReason,
        participants,
        requiredSuffixLength,
        jokersRemaining,
        turnSeconds,
        active,
        createdAt,
        updatedAt,
      ];
}
