
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/achievement/presentation/providers/achievement_provider.dart';
import 'package:heartbit/features/pet/domain/entities/pet.dart';
import 'package:heartbit/features/pet/domain/repositories/pet_repository.dart';
import 'package:heartbit/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:heartbit/features/pet/data/repositories/pet_repository_impl.dart';

part 'pet_provider.g.dart';

// --- Data Layer ---

@riverpod
PetRemoteDataSource petRemoteDataSource(PetRemoteDataSourceRef ref) {
  return PetRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
PetRepository petRepository(PetRepositoryRef ref) {
  return PetRepositoryImpl(
    remoteDataSource: ref.watch(petRemoteDataSourceProvider),
  );
}

// --- Presentation Layer ---

@riverpod
Stream<Pet?> petState(PetStateRef ref) {
  final user = ref.watch(authUserIdProvider);
  if (user == null) return const Stream.empty();
  
  final coupleAsync = ref.watch(coupleStateProvider);
  
  return coupleAsync.when(
    data: (couple) {
      if (couple == null) return const Stream.empty();
      return ref.watch(petRepositoryProvider).watchPet(couple.id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

@riverpod
class PetController extends _$PetController {
  @override
  FutureOr<void> build() {
    // Watch pet state changes to check evolution achievements
    ref.listen(petStateProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        final pet = next.value!;
        final prevPet = previous?.valueOrNull;
        
        // Check if level changed
        if (prevPet == null || pet.level != prevPet.level) {
          ref.read(achievementControllerProvider.notifier).checkAchievements(
            petLevel: pet.level,
          );
        }
      }
    });
  }

  Future<void> feed() async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    final coupleId = coupleAsync.value!.id;

    state = const AsyncLoading();
    try {
      await ref.read(petRepositoryProvider).feedPet(coupleId, 10.0);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createPetIfNeeded() async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    final coupleId = coupleAsync.value!.id;
    
    await ref.read(petRepositoryProvider).createPet(coupleId);
    
    // Unlock first_egg achievement
    ref.read(achievementControllerProvider.notifier).checkAchievements(
      hasCreatedPet: true,
    );
  }

  Future<void> interact() async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    final coupleId = coupleAsync.value!.id;

    state = const AsyncLoading();
    try {
      // Interaction adds 5 XP
      await ref.read(petRepositoryProvider).addExperience(coupleId, 5.0);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> sendInteraction(String type) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final userId = ref.read(authUserIdProvider);
    
    // Validations
    if (!coupleAsync.hasValue || coupleAsync.value == null || userId == null) return;
    
    final coupleId = coupleAsync.value!.id;

    final interaction = PetInteraction(
       userId: userId, 
       type: type, 
       timestamp: DateTime.now()
    );

    try {
       await ref.read(petRepositoryProvider).sendInteraction(coupleId, interaction);
    } catch (e) {
       print('Interaction failed: $e'); 
    }
  }
}
