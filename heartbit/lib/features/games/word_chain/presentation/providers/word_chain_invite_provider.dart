import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';

class WordChainInvite {
  final String id;
  final String sessionId;
  final String coupleId;
  final String fromUserId;
  final DateTime createdAt;

  const WordChainInvite({
    required this.id,
    required this.sessionId,
    required this.coupleId,
    required this.fromUserId,
    required this.createdAt,
  });

  factory WordChainInvite.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = (map['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return WordChainInvite(
      id: id,
      sessionId: map['sessionId'] as String? ?? '',
      coupleId: map['coupleId'] as String? ?? '',
      fromUserId: map['fromUserId'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}

final wordChainInvitesProvider = StreamProvider<List<WordChainInvite>>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final userId = ref.watch(authUserIdProvider);

  if (userId == null) return const Stream<List<WordChainInvite>>.empty();

  return firestore
      .collection('notifications')
      .where('targetUserId', isEqualTo: userId)
      .where('type', isEqualTo: 'word_chain_invite')
      .snapshots()
      .map((snapshot) {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 2));

    final invites = snapshot.docs
        .where((doc) => doc.data()['dismissedAt'] == null)
        .map((doc) => WordChainInvite.fromMap(doc.id, doc.data()))
        .where((invite) => invite.createdAt.isAfter(cutoff))
        .toList();

    invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return invites.isNotEmpty ? [invites.first] : <WordChainInvite>[];
  });
});

final dismissWordChainInviteProvider =
    FutureProvider.family<void, String>((ref, inviteId) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  await firestore.collection('notifications').doc(inviteId).update({
    'sent': true,
    'dismissedAt': FieldValue.serverTimestamp(),
  });
});
