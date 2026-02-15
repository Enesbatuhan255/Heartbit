import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/features/pairing/presentation/providers/pairing_provider.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import '../../domain/entities/draft_session.dart';
import '../../data/datasources/draft_session_data_source.dart';

part 'draft_session_provider.g.dart';

@riverpod
DraftSessionDataSource draftSessionDataSource(DraftSessionDataSourceRef ref) {
  return DraftSessionDataSource(ref.read(firebaseFirestoreProvider));
}

@riverpod
Stream<DraftSession?> sharedDraftSession(SharedDraftSessionRef ref) {
  final coupleAsync = ref.watch(coupleStateProvider);
  
  print('🔔 sharedDraftSession: coupleAsync.hasValue=${coupleAsync.hasValue}');
  
  if (!coupleAsync.hasValue || coupleAsync.value == null) {
    print('🔔 sharedDraftSession: No couple data, returning empty stream');
    return const Stream.empty();
  }
  
  final coupleId = coupleAsync.value!.id;
  print('🔔 sharedDraftSession: Watching draft for coupleId=$coupleId');
  
  final dataSource = ref.watch(draftSessionDataSourceProvider);
  return dataSource.watchDraft(coupleId).map((draft) {
    print('🔔 sharedDraftSession: Draft update received - readyUsers=${draft?.readyUsers}');
    return draft;
  });
}

@riverpod
class DraftSessionController extends _$DraftSessionController {
  @override
  FutureOr<void> build() {
    // No local state needed, we modify via data source
  }

  DraftSession _emptyDraft() => const DraftSession();

  Future<void> _update(DraftSession Function(DraftSession current) updateFn) async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    final coupleId = coupleAsync.value!.id;

    final dataSource = ref.read(draftSessionDataSourceProvider);
    
    // We get the LATEST value from the stream to ensure consistency
    final currentDraftAsync = await ref.read(sharedDraftSessionProvider.future);
    final currentDraft = currentDraftAsync ?? _emptyDraft();
    
