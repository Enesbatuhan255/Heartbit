import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartbit/features/games/story_chain/domain/entities/story_chain_session.dart';
import 'package:heartbit/features/games/story_chain/domain/utils/story_chain_validator.dart';

void main() {
  group('StoryChainSession', () {
    test('required word count progression caps at 10 in increasing mode', () {
      expect(
        StoryChainSession.requiredWordCountFor(
          mode: StoryMode.increasing,
          successfulTurnCount: 0,
        ),
        1,
      );
      expect(
        StoryChainSession.requiredWordCountFor(
          mode: StoryMode.increasing,
          successfulTurnCount: 4,
        ),
        5,
      );
      expect(
        StoryChainSession.requiredWordCountFor(
          mode: StoryMode.increasing,
          successfulTurnCount: 9,
        ),
        10,
      );
      expect(
        StoryChainSession.requiredWordCountFor(
          mode: StoryMode.increasing,
          successfulTurnCount: 99,
        ),
        10,
      );
    });

    test('single mode always stays at one word', () {
      expect(
        StoryChainSession.requiredWordCountFor(
          mode: StoryMode.singleWord,
          successfulTurnCount: 0,
        ),
        1,
      );
      expect(
        StoryChainSession.requiredWordCountFor(
          mode: StoryMode.singleWord,
          successfulTurnCount: 80,
        ),
        1,
      );
    });

    test('fromMap falls back required defaults safely', () {
      final now = Timestamp.fromDate(DateTime(2026, 1, 1));
      final session = StoryChainSession.fromMap('s1', {
        'id': 's1',
        'coupleId': 'c1',
        'status': 'playing',
        'mode': 'increasing',
        'turns': [
          {
            'text': 'bir',
            'userId': 'u1',
            'timestamp': 1,
            'wordCount': 1,
          },
          {
            'text': 'iki uc',
            'userId': 'u2',
            'timestamp': 2,
            'wordCount': 2,
          },
        ],
        'currentTurnUserId': 'u1',
        'readyUsers': ['u1', 'u2'],
        'participants': ['u1', 'u2'],
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      });

      expect(session.successfulTurnCount, 2);
      expect(session.requiredWordCount, 3);
      expect(session.maxTurns, StoryChainSession.defaultMaxTurns);
      expect(session.memorySaved, false);
    });

    test('storyText joins turns as one readable string', () {
      final now = Timestamp.fromDate(DateTime(2026, 1, 1));
      final session = StoryChainSession.fromMap('s2', {
        'id': 's2',
        'coupleId': 'c1',
        'status': 'completed',
        'mode': 'single_word',
        'turns': [
          {
            'text': 'Bugun',
            'userId': 'u1',
            'timestamp': 1,
            'wordCount': 1,
          },
          {
            'text': 'hava guzel',
            'userId': 'u2',
            'timestamp': 2,
            'wordCount': 2,
          },
        ],
        'requiredWordCount': 1,
        'successfulTurnCount': 2,
        'maxTurns': 120,
        'memorySaved': true,
        'currentTurnUserId': null,
        'readyUsers': ['u1', 'u2'],
        'participants': ['u1', 'u2'],
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      });

      expect(session.storyText, 'Bugun hava guzel');
    });
  });

  group('StoryChainValidator', () {
    StoryChainSession buildSession({
      required StoryMode mode,
      required int requiredWordCount,
    }) {
      final now = Timestamp.fromDate(DateTime(2026, 1, 1));
      return StoryChainSession.fromMap('v1', {
        'id': 'v1',
        'coupleId': 'c1',
        'status': 'playing',
        'mode': StoryChainSession.modeToStorage(mode),
        'turns': const [],
        'currentTurnUserId': 'u1',
        'readyUsers': ['u1', 'u2'],
        'participants': ['u1', 'u2'],
        'requiredWordCount': requiredWordCount,
        'successfulTurnCount': 0,
        'maxTurns': 120,
        'memorySaved': false,
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      });
    }

    test('single word mode enforces exactly one word', () {
      final session =
          buildSession(mode: StoryMode.singleWord, requiredWordCount: 1);

      expect(StoryChainValidator.validateTurn('merhaba', session), isNull);
      expect(
        StoryChainValidator.validateTurn('merhaba dunya', session),
        isNotNull,
      );
    });

    test('increasing mode enforces exact required count', () {
      final session =
          buildSession(mode: StoryMode.increasing, requiredWordCount: 3);

      expect(StoryChainValidator.validateTurn('bir iki uc', session), isNull);
      expect(StoryChainValidator.validateTurn('bir iki', session), isNotNull);
      expect(StoryChainValidator.validateTurn('bir iki uc dort', session),
          isNotNull);
    });

    test('rejects non-letter characters', () {
      final session =
          buildSession(mode: StoryMode.increasing, requiredWordCount: 2);

      final result = StoryChainValidator.validateTurn('merhaba 123', session);
      expect(result, isNotNull);
      expect(result, contains('Sadece harf'));
    });
  });
}
