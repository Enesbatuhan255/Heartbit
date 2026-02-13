import 'package:equatable/equatable.dart';

/// Represents a single block in the Stack Tower game.
class StackedBlock extends Equatable {
  /// The left position (X coordinate) relative to screen width (0.0 - 1.0)
  final double leftRatio;
  
  /// The width of the block relative to screen width (0.0 - 1.0)
  final double widthRatio;
  
  /// Index of the block (0 = base, 1+ = stacked)
  final int index;
  
  /// The user who placed this block
  final String placedBy;
  
  /// Color index for the block
  final int colorIndex;

  const StackedBlock({
    required this.leftRatio,
    required this.widthRatio,
    required this.index,
    required this.placedBy,
    required this.colorIndex,
  });

  /// Creates a copy of this block with optional new values
  StackedBlock copyWith({
    double? leftRatio,
    double? widthRatio,
    int? index,
    String? placedBy,
    int? colorIndex,
  }) {
    return StackedBlock(
      leftRatio: leftRatio ?? this.leftRatio,
      widthRatio: widthRatio ?? this.widthRatio,
      index: index ?? this.index,
      placedBy: placedBy ?? this.placedBy,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  /// The right edge ratio
  double get rightRatio => leftRatio + widthRatio;

  /// Calculate the overlapping width with another block
  double overlapWidthRatio(StackedBlock other) {
    final overlapLeft = leftRatio > other.leftRatio ? leftRatio : other.leftRatio;
    final overlapRight = rightRatio < other.rightRatio ? rightRatio : other.rightRatio;
    if (overlapRight <= overlapLeft) return 0;
    return overlapRight - overlapLeft;
  }

  Map<String, dynamic> toMap() => {
    'leftRatio': leftRatio,
    'widthRatio': widthRatio,
    'index': index,
    'placedBy': placedBy,
    'colorIndex': colorIndex,
  };

  factory StackedBlock.fromMap(Map<String, dynamic> map) {
    return StackedBlock(
      leftRatio: double.tryParse(map['leftRatio']?.toString() ?? '0') ?? 0.0,
      widthRatio: double.tryParse(map['widthRatio']?.toString() ?? '0') ?? 0.1,
      index: int.tryParse(map['index']?.toString() ?? '0') ?? 0,
      placedBy: map['placedBy']?.toString() ?? '',
      colorIndex: int.tryParse(map['colorIndex']?.toString() ?? '0') ?? 0,
    );
  }

  @override
  List<Object?> get props => [leftRatio, widthRatio, index, placedBy, colorIndex];
}

/// Represents a Stack Tower game session between two partners.
class StackTowerSession extends Equatable {
  final String id;
  final String coupleId;
  
  /// The user whose turn it is to place the next block
  final String currentTurnUserId;
  
  /// All blocks currently stacked
  final List<StackedBlock> blocks;
  
  /// Current game status: 'waiting', 'playing', 'gameover'
  final String status;
  
  /// Current speed multiplier
  final double speed;
  
  /// Total score (number of successfully placed blocks)
  final int score;
  
  /// When the session was created
  final DateTime createdAt;
  
  /// Is the session active
  final bool active;
  
  /// List of user IDs who have joined and are ready
  final List<String> readyUsers;

  const StackTowerSession({
    required this.id,
    required this.coupleId,
    required this.currentTurnUserId,
    required this.blocks,
    required this.status,
    required this.speed,
    required this.score,
    required this.createdAt,
    this.active = true,
    this.readyUsers = const [],
  });

  /// Check if both users are ready
  bool get bothReady => readyUsers.length >= 2;

  @override
  List<Object?> get props => [id, coupleId, currentTurnUserId, blocks, status, speed, score, createdAt, active, readyUsers];
}
