import 'dart:async';

import 'package:athaar/core/notifications/athaar_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Optional remote announcements. The app remains usable when Firebase is absent.
class AthaarPushNotifications {
  AthaarPushNotifications._();

  static const String _topic = 'athaar_all';
  static bool _ready = false;

  static Future<bool> initialize() async {
    if (kIsWeb ||
        ![TargetPlatform.android, TargetPlatform.iOS]
            .contains(defaultTargetPlatform)) {
      return false;
    }
    if (_ready) return true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        if (notification == null) {
          return;
        }
        unawaited(AthaarNotifications.showAdminBroadcast(
          title: notification.title ?? 'إشعار من أثَر',
          body: notification.body ?? '',
        ));
      });
      _ready = true;
      return true;
    } catch (_) {
      // Builds without native Firebase configuration retain all local features.
      return false;
    }
  }

  /// Subscribes only after the user explicitly opts in from notification settings.
  static Future<bool> setBroadcastEnabled(bool enabled) async {
    if (!_ready && !await initialize()) return false;
    try {
      final messaging = FirebaseMessaging.instance;
      if (enabled) {
        final settings = await messaging.requestPermission(
          alert: true, badge: true, sound: true, provisional: false,
        );
        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
          return false;
        }
        await messaging.subscribeToTopic(_topic);
      } else {
        await messaging.unsubscribeFromTopic(_topic);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
