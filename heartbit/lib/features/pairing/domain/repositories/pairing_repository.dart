
import '../entities/couple_entity.dart';

abstract class PairingRepository {
  Future<String> generatePairingCode(String userId);
  Future<String?> validatePairingCode(String code);
  Future<CoupleEntity> joinWithCode({
    required String currentUserId,
    required String partnerUserId,
    required String code,
  });
  Future<String?> getCurrentPairingCode(String userId);
  Future<void> cancelPairingCode(String userId);
  Future<CoupleEntity?> getCoupleForUser(String userId);
  Stream<CoupleEntity?> watchCoupleForUser(String userId);
  Future<void> leaveCouple(String userId);
}
