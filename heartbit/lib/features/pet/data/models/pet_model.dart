
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pet.dart';

/// Helper class for Firestore conversion
class PetModel {
  static Pet fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Pet(
      id: doc.id,
      coupleId: data['coupleId'] as String,
      name: data['name'] as String? ?? 'Baby Egg',
      level: (data['level'] as num?)?.toInt() ?? 1,
      experience: (data['experience'] as num?)?.toDouble() ?? 0.0,
      totalXp: (data['totalXp'] as num?)?.toDouble() ?? 0.0,
      hunger: (data['hunger'] as num?)?.toDouble() ?? 100.0,
      happiness: (data['happiness'] as num?)?.toDouble() ?? 100.0,
      lastFed: (data['lastFed'] as Timestamp?)?.toDate(),
      lastInteracted: (data['lastInteracted'] as Timestamp?)?.toDate(),
      lastInteraction: data['lastInteraction'] != null
          ? PetInteraction.fromJson(Map<String, dynamic>.from(data['lastInteraction'] as Map))
          : null,
    );
  }

  static Map<String, dynamic> toMap(Pet pet) {
    return {
      'coupleId': pet.coupleId,
      'name': pet.name,
      'level': pet.level,
      'experience': pet.experience,
      'totalXp': pet.totalXp,
      'hunger': pet.hunger,
      'happiness': pet.happiness,
      'lastFed': pet.lastFed != null ? Timestamp.fromDate(pet.lastFed!) : null,
      'lastInteracted': pet.lastInteracted != null ? Timestamp.fromDate(pet.lastInteracted!) : null,
      'lastInteraction': pet.lastInteraction?.toJson(),
      'updatedAt': Timestamp.now(),
    };
  }
}
