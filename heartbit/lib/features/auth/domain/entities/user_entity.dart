
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final bool isAnonymous;

  const UserEntity({
    required this.uid,
    this.email,
    required this.isAnonymous,
  });

  @override
  List<Object?> get props => [uid, email, isAnonymous];
}
