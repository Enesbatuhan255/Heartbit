import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RhythmCopySession extends Equatable {
  final String id;
  final String coupleId;
  final List<String> participants;
  final String composerId;
  final String copyUserId;
  final String
      status; // waiting | composing | copying | roundEnd | gameover | cancelled
  final int round;
  final int maxRounds;
  final List<int> pattern;
  final List<int> patternTimingsMs;
  final List<int> copyInput;
  final List<int> copyInputTimingsMs;
  final Map<String, int> scores;
  final double? lastAccuracy;
  final double? lastNoteAccuracy;
  final double? lastTimingAccuracy;
  final int? lastResponseMs;
  final String? lastRoundWinnerId;
  final DateTime? copyStartedAt;
  final String? reactionEmoji;
  final String? reactionBy;
  final DateTime? reactionAt;
  final List<String> readyUsers;
  final bool active;
  final DateTime createdAt;

  const RhythmCopySession({
    required this.id,
    required this.coupleId,
    required this.participants,
    required this.composerId,
    required this.copyUserId,
    required this.status,
    required this.round,
    required this.maxRounds,
    required this.pattern,
    required this.patternTimingsMs,
    required this.copyInput,
    required this.copyInputTimingsMs,
    required this.scores,
    this.lastAccuracy,
    this.lastNoteAccuracy,
    this.lastTimingAccuracy,
    this.lastResponseMs,
    this.lastRoundWinnerId,
    this.copyStartedAt,
    this.reactionEmoji,
    this.reactionBy,
    this.reactionAt,
    required this.readyUsers,
    required this.active,
    required this.createdAt,
  });

  bool get bothReady => readyUsers.length >= 2;

  int scoreOf(String userId) => scores[userId] ?? 0;

  String? partnerOf(String userId) {
    for (final participant in participants) {
      if (participant != userId) return participant;
    }
    return null;
  }

  factory RhythmCopySession.fromMap(String id, Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];
    DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    } else {
      createdAt = DateTime.now();
    }

    DateTime? copyStartedAt;
    final copyStartedAtValue = data['copyStartedAt'];
    if (copyStartedAtValue is Timestamp) {
      copyStartedAt = copyStartedAtValue.toDate();
    } else if (copyStartedAtValue is DateTime) {
      copyStartedAt = copyStartedAtValue;
    }

    DateTime? reactionAt;
    final reactionAtValue = data['reactionAt'];
    if (reactionAtValue is Timestamp) {
      reactionAt = reactionAtValue.toDate();
    } else if (reactionAtValue is DateTime) {
      reactionAt = reactionAtValue;
    }

    final rawScores = Map<String, dynamic>.from(data['scores'] ?? const {});
    final scores = <String, int>{};
    rawScores.forEach((key, value) {
      scores[key] = int.tryParse(value.toString()) ?? 0;
    });

    final rawPattern = List<dynamic>.from(data['pattern'] ?? const []);
    final pattern =
        rawPattern.map((e) => int.tryParse(e.toString()) ?? 0).toList();

    final rawPatternTimings =
        List<dynamic>.from(data['patternTimingsMs'] ?? const []);
    var patternTimingsMs = rawPatternTimings
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList(growable: false);
    if (patternTimingsMs.isEmpty && pattern.isNotEmpty) {
      patternTimingsMs =
          List<int>.generate(pattern.length, (index) => index * 400);
    }

    final rawCopyInput = List<dynamic>.from(data['copyInput'] ?? const []);
    final copyInput =
        rawCopyInput.map((e) => int.tryParse(e.toString()) ?? 0).toList();

    final rawCopyInputTimings =
        List<dynamic>.from(data['copyInputTimingsMs'] ?? const []);
    var copyInputTimingsMs = rawCopyInputTimings
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList(growable: false);
    if (copyInputTimingsMs.isEmpty && copyInput.isNotEmpty) {
      copyInputTimingsMs =
          List<int>.generate(copyInput.length, (index) => index * 400);
    }

    final lastAccuracyValue = data['lastAccuracy'];
    final lastAccuracy = lastAccuracyValue == null
        ? null
        : double.tryParse(lastAccuracyValue.toString());

    final lastNoteAccuracyValue = data['lastNoteAccuracy'];
    final lastNoteAccuracy = lastNoteAccuracyValue == null
        ? null
        : double.tryParse(lastNoteAccuracyValue.toString());

    final lastTimingAccuracyValue = data['lastTimingAccuracy'];
    final lastTimingAccuracy = lastTimingAccuracyValue == null
        ? null
        : double.tryParse(lastTimingAccuracyValue.toString());

    final lastResponseMsValue = data['lastResponseMs'];
    final lastResponseMs = lastResponseMsValue == null
        ? null
        : int.tryParse(lastResponseMsValue.toString());

    return RhythmCopySession(
      id: id,
      coupleId: data['coupleId'] as String? ?? '',
      participants: List<String>.from(data['participants'] ?? const []),
      composerId: data['composerId'] as String? ?? '',
      copyUserId: data['copyUserId'] as String? ?? '',
      status: data['status'] as String? ?? 'waiting',
      round: data['round'] as int? ?? 1,
      maxRounds: data['maxRounds'] as int? ?? 6,
      pattern: pattern,
      patternTimingsMs: patternTimingsMs,
      copyInput: copyInput,
      copyInputTimingsMs: copyInputTimingsMs,
      scores: scores,
      lastAccuracy: lastAccuracy,
      lastNoteAccuracy: lastNoteAccuracy,
      lastTimingAccuracy: lastTimingAccuracy,
      lastResponseMs: lastResponseMs,
      lastRoundWinnerId: data['lastRoundWinnerId'] as String?,
      copyStartedAt: copyStartedAt,
      reactionEmoji: data['reactionEmoji'] as String?,
      reactionBy: data['reactionBy'] as String?,
      reactionAt: reactionAt,
      readyUsers: List<String>.from(data['readyUsers'] ?? const []),
      active: data['active'] as bool? ?? true,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        coupleId,
        participants,
        composerId,
        copyUserId,
        status,
        round,
        maxRounds,
        pattern,
        patternTimingsMs,
        copyInput,
        copyInputTimingsMs,
        scores,
        lastAccuracy,
        lastNoteAccuracy,
        lastTimingAccuracy,
        lastResponseMs,
        lastRoundWinnerId,
        copyStartedAt,
        reactionEmoji,
        reactionBy,
        reactionAt,
        readyUsers,
        active,
        createdAt,
      ];
}
