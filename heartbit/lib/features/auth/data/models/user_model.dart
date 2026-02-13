
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    required super.isAnonymous,
  });

  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      isAnonymous: user.isAnonymous,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      isAnonymous: isAnonymous,
    );
  }
}
