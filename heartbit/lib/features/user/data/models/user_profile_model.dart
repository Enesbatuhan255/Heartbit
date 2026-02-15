
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  static UserProfile fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      status: data['status'] as String?,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      isOnline: data['isOnline'] as bool? ?? false,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> toMap(UserProfile user) {
    return {
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'status': user.status,
      'lastSeen': user.lastSeen != null ? Timestamp.fromDate(user.lastSeen!) : null,
      'isOnline': user.isOnline,
      'latitude': user.latitude,
      'longitude': user.longitude,
      'updatedAt': Timestamp.now(),
    };
  }
}
