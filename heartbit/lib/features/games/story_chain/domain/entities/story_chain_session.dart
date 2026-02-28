import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StoryTurn extends Equatable {
  final String text;
  final String userId;
  final int timestamp;
  final int wordCount;

  const StoryTurn({
    required this.text,
    required this.userId,
    required this.timestamp,
    required this.wordCount,
  });

  factory StoryTurn.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    final normalizedText = (map['text'] as String? ?? '').trim();
    final words = normalizedText
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;

    return StoryTurn(
      text: normalizedText,
      userId: map['userId'] as String? ?? '',
      timestamp: parseInt(map['timestamp'], 0),
      wordCount: parseInt(map['wordCount'], words),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'timestamp': timestamp,
      'wordCount': wordCount,
    };
  }

  @override
  List<Object?> get props => [text, userId, timestamp, wordCount];
}

enum StoryMode { singleWord, increasing }

enum StoryStatus { waiting, playing, completed, cancelled }

class StoryChainSession extends Equatable {
  static const int defaultMaxTurns = 120;
  static const int maxRequiredWordCount = 10;

  final String id;
  final String coupleId;
  final StoryStatus status;
  final StoryMode mode;
  final List<StoryTurn> turns;
  final String? currentTurnUserId;
  final List<String> readyUsers;
  final List<String> participants;
  final int requiredWordCount;
  final int successfulTurnCount;
  final int maxTurns;
  final bool memorySaved;
  final bool active;
  final String? endedByUserId;
  final String? endReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoryChainSession({
    required this.id,
    required this.coupleId,
    required this.status,
    required this.mode,
    required this.turns,
    required this.currentTurnUserId,
    required this.readyUsers,
    required this.participants,
    required this.requiredWordCount,
    required this.successfulTurnCount,
    required this.maxTurns,
    required this.memorySaved,
    required this.active,
    required this.endedByUserId,
    required this.endReason,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get bothReady => readyUsers.length >= 2;

  int get nextRequiredWordCount {
    return requiredWordCountFor(
      mode: mode,
      successfulTurnCount: successfulTurnCount,
    );
  }

  String get storyText {
    if (turns.isEmpty) return '';
    final buffer = StringBuffer();
    for (final turn in turns) {
      final text = turn.text.trim();
      if (text.isEmpty) continue;
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(text);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? partnerOf(String userId) {
    for (final participant in participants) {
      if (participant != userId) return participant;
    }
    return null;
  }

  static int requiredWordCountFor({
    required StoryMode mode,
    required int successfulTurnCount,
  }) {
    if (mode == StoryMode.singleWord) return 1;
    final next = successfulTurnCount + 1;
    if (next < 1) return 1;
    if (next > maxRequiredWordCount) return maxRequiredWordCount;
    return next;
  }

  static StoryMode modeFromStorage(String raw) {
    switch (raw) {
      case 'increasing':
        return StoryMode.increasing;
      default:
        return StoryMode.singleWord;
    }
  }

  static String modeToStorage(StoryMode mode) {
    switch (mode) {
      case StoryMode.increasing:
        return 'increasing';
      case StoryMode.singleWord:
        return 'single_word';
    }
  }

  static StoryStatus statusFromStorage(String raw) {
    switch (raw) {
      case 'playing':
        return StoryStatus.playing;
      case 'completed':
        return StoryStatus.completed;
      case 'cancelled':
        return StoryStatus.cancelled;
      default:
        return StoryStatus.waiting;
    }
  }

  static String statusToStorage(StoryStatus status) {
    switch (status) {
      case StoryStatus.playing:
        return 'playing';
      case StoryStatus.completed:
        return 'completed';
      case StoryStatus.cancelled:
        return 'cancelled';
      case StoryStatus.waiting:
        return 'waiting';
    }
  }

  factory StoryChainSession.fromMap(String id, Map<String, dynamic> data) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    int parseInt(dynamic value, int fallback) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    final mode = modeFromStorage(data['mode'] as String? ?? 'single_word');

    final turnsRaw = List<dynamic>.from(data['turns'] ?? const []);
    final turns = <StoryTurn>[];
    for (final item in turnsRaw) {
      if (item is Map) {
        turns.add(StoryTurn.fromMap(Map<String, dynamic>.from(item)));
      }
    }

    final successfulTurnCount =
        parseInt(data['successfulTurnCount'], turns.length).clamp(0, 100000);
    final fallbackRequired = requiredWordCountFor(
      mode: mode,
      successfulTurnCount: successfulTurnCount,
    );
    final requiredWordCount =
        parseInt(data['requiredWordCount'], fallbackRequired).clamp(1, 10);

    return StoryChainSession(
      id: id,
      coupleId: data['coupleId'] as String? ?? '',
      status: statusFromStorage(data['status'] as String? ?? 'waiting'),
      mode: mode,
      turns: turns,
      currentTurnUserId: data['currentTurnUserId'] as String?,
      readyUsers: List<String>.from(data['readyUsers'] ?? const []),
      participants: List<String>.from(data['participants'] ?? const []),
      requiredWordCount: requiredWordCount,
      successfulTurnCount: successfulTurnCount,
      maxTurns: parseInt(data['maxTurns'], defaultMaxTurns).clamp(1, 100000),
      memorySaved: data['memorySaved'] as bool? ?? false,
      active: data['active'] as bool? ?? true,
      endedByUserId: data['endedByUserId'] as String?,
      endReason: data['endReason'] as String?,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        coupleId,
        status,
        mode,
        turns,
        currentTurnUserId,
        readyUsers,
        participants,
        requiredWordCount,
        successfulTurnCount,
        maxTurns,
        memorySaved,
        active,
        endedByUserId,
        endReason,
        createdAt,
        updatedAt,
      ];
}
