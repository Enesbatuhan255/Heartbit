import '../repositories/user_repository.dart';

class UpdateProfilePhotoUseCase {
  final UserRepository _repository;

  UpdateProfilePhotoUseCase(this._repository);

  Future<void> call(String uid, String photoUrl) {
    return _repository.updateProfilePhoto(uid, photoUrl);
  }
}
