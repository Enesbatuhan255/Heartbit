import '../repositories/user_repository.dart';

class UploadProfileImageUseCase {
  final UserRepository _repository;

  UploadProfileImageUseCase(this._repository);

  Future<String> call(String uid, String filePath) {
    return _repository.uploadProfileImage(uid, filePath);
  }
}
