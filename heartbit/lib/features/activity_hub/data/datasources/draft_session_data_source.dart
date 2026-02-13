import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/draft_session.dart';

class DraftSessionDataSource {
  final FirebaseFirestore _firestore;

  DraftSessionDataSource(this._firestore);

  Stream<DraftSession?> watchDraft(String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('session')
        .doc('draft')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return DraftSession.fromJson(snapshot.data()!);
    });
  }

  Future<void> updateDraft(String coupleId, DraftSession draft) async {
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('session')
        .doc('draft')
        .set(draft.toJson(), SetOptions(merge: true));
  }

  Future<void> clearDraft(String coupleId) async {
    // Instead of deleting, we reset it to default to keep the document alive if needed,
    // or we can delete. Let's reset to defaults for cleaner state.
    // Actually, deleting is fine if we handle null gracefully.
    await _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('session')
        .doc('draft')
        .delete();
  }
}
