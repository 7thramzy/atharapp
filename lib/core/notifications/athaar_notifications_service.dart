import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final athaarNotificationsServiceProvider =
    Provider<AthaarNotificationsService>((ref) {
  final service = AthaarNotificationsService();
  ref.onDispose(service.dispose);
  return service;
});

/// Local notification service. It does not require a cloud project or send
/// personal data anywhere.
class AthaarNotificationsService {
  AthaarNotificationsService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 7401;
  static const String _channelId = 'athaar_daily_reminders';
  static const String _channelName = 'تذكيرات أثَر';
  static const String _channelDescription =
      'تذكيرات الورد والقراءة والمراجعة في أثَر';

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String?> _tapController =
      StreamController<String?>.broadcast();

  Future<void>? _initialization;

  Stream<String?> get notificationTaps => _tapController.stream;

  bool get supportsDailyScheduling {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  bool get supportsForegroundNotifications => kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();

    // Fail explicitly rather than accidentally scheduling reminders in UTC.
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const windowsSettings = WindowsInitializationSettings(
      appName: 'أثَر',
      appUserModelId: 'com.athaar.athaar',
      guid: '9c6a9c31-8b7f-4f8f-8ce7-d0a07fa4c96b',
    );
    const webSettings = WebInitializationSettings(
      defaultIcon: 'icons/Icon-192.png',
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        windows: windowsSettings,
        web: webSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        _tapController.add(response.payload);
      },
    );
  }

  /// Must be called from a clear user action, not automatically at launch.
  Future<bool> requestPermission() async {
    await initialize();

    if (kIsWeb) {
      final web = _plugin.resolvePlatformSpecificImplementation<
          WebFlutterLocalNotificationsPlugin>();
      if (web == null) return false;
      if (web.permissionStatus == WebNotificationPermission.granted) {
        return true;
      }
      return await web.requestNotificationsPermission() ==
          WebNotificationPermission.granted;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? false;
      case TargetPlatform.iOS:
        final ios = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        return await ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      case TargetPlatform.windows:
        // Windows toast delivery is controlled by Windows notification settings
        // and the registered Start Menu shortcut created by the installer.
        return true;
      default:
        return false;
    }
  }

  Future<void> showTestNotification() async {
    await initialize();
    await _plugin.show(
      id: 7402,
      title: 'أثَر',
      body: 'الإشعارات المحلية مفعّلة على هذا الجهاز.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          threadIdentifier: 'athaar-reminders',
        ),
        windows: WindowsNotificationDetails(),
      ),
      payload: 'athaar://notifications/test',
    );
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    if (!supportsDailyScheduling) {
      throw UnsupportedError(
        'يتيح هذا النظام الإشعارات الفورية، ولا يدعم الجدولة اليومية هنا.',
      );
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw RangeError('Invalid local reminder time.');
    }

    await initialize();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'وردك اليومي في أثَر',
      body: 'خذ وقتك مع القرآن والذكر والمراجعة.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
          threadIdentifier: 'athaar-reminders',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'athaar://memorization',
    );
  }

  Future<void> cancelDailyReminder() async {
    await initialize();
    await _plugin.cancel(id: _dailyReminderId);
  }

  Future<void> dispose() async {
    await _tapController.close();
  }
}
