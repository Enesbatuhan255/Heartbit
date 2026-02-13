import 'package:equatable/equatable.dart';

class DrawingPoint extends Equatable {
  final double x;
  final double y;
  final bool isEnd;

  const DrawingPoint({
    required this.x,
    required this.y,
    this.isEnd = false,
  });

  Map<String, dynamic> toMap() => {
    'x': x,
    'y': y,
    if (isEnd) 'e': true,
  };

  factory DrawingPoint.fromMap(Map<String, dynamic> map) {
    return DrawingPoint(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      isEnd: map['e'] == true,
    );
  }

  @override
  List<Object?> get props => [x, y, isEnd];
}

class DrawingSession extends Equatable {
  final String id;
  final String coupleId;
  final String drawerId;
  final String secretWord;
  final String status; // 'drawing', 'guessing', 'solved'
  final List<DrawingPoint> points;
  final DateTime createdAt;
  final List<String> attempts;
  final DateTime? drawingCompletedAt; // New field

  const DrawingSession({
    required this.id,
    required this.coupleId,
    required this.drawerId,
    required this.secretWord,
    required this.status,
    required this.points,
    required this.createdAt,
    this.attempts = const [],
    this.drawingCompletedAt,
  });

  @override
  List<Object?> get props => [id, coupleId, drawerId, secretWord, status, points, createdAt, attempts, drawingCompletedAt];
}
