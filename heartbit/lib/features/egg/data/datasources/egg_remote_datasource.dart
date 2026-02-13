
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class EggRemoteDataSource {
  Future<void> incrementWarmth(String coupleId, int amount);
  Future<void> setHatched(String coupleId);
}

class EggRemoteDataSourceImpl implements EggRemoteDataSource {
  final FirebaseFirestore _firestore;

  EggRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _couplesCollection =>
      _firestore.collection('couples');

  @override
  Future<void> incrementWarmth(String coupleId, int amount) async {
    final docRef = _couplesCollection.doc(coupleId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentWarmth = (data['eggWarmth'] as num?)?.toInt() ?? 0;
      final isHatched = data['isHatched'] as bool? ?? false;

      if (isHatched) return; // Already hatched

      final newWarmth = (currentWarmth + amount).clamp(0, 1000);
      
      final updates = <String, dynamic>{
        'eggWarmth': newWarmth,
        'lastEggInteraction': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };

      // Auto-hatch if reached 1000
      if (newWarmth >= 1000) {
        updates['isHatched'] = true;
      }

      transaction.update(docRef, updates);
    });
  }

  @override
  Future<void> setHatched(String coupleId) async {
    await _couplesCollection.doc(coupleId).update({
      'isHatched': true,
      'updatedAt': Timestamp.now(),
    });
  }
}
