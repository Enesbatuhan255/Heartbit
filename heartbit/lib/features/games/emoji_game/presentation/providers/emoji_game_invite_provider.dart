import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heartbit/shared/providers/firebase_providers.dart';
import 'package:heartbit/features/auth/presentation/providers/auth_provider.dart';

part 'emoji_game_invite_provider.g.dart';

/// Represents an Emoji Game invitation
class EmojiGameInvite {
  final String id;
  final String sessionId;
  final String coupleId;
  final String fromUserId;
  final DateTime createdAt;

  EmojiGameInvite({
    required this.id,
    required this.sessionId,
    required this.coupleId,
    required this.fromUserId,
    required this.createdAt,
  });

  factory EmojiGameInvite.fromMap(String id, Map<String, dynamic> map) {
    return EmojiGameInvite(
      id: id,
      sessionId: map['sessionId'] as String? ?? '',
      coupleId: map['coupleId'] as String? ?? '',
      fromUserId: map['fromUserId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Watches for Emoji Game invitations for the current user
@riverpod
Stream<List<EmojiGameInvite>> emojiGameInvites(EmojiGameInvitesRef ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final userId = ref.watch(authUserIdProvider);

  if (userId == null) return const Stream.empty();

  return firestore
      .collection('notifications')
      .where('targetUserId', isEqualTo: userId)
      .where('type', isEqualTo: 'emoji_game_invite')
      .snapshots()
      .map((snapshot) {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 2));

    final invites = snapshot.docs
        .where((doc) => doc.data()['dismissedAt'] == null)
        .map((doc) => EmojiGameInvite.fromMap(doc.id, doc.data()))
        .where((invite) => invite.createdAt.isAfter(cutoff))
        .toList();

    invites.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return invites.isNotEmpty ? [invites.first] : <EmojiGameInvite>[];
  });
}

/// Marks an Emoji Game invite as dismissed/read
@riverpod
Future<void> dismissEmojiGameInvite(DismissEmojiGameInviteRef ref, String inviteId) async {
  final firestore = ref.watch(firebaseFirestoreProvider);
  await firestore.collection('notifications').doc(inviteId).update({
    'sent': true,
    'dismissedAt': FieldValue.serverTimestamp(),
  });
}
