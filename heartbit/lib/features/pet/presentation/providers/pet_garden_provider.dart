import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/pet/domain/entities/pet_garden_types.dart';
import 'package:heartbit/features/pet/presentation/providers/pet_provider.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';

final petGardenSelectedTabProvider =
    StateProvider<PetGardenTab>((ref) => PetGardenTab.feed);

final petGardenActiveDecorProvider = StateProvider<String?>((ref) => null);

final petGardenTransientAnimationProvider =
    StateProvider<PetAnimationState?>((ref) => null);

final petGardenItemsProvider =
    Provider<List<PetGardenItem>>((ref) => PetGardenCatalog.all);

final petGardenFilteredItemsProvider = Provider<List<PetGardenItem>>((ref) {
  final tab = ref.watch(petGardenSelectedTabProvider);
  final all = ref.watch(petGardenItemsProvider);
  return all.where((item) => item.category == tab).toList(growable: false);
});

final petAnimationStateProvider = Provider<PetAnimationState>((ref) {
  final transient = ref.watch(petGardenTransientAnimationProvider);
  if (transient != null) return transient;

  final pet = ref.watch(petStateProvider).valueOrNull;
  if (pet == null) return PetAnimationState.idle;

  if (pet.hunger < 35) return PetAnimationState.hungry;
  if (pet.happiness >= 75) return PetAnimationState.happy;
  return PetAnimationState.idle;
});

final petGardenInventoryProvider = StreamProvider<Map<String, int>>((ref) {
  final couple = ref.watch(coupleStateProvider).valueOrNull;
  if (couple == null) {
    return Stream.value(PetGardenCatalog.initialInventory);
  }

  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore.collection('pets').doc(couple.id).snapshots().map((doc) {
    if (!doc.exists) {
      return PetGardenCatalog.initialInventory;
    }

    final data = doc.data() ?? <String, dynamic>{};
    final rawInventory = data['inventory'];

    final normalized = Map<String, int>.from(PetGardenCatalog.initialInventory);

    if (rawInventory is Map) {
      for (final entry in rawInventory.entries) {
        final key = entry.key.toString();
        final value = (entry.value as num?)?.toInt() ?? 0;
        normalized[key] = value;
      }
    }

    return normalized;
  });
});

final petGardenControllerProvider = Provider<PetGardenController>(
  (ref) => PetGardenController(ref),
);

class PetGardenController {
  PetGardenController(this.ref);

  final Ref ref;

  void playTemporaryAnimation(
    PetAnimationState state, {
    Duration duration = const Duration(milliseconds: 1800),
  }) {
    ref.read(petGardenTransientAnimationProvider.notifier).state = state;
    Future.delayed(duration, () {
      ref.read(petGardenTransientAnimationProvider.notifier).state = null;
    });
  }

  Future<bool> useItem(PetGardenItem item) async {
    final couple = ref.read(coupleStateProvider).valueOrNull;
    if (couple == null) return false;

    final firestore = ref.read(firebaseFirestoreProvider);
    final userId = ref.read(authUserIdProvider) ?? 'system';
    final docRef = firestore.collection('pets').doc(couple.id);

    final applied = await firestore.runTransaction<bool>((tx) async {
      final snapshot = await tx.get(docRef);
      final now = Timestamp.now();

      final data = snapshot.data() ?? _basePetDoc(couple.id);
      final inventory = _readInventory(data);

      final currentQty = inventory[item.id] ?? 0;
      if (currentQty <= 0) {
        return false;
      }

      inventory[item.id] = currentQty - 1;

      final updates = <String, dynamic>{
        'coupleId': couple.id,
        'inventory': inventory,
        'updatedAt': now,
        'lastInteracted': now,
        'lastInteraction': {
          'userId': userId,
          'type': item.category == PetGardenTab.feed ? 'feed' : 'decor',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      if (item.category == PetGardenTab.feed) {
        final currentHunger = (data['hunger'] as num?)?.toDouble() ?? 100.0;
        final currentHappiness =
            (data['happiness'] as num?)?.toDouble() ?? 100.0;

        updates['hunger'] = (currentHunger + item.hungerGain).clamp(0.0, 100.0);
        updates['happiness'] =
            (currentHappiness + item.happinessGain).clamp(0.0, 100.0);
        updates['lastFed'] = now;
      }

      tx.set(docRef, updates, SetOptions(merge: true));
      return true;
    });

    if (!applied) return false;

    if (item.category == PetGardenTab.decor) {
      ref.read(petGardenActiveDecorProvider.notifier).state = item.id;
      playTemporaryAnimation(PetAnimationState.loving);
    } else {
      playTemporaryAnimation(PetAnimationState.feeding);
    }

    return true;
  }

  Map<String, int> _readInventory(Map<String, dynamic> source) {
    final normalized = Map<String, int>.from(PetGardenCatalog.initialInventory);
    final raw = source['inventory'];

    if (raw is Map) {
      for (final entry in raw.entries) {
        normalized[entry.key.toString()] = (entry.value as num?)?.toInt() ?? 0;
      }
    }

    return normalized;
  }

  Map<String, dynamic> _basePetDoc(String coupleId) {
    final now = Timestamp.now();
    return {
      'coupleId': coupleId,
      'name': 'Baby Egg',
      'level': 1,
      'experience': 0.0,
      'totalXp': 0.0,
      'hunger': 100.0,
      'happiness': 100.0,
      'lastFed': now,
      'lastInteracted': now,
      'inventory': PetGardenCatalog.initialInventory,
      'updatedAt': now,
    };
  }
}
