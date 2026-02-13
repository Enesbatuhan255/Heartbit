import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Service to handle FCM push notifications
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize notifications and request permissions
  Future<void> initialize(String userId) async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get and save FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(userId, token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _saveToken(userId, newToken);
      });
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> _saveToken(String userId, String token) async {
    await _firestore.collection('users').doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // For foreground, we rely on in-app banners (already implemented)
    // This is a hook for future local notification display if needed
    print('FCM Foreground: ${message.notification?.title}');
  }

  /// Get partner's FCM token to send notification
  Future<String?> getPartnerToken(String partnerId) async {
    final doc = await _firestore.collection('users').doc(partnerId).get();
    return doc.data()?['fcmToken'] as String?;
  }
}

@riverpod
NotificationService notificationService(Ref ref) {
  return NotificationService();
}
