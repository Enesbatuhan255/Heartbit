import 'package:equatable/equatable.dart';

/// Represents the daily connection score between partners
class ConnectionScore extends Equatable {
  /// Today's connection score (0-100)
  final int todayScore;
  
  /// Yesterday's score for comparison (nullable if no data)
  final int? yesterdayScore;
  
  /// Breakdown of points by activity
  final Map<String, int> breakdown;
  
  const ConnectionScore({
    required this.todayScore,
    this.yesterdayScore,
    this.breakdown = const {},
  });
  
  /// Get trend direction compared to yesterday
  ConnectionTrend get trend {
    if (yesterdayScore == null) return ConnectionTrend.neutral;
    if (todayScore > yesterdayScore!) return ConnectionTrend.up;
    if (todayScore < yesterdayScore!) return ConnectionTrend.down;
    return ConnectionTrend.neutral;
  }
  
  /// Get the difference from yesterday
  int get difference => yesterdayScore != null ? todayScore - yesterdayScore! : 0;
  
  /// Get emoji for trend
  String get trendEmoji {
    switch (trend) {
      case ConnectionTrend.up:
        return '🔥';
      case ConnectionTrend.down:
        return '📉';
      case ConnectionTrend.neutral:
        return '➡️';
    }
  }
  
  /// Get message for trend
  String get trendMessage {
    if (yesterdayScore == null) return 'İlk gününüz!';
    
    switch (trend) {
      case ConnectionTrend.up:
        return 'Dün %$yesterdayScore\'dı → artış var $trendEmoji';
      case ConnectionTrend.down:
        return 'Dün %$yesterdayScore\'dı → düşüş var $trendEmoji';
      case ConnectionTrend.neutral:
        return 'Dünle aynı $trendEmoji';
    }
  }
  
  @override
  List<Object?> get props => [todayScore, yesterdayScore, breakdown];
}

enum ConnectionTrend { up, down, neutral }
