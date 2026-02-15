
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/couple_entity.dart';

class CoupleModel extends CoupleEntity {
  const CoupleModel({
    required super.id,
    required super.user1Id,
    required super.user2Id,
    required super.totalPoints,
    required super.level,
    super.streak = 0,
    super.lastStreakDate,
    super.eggWarmth = 0,
    super.isHatched = false,
    super.lastEggInteraction,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CoupleModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoupleModel(
      id: doc.id,
      user1Id: data['user1Id'] as String,
      user2Id: data['user2Id'] as String,
      totalPoints: (data['totalPoints'] as num).toInt(),
      level: (data['level'] as num).toInt(),
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      lastStreakDate: (data['lastStreakDate'] as Timestamp?)?.toDate(),
      eggWarmth: (data['eggWarmth'] as num?)?.toInt() ?? 0,
      isHatched: data['isHatched'] as bool? ?? false,
      lastEggInteraction: (data['lastEggInteraction'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  CoupleEntity toEntity() {
    return CoupleEntity(
      id: id,
      user1Id: user1Id,
      user2Id: user2Id,
      totalPoints: totalPoints,
      level: level,
      streak: streak,
      lastStreakDate: lastStreakDate,
      eggWarmth: eggWarmth,
      isHatched: isHatched,
      lastEggInteraction: lastEggInteraction,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
