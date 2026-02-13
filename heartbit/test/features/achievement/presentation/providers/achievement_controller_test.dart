
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heartbit/features/achievement/data/datasources/achievement_datasource.dart';
import 'package:heartbit/features/achievement/domain/entities/achievement.dart';
import 'package:heartbit/features/achievement/presentation/providers/achievement_provider.dart';
import 'package:heartbit/features/pairing/domain/entities/couple_entity.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/pet/domain/repositories/pet_repository.dart';
import 'package:heartbit/features/pet/domain/entities/pet.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';


// --- Fakes ---

class FakeAchievementDataSource implements AchievementDataSource {
  final Map<String, UnlockedAchievement> _unlocked = {};
  final Map<String, bool> _claimed = {};

  @override
  Future<void> claimAchievement(String coupleId, String achievementId) async {
    _claimed['${coupleId}_$achievementId'] = true;
  }

  @override
  Future<bool> isUnlocked(String coupleId, String achievementId) async {
    return _unlocked.containsKey('${coupleId}_$achievementId');
  }

  @override
  Future<void> unlockAchievement(String coupleId, String achievementId) async {
    _unlocked['${coupleId}_$achievementId'] = UnlockedAchievement(
      achievementId: achievementId,
      unlockedAt: DateTime.now(),
      isClaimed: false,
    );
  }

  @override
  Stream<List<UnlockedAchievement>> watchUnlockedAchievements(String coupleId) {
    return Stream.value(_unlocked.values.toList());
  }

  // Helper for test verification
  bool isClaimed(String coupleId, String achievementId) {
    return _claimed['${coupleId}_$achievementId'] ?? false;
  }
}

class FakePetRepository implements PetRepository {
  double _xp = 0;

  @override
  Future<void> addExperience(String coupleId, double amount) async {
    _xp += amount;
  }

  @override
  Future<void> createPet(String coupleId) async {}

  @override
  Future<void> feedPet(String coupleId, double amount) async {}

  Future<Pet?> getPet(String coupleId) async {
    return null;
  }

  @override
  Stream<Pet?> watchPet(String coupleId) {
    return const Stream.empty();
  }
  
  // Helper
  double get totalXp => _xp;
  
  @override
  Future<void> updatePet(Pet pet) async {}

  @override
  Future<void> sendInteraction(String coupleId, PetInteraction interaction) async {}
}

// --- Tests ---

void main() {
  late ProviderContainer container;
  late FakeAchievementDataSource fakeDataSource;
  late FakePetRepository fakePetRepository;
  
  const testCoupleId = 'couple_123';
  final testCouple = CoupleEntity(
    id: testCoupleId, 
    user1Id: 'u1', 
    user2Id: 'u2', 
    totalPoints: 0, 
    level: 1, 
    createdAt: DateTime.now(), 
    updatedAt: DateTime.now()
  );

  setUp(() async {
    fakeDataSource = FakeAchievementDataSource();
    fakePetRepository = FakePetRepository();

    container = ProviderContainer(
      overrides: [
        achievementDataSourceProvider.overrideWithValue(fakeDataSource),
        petRepositoryProvider.overrideWithValue(fakePetRepository),
        coupleStateProvider.overrideWith((ref) => Stream.value(testCouple)),
      ],
    );
    
    // Allow StreamProvider to emit initial value
    // Wait for the first data to be available
    await container.read(coupleStateProvider.future);
  });

  tearDown(() {
    container.dispose();
  });

  test('Should unlock first_egg achievement when pet is created', () async {
    final controller = container.read(achievementControllerProvider.notifier);
    
    await controller.checkAchievements(hasCreatedPet: true);
    
    final isUnlocked = await fakeDataSource.isUnlocked(testCoupleId, 'first_egg');
    expect(isUnlocked, true);
  });

  test('Should unlock streak achievements', () async {
    final controller = container.read(achievementControllerProvider.notifier);
    
    await controller.checkAchievements(streak: 3);
    
    expect(await fakeDataSource.isUnlocked(testCoupleId, 'streak_3'), true);
    expect(await fakeDataSource.isUnlocked(testCoupleId, 'streak_7'), false); // Should not be unlocked
    
    await controller.checkAchievements(streak: 7);
    expect(await fakeDataSource.isUnlocked(testCoupleId, 'streak_7'), true);
  });
  
  test('Should unlock pet level achievements', () async {
    final controller = container.read(achievementControllerProvider.notifier);
    
    // Level 10 check
    await controller.checkAchievements(petLevel: 10);
    
    expect(await fakeDataSource.isUnlocked(testCoupleId, 'teen_stage'), true);
    expect(await fakeDataSource.isUnlocked(testCoupleId, 'pet_level_10'), true);
    expect(await fakeDataSource.isUnlocked(testCoupleId, 'pet_master'), false);
  });

  test('Should claim reward and add XP', () async {
    final controller = container.read(achievementControllerProvider.notifier);
    
    // Unlock first
    await controller.checkAchievements(hasCreatedPet: true);
    
    // Claim
    await controller.claimReward('first_egg');
    
    // Verify claimed in datasource
    expect(fakeDataSource.isClaimed(testCoupleId, 'first_egg'), true);
    
    // Verify XP added
    // first_egg gives 10 XP
    expect(fakePetRepository.totalXp, 10.0);
  });
}
