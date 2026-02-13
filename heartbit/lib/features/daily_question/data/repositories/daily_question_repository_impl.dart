import '../../domain/entities/daily_question.dart';
import '../../domain/repositories/daily_question_repository.dart';
import '../datasources/daily_question_remote_datasource.dart';

/// Repository implementation for Daily Question
class DailyQuestionRepositoryImpl implements DailyQuestionRepository {
  final DailyQuestionRemoteDataSource _remoteDataSource;

  DailyQuestionRepositoryImpl({
    required DailyQuestionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Stream<DailyQuestion?> watchTodaysQuestion(String coupleId) {
    return _remoteDataSource.watchTodaysQuestion(coupleId);
  }

  @override
  Future<DailyQuestion> getOrCreateTodaysQuestion(String coupleId) {
    return _remoteDataSource.getOrCreateTodaysQuestion(coupleId);
  }

  @override
  Future<void> submitAnswer({
    required String coupleId,
    required String date,
    required String userId,
    required bool isUser1,
    required String answer,
  }) {
    return _remoteDataSource.submitAnswer(
      coupleId: coupleId,
      date: date,
      isUser1: isUser1,
      answer: answer,
    );
  }

  @override
  Future<bool> claimBonusXpTransaction({
    required String coupleId,
    required String date,
  }) {
    return _remoteDataSource.claimBonusXpTransaction(
      coupleId: coupleId,
      date: date,
    );
  }

  @override
  Future<void> submitReaction({
    required String coupleId,
    required String date,
    required String userId,
    required bool isUser1,
    required String reaction,
  }) {
    return _remoteDataSource.submitReaction(
      coupleId: coupleId,
      date: date,
      isUser1: isUser1,
      reaction: reaction,
    );
  }

  @override
  Future<List<DailyQuestion>> getPastQuestions({
    required String coupleId,
    int limit = 30,
  }) {
    return _remoteDataSource.getPastQuestions(
      coupleId: coupleId,
      limit: limit,
    );
  }

  @override
  Future<bool> claimSyncBonusXpTransaction({
    required String coupleId,
    required String date,
    required int xpAmount,
  }) {
    return _remoteDataSource.claimSyncBonusXpTransaction(
      coupleId: coupleId,
      date: date,
      xpAmount: xpAmount,
    );
  }
}
