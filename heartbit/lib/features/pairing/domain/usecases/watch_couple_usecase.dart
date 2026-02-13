import '../entities/couple_entity.dart';
import '../repositories/pairing_repository.dart';

class WatchCoupleUseCase {
  final PairingRepository _repository;

  WatchCoupleUseCase(this._repository);

  Stream<CoupleEntity?> call(String userId) {
    return _repository.watchCoupleForUser(userId);
  }
}
