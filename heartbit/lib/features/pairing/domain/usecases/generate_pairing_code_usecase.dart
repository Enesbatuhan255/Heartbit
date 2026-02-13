import '../repositories/pairing_repository.dart';

class GeneratePairingCodeUseCase {
  final PairingRepository _repository;

  GeneratePairingCodeUseCase(this._repository);

  Future<String> call(String userId) {
    return _repository.generatePairingCode(userId);
  }
}
