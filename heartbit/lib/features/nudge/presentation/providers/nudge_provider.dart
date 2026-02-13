import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/features/nudge/domain/entities/nudge_type.dart';
import 'package:heartbit/features/egg/presentation/providers/egg_provider.dart';

part 'nudge_provider.g.dart';

/// Watch for incoming nudges
@riverpod
Stream<Map<String, dynamic>?> nudgeState(NudgeStateRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  final userId = ref.watch(authUserIdProvider);
  
  return coupleAsync.when(
    data: (couple) {
      if (couple == null || userId == null) return Stream.value(null);
      
      final firestore = ref.watch(firebaseFirestoreProvider);
      return firestore
          .collection('couples')
          .doc(couple.id)
          .snapshots()
          .map((snap) {
            if (!snap.exists) return null;
            final data = snap.data();
            if (data == null) return null;
            
            final lastNudgeBy = data['lastNudgeBy'] as String?;
            final lastNudgeType = data['lastNudgeType'] as String?;
            final lastNudgeTime = data['lastNudgeTime'] as Timestamp?;
            
            // Only show nudge if:
            // 1. It was sent by partner (not me)
            // 2. It was recent (within last 10 seconds)
            if (lastNudgeBy != null && 
                lastNudgeBy != userId && 
                lastNudgeTime != null &&
                lastNudgeType != null) {
              final elapsed = DateTime.now().difference(lastNudgeTime.toDate());
              // Increased to 60s for better reliability and clock skew tolerance
              if (elapsed.inSeconds.abs() < 60) {
                return {
                  'type': lastNudgeType,
                  'time': lastNudgeTime.toDate(),
                };
              }
            }
            return null;
          });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
}

/// Controller for sending nudges
@riverpod
class NudgeController extends _$NudgeController {
  @override
  FutureOr<void> build() {}

  Future<bool> sendNudge(NudgeType type) async {
    final coupleAsync = ref.read(coupleStateProvider);
    final userId = ref.read(authUserIdProvider);
    
    if (!coupleAsync.hasValue || coupleAsync.value == null || userId == null) {
      return false;
    }
    
    final coupleId = coupleAsync.value!.id;
    final firestore = ref.read(firebaseFirestoreProvider);
    
    try {
      await firestore.collection('couples').doc(coupleId).update({
        'lastNudgeBy': userId,
        'lastNudgeType': type.key,
        'lastNudgeTime': FieldValue.serverTimestamp(),
      });
      // ADDED: Small warmth boost for nudging
      await ref.read(eggRepositoryProvider).incrementWarmth(coupleId, 5);
      
      return true;
    } catch (e) {
      print('DEBUG: Failed to send nudge: $e');
      return false;
    }
  }
}
