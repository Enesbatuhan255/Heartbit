import '../entities/couple_entity.dart';
import '../repositories/pairing_repository.dart';

class JoinWithCodeUseCase {
  final PairingRepository _repository;

  JoinWithCodeUseCase(this._repository);

  Future<CoupleEntity> call({
    required String currentUserId,
    required String code,
  }) async {
    // 1. Validate code and find partner
    final partnerUserId = await _repository.validatePairingCode(code);
    
    if (partnerUserId == null) {
      throw Exception('Invalid or expired pairing code');
    }

    if (partnerUserId == currentUserId) {
      throw Exception('You cannot pair with yourself');
    }

    // 2. Create pairing
    return await _repository.joinWithCode(
      currentUserId: currentUserId,
      partnerUserId: partnerUserId,
    );
  }
}
