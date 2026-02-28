
import 'package:heartbit/features/pairing/domain/entities/couple_entity.dart';
import 'package:heartbit/features/pairing/domain/repositories/pairing_repository.dart';

class FakePairingRepository implements PairingRepository {
  final Map<String, String> _userCodes = {};
  final Map<String, String> _couples = {}; // userId -> coupleId
  final Map<String, CoupleEntity> _coupleEntities = {};

  @override
  Future<String> generatePairingCode(String userId) async {
    final code = 'ABC123'; // Deterministic for testing
    _userCodes[userId] = code;
    return code;
  }

  @override
  Future<String?> validatePairingCode(String code) async {
    // Find key for value
    for (var entry in _userCodes.entries) {
      if (entry.value == code) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  Future<CoupleEntity> joinWithCode({
    required String currentUserId,
    required String partnerUserId,
    required String code,
  }) async {
    final partnerCode = _userCodes[partnerUserId];
    if (partnerCode != null && partnerCode != code) {
      throw ArgumentError('Invalid pairing code');
    }

    final coupleId = 'couple_${currentUserId}_$partnerUserId';
    
    _couples[currentUserId] = coupleId;
    _couples[partnerUserId] = coupleId;
    
    final couple = CoupleEntity(
      id: coupleId, 
      user1Id: partnerUserId, 
      user2Id: currentUserId, 
      totalPoints: 0, 
      level: 1, 
      createdAt: DateTime.now(), 
      updatedAt: DateTime.now()
    );
    
    _coupleEntities[coupleId] = couple;
    return couple;
  }

  @override
  Future<String?> getCurrentPairingCode(String userId) async {
    return _userCodes[userId];
  }

  @override
  Future<void> cancelPairingCode(String userId) async {
    _userCodes.remove(userId);
  }

  @override
  Future<CoupleEntity?> getCoupleForUser(String userId) async {
    final coupleId = _couples[userId];
    if (coupleId == null) return null;
    return _coupleEntities[coupleId];
  }

  @override
  Stream<CoupleEntity?> watchCoupleForUser(String userId) {
    // Simple stream implementation
    final coupleId = _couples[userId];
    if (coupleId == null) return Stream.value(null);
    return Stream.value(_coupleEntities[coupleId]);
  }

  @override
  Future<void> leaveCouple(String userId) async {
    final coupleId = _couples[userId];
    if (coupleId != null) {
      _couples.remove(userId);
      // In a real scenario we'd update status, but for fake just removing mapping is enough for now
      // unless we want to test status specifically in a test using this fake
    }
  }
}