    final newDraft = updateFn(currentDraft);
    await dataSource.updateDraft(coupleId, newDraft);
  }

  /// Toggle "Ready" state for the current user
  Future<void> toggleReady() async {
    final userId = ref.read(authUserIdProvider);
    if (userId == null) {
      print('⚠️ toggleReady: No userId found');
      return;
    }

    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) {
      print('⚠️ toggleReady: No couple data found');
      return;
    }
    final couple = coupleAsync.value!;
    
    print('✅ toggleReady: userId=$userId, coupleId=${couple.id}');

    await _update((current) {
      final list = [...current.readyUsers];
      final wasReady = list.contains(userId);
      
      print('✅ toggleReady: wasReady=$wasReady, current readyUsers=$list');
      
      if (wasReady) {
        list.remove(userId);
        print('✅ toggleReady: Removing user from ready list');
      } else {
        list.add(userId);
        print('✅ toggleReady: Adding user to ready list');
        
        // Send FCM notification to partner when becoming ready
        final partnerId = userId == couple.user1Id ? couple.user2Id : couple.user1Id;
        print('✅ toggleReady: Sending notification to partnerId=$partnerId');
        _sendPartnerNotification(couple.id, partnerId);
      }
      
      print('✅ toggleReady: New readyUsers list=$list');
      return current.copyWith(readyUsers: list);
    });
  }
  
  /// Creates a notification document that triggers a Cloud Function to send FCM
  Future<void> _sendPartnerNotification(String coupleId, String partnerId) async {
    try {
      print('📤 _sendPartnerNotification: Creating notification for partnerId=$partnerId');
      final firestore = ref.read(firebaseFirestoreProvider);
      final docRef = await firestore
          .collection('notifications')
          .add({
        'type': 'activity_hub_invite',
        'targetUserId': partnerId,
        'coupleId': coupleId,
        'title': 'Partnerin seni bekliyor! 💕',
        'body': 'Activity Hub\'a katıl ve birlikte seçim yapın!',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      print('📤 _sendPartnerNotification: SUCCESS - docId=${docRef.id}');
    } catch (e) {
      print('❌ _sendPartnerNotification: FAILED - $e');
    }
  }

  /// Enter lobby - adds user to lobbyUsers and notifies partner
  Future<void> enterLobby() async {
    final userId = ref.read(authUserIdProvider);
    if (userId == null) {
      print('⚠️ enterLobby: No userId found');
      return;
    }

    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) {
      print('⚠️ enterLobby: No couple data found');
      return;
    }
    final couple = coupleAsync.value!;
    
    print('🚪 enterLobby: userId=$userId entering lobby');

    await _update((current) {
      final list = [...current.lobbyUsers];
      if (!list.contains(userId)) {
        list.add(userId);
        print('🚪 enterLobby: Added user to lobbyUsers=$list');
        
        // Notify partner
        final partnerId = userId == couple.user1Id ? couple.user2Id : couple.user1Id;
        _sendLobbyEntryNotification(couple.id, partnerId);
      }
      return current.copyWith(lobbyUsers: list);
    });
  }
  
  /// Leave lobby - removes user from lobbyUsers
  Future<void> leaveLobby() async {
    final userId = ref.read(authUserIdProvider);
    if (userId == null) return;

    print('🚪 leaveLobby: userId=$userId leaving lobby');
    
    await _update((current) {
      final list = current.lobbyUsers.where((id) => id != userId).toList();
      return current.copyWith(lobbyUsers: list);
    });
  }
  
  /// Send notification when entering lobby
  Future<void> _sendLobbyEntryNotification(String coupleId, String partnerId) async {
    try {
      print('📤 _sendLobbyEntryNotification: Sending to $partnerId');
      final firestore = ref.read(firebaseFirestoreProvider);
      await firestore
          .collection('notifications')
          .add({
        'type': 'activity_hub_lobby_entry',
        'targetUserId': partnerId,
        'coupleId': coupleId,
        'title': 'Partnerin Activity Hub\'da! 🎯',
        'body': 'Birlikte aktivite seçmek için katıl!',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      print('📤 _sendLobbyEntryNotification: SUCCESS');
    } catch (e) {
      print('❌ _sendLobbyEntryNotification: FAILED - $e');
    }
  }

  // --- Modifiers that RESET ready state ---

  Future<void> toggleCategory(String categoryValue) async {
    await _update((current) {
      final list = [...current.selectedCategories];
      if (list.contains(categoryValue)) {
        list.remove(categoryValue);
      } else {
        list.add(categoryValue);
      }
      // Reset ready state because settings changed
      return current.copyWith(selectedCategories: list, readyUsers: []);
    });
  }
  
  Future<void> toggleBudget(int budget) async {
    await _update((current) {
      final list = [...current.budgetLevels];
      if (list.contains(budget)) {
        list.remove(budget);
      } else {
        list.add(budget);
      }
      return current.copyWith(budgetLevels: list, readyUsers: []);
    });
  }
  
  Future<void> toggleDuration(String tier) async {
    await _update((current) {
      final list = [...current.durationTiers];
      if (list.contains(tier)) {
        list.remove(tier);
      } else {
        list.add(tier);
      }
      return current.copyWith(durationTiers: list, readyUsers: []);
    });
  }

  Future<void> addCustomActivity(String title) async {
    await _update((current) {
      if (current.customActivities.contains(title)) return current;
      return current.copyWith(
        customActivities: [...current.customActivities, title],
        readyUsers: []
      );
    });
  }

  Future<void> removeCustomActivity(String title) async {
    await _update((current) {
      return current.copyWith(
        customActivities: current.customActivities.where((t) => t != title).toList(),
        readyUsers: []
      );
    });
  }
  
  /// Set the active session ID for both partners to use
  Future<void> setActiveSessionId(String sessionId) async {
    print('📝 Saving activeSessionId to DraftSession: $sessionId');
    await _update((current) {
      return current.copyWith(activeSessionId: sessionId);
    });
    print('✅ activeSessionId saved successfully');
  }
  
  Future<void> clear() async {
    final coupleAsync = ref.read(coupleStateProvider);
    if (!coupleAsync.hasValue || coupleAsync.value == null) return;
    await ref.read(draftSessionDataSourceProvider).clearDraft(coupleAsync.value!.id);
  }
}
