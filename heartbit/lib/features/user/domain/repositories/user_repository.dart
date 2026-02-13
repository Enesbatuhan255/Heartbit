
import '../entities/user_profile.dart';

abstract class UserRepository {
  Stream<UserProfile?> watchUser(String uid);
  Future<UserProfile?> getUser(String uid);
  Future<void> updateStatus(String uid, String status);
  Future<void> updateDisplayName(String uid, String displayName);
  Future<void> updateLastSeen(String uid);
  Future<String> uploadProfileImage(String uid, String filePath);
  Future<void> updateProfilePhoto(String uid, String photoUrl);
  Future<void> updateInteraction(String uid);
}
