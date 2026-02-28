import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';

class StoryChainInvite {
  final String id;
  final String sessionId;
  final String coupleId;
  final String fromUserId;
  final DateTime createdAt;

  const StoryChainInvite({
    required this.id,
    required this.sessionId,
    required this.coupleId,
    required this.fromUserId,
    required this.createdAt,
  });

  factory StoryChainInvite.fromMap(String id, Map<String, dynamic> map) {
    final createdAt =
        (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return StoryChainInvite(
      id: id,
      sessionId: map['sessionId'] as String? ?? '',
      coupleId: map['coupleId'] as String? ?? '',
      fromUserId: map['fromUserId'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}

final storyChainInvitesProvider = StreamProvider<List<StoryChainInvite>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final userId = ref.watch(authUserIdProvider);

  if (userId == null) return const Stream<List<StoryChainInvite>>.empty();

  return firestore
      .collection('notifications')
      .where('targetUserId', isEqualTo: userId)
      .where('type', isEqualTo: 'story_chain_invite')
      .snapshots()
      .map((snapshot) {
    final invites = snapshot.docs
        .where((doc) =>
            doc.data()['dismissedAt'] == null && doc.data()['rejected'] != true)
        .map((doc) => StoryChainInvite.fromMap(doc.id, doc.data()))
        .toList();

    invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return invites.isNotEmpty ? [invites.first] : <StoryChainInvite>[];
  });
});

final dismissStoryChainInviteProvider =
    FutureProvider.family<void, String>((ref, inviteId) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  await firestore.collection('notifications').doc(inviteId).update({
    'sent': true,
    'dismissedAt': FieldValue.serverTimestamp(),
  });
});
