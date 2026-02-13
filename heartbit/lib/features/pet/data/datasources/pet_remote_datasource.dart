
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/pet_evolution.dart';

abstract class PetRemoteDataSource {
  Stream<Pet?> watchPet(String coupleId);
  Future<void> createPet(String coupleId);
  Future<void> updatePet(Pet pet);
  Future<void> feedPet(String coupleId, double amount);
  Future<void> addExperience(String coupleId, double amount);
  Future<void> updateHappiness(String coupleId, double amount);
  Future<void> sendInteraction(String coupleId, PetInteraction interaction);
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final FirebaseFirestore _firestore;

  PetRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _petsCollection =>
      _firestore.collection('pets');

  @override
  Stream<Pet?> watchPet(String coupleId) {
    return _petsCollection.doc(coupleId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PetModel.fromDocument(doc);
    });
  }

  @override
  Future<void> createPet(String coupleId) async {
    final pet = Pet(
      id: coupleId,
      coupleId: coupleId,
      name: 'Baby Egg',
      level: 1,
      experience: 0,
      totalXp: 0,
      hunger: 100,
      happiness: 100,
      lastFed: DateTime.now(),
      lastInteracted: DateTime.now(),
    );

    await _petsCollection.doc(coupleId).set(PetModel.toMap(pet));
  }

  @override
  Future<void> updatePet(Pet pet) async {
    await _petsCollection.doc(pet.coupleId).update(PetModel.toMap(pet));
  }

  @override
  Future<void> feedPet(String coupleId, double amount) async {
    final docRef = _petsCollection.doc(coupleId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentHunger = (data['hunger'] as num?)?.toDouble() ?? 0.0;
      final currentHappiness = (data['happiness'] as num?)?.toDouble() ?? 0.0;
      
      final newHunger = (currentHunger + amount).clamp(0.0, 100.0);
      // Feeding also slightly increases happiness
      final newHappiness = (currentHappiness + amount * 0.5).clamp(0.0, 100.0);

      transaction.update(docRef, {
        'hunger': newHunger,
        'happiness': newHappiness,
        'lastFed': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  @override
  Future<void> addExperience(String coupleId, double amount) async {
    final docRef = _petsCollection.doc(coupleId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentTotalXp = (data['totalXp'] as num?)?.toDouble() ?? 0.0;
      final currentHappiness = (data['happiness'] as num?)?.toDouble() ?? 100.0;
      
      // Apply mood bonus to XP
      final mood = PetEvolution.moodFromHappiness(currentHappiness);
      final actualAmount = PetEvolution.applyMoodBonus(amount, mood);
      
      final newTotalXp = currentTotalXp + actualAmount;
      
      // Use PetEvolution to calculate level for consistency
      final newLevel = PetEvolution.levelFromTotalXp(newTotalXp);
      
      // Calculate XP within current level for progress display
      final xpForCurrentLevel = PetEvolution.totalXpForLevel(newLevel).toDouble();
      final xpWithinLevel = newTotalXp - xpForCurrentLevel;

      transaction.update(docRef, {
        'experience': xpWithinLevel,
        'totalXp': newTotalXp,
        'level': newLevel,
        'lastInteracted': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  @override
  Future<void> updateHappiness(String coupleId, double amount) async {
    final docRef = _petsCollection.doc(coupleId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final currentHappiness = (snapshot.data()!['happiness'] as num?)?.toDouble() ?? 100.0;
      final newHappiness = (currentHappiness + amount).clamp(0.0, 100.0);

      transaction.update(docRef, {
        'happiness': newHappiness,
        'lastInteracted': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  @override
  Future<void> sendInteraction(String coupleId, PetInteraction interaction) async {
    await _petsCollection.doc(coupleId).update({
      'lastInteraction': interaction.toJson(),
      'updatedAt': Timestamp.now(),
    });
  }
}
