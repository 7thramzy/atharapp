import 'dart:async';
import 'dart:convert';

import 'package:athaar/core/database/database_providers.dart';
import 'package:athaar/core/notifications/athaar_notifications.dart';
import 'package:athaar/core/notifications/athaar_push_notifications.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  TimeOfDay _morning = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _evening = const TimeOfDay(hour: 18, minute: 0);
  bool _morningEnabled = false;
  bool _eveningEnabled = false;
  bool _adminBroadcastsEnabled = false;
  bool _pushReady = false;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPreferences());
    unawaited(_initializePush());
  }

  Future<void> _initializePush() async {
    final ready = await AthaarPushNotifications.initialize();
    if (mounted) setState(() => _pushReady = ready);
  }

  Future<void> _loadPreferences() async {
    try {
      final raw = await ref.read(appDatabaseProvider)
          .readMetadata('notifications.preferences.v1');
      if (raw == null || !mounted) {
        return;
      }
      final value = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _morningEnabled = value['morningEnabled'] == true;
        _eveningEnabled = value['eveningEnabled'] == true;
        _adminBroadcastsEnabled = value['adminBroadcastsEnabled'] == true;
        _morning = TimeOfDay(
          hour: (value['morningHour'] as int?) ?? 7,
          minute: (value['morningMinute'] as int?) ?? 0,
        );
        _evening = TimeOfDay(
          hour: (value['eveningHour'] as int?) ?? 18,
          minute: (value['eveningMinute'] as int?) ?? 0,
        );
      });
    } catch (_) {
      // Invalid local preference data is ignored; defaults remain safe.
    }
  }

  Future<void> _chooseTime(bool morning) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: morning ? _morning : _evening,
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      if (morning) {
        _morning = selected;
      } else {
        _evening = selected;
      }
    });
  }

  Future<void> _apply() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final anyEnabled = _morningEnabled || _eveningEnabled;
      final granted = anyEnabled ? await AthaarNotifications.requestPermission() : true;
      if (!granted) {
        setState(() => _message = 'لم يتم منح إذن الإشعارات. يمكنك تفعيله من إعدادات الجهاز.');
        return;
      }
      if (_morningEnabled) {
        await AthaarNotifications.scheduleDaily(
          id: 4101,
          title: 'وِرد الصباح من أثَر',
          body: 'حان وقت وردك الصباحي. ابدأ بما تيسر.',
          hour: _morning.hour,
          minute: _morning.minute,
        );
      } else {
        await AthaarNotifications.cancel(4101);
      }
      if (_eveningEnabled) {
        await AthaarNotifications.scheduleDaily(
          id: 4102,
          title: 'وِرد المساء من أثَر',
          body: 'خصص دقائق لورد المساء.',
          hour: _evening.hour,
          minute: _evening.minute,
        );
      } else {
        await AthaarNotifications.cancel(4102);
      }
      if (_adminBroadcastsEnabled) {
        if (!_pushReady) throw StateError('خدمة Firebase غير مهيأة لهذا الإصدار بعد.');
        final subscribed = await AthaarPushNotifications.setBroadcastEnabled(true);
        if (!subscribed) throw StateError('لم يتم منح إذن استقبال الإعلانات على هذا الجهاز.');
      } else if (_pushReady) {
        await AthaarPushNotifications.setBroadcastEnabled(false);
      }
      await ref.read(appDatabaseProvider).saveMetadata(
        key: 'notifications.preferences.v1',
        value: jsonEncode({
          'morningEnabled': _morningEnabled,
          'eveningEnabled': _eveningEnabled,
          'morningHour': _morning.hour,
          'morningMinute': _morning.minute,
          'eveningHour': _evening.hour,
          'eveningMinute': _evening.minute,
          'adminBroadcastsEnabled': _adminBroadcastsEnabled,
        }),
      );
      if (mounted) {
        setState(() => _message = 'تم تحديث تذكيرات هذا الجهاز.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'تعذر إعداد التذكيرات: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _reminderTile({
    required String title,
    required String subtitle,
    required bool enabled,
    required TimeOfDay time,
    required VoidCallback onToggle,
    required VoidCallback onTime,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(subtitle),
              value: enabled,
              onChanged: (_) => onToggle(),
            ),
            if (enabled)
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: onTime,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(time.format(context)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الإشعارات والتذكيرات')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'تذكيرات على هذا الجهاز',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('تعمل التذكيرات محلياً ولا تحتاج إلى اتصال بالإنترنت. اختر الأوقات المناسبة لك.'),
            const SizedBox(height: 12),
            _reminderTile(
              title: 'ورد الصباح',
              subtitle: 'تذكير يومي ببدء ورد الصباح',
              enabled: _morningEnabled,
              time: _morning,
              onToggle: () => setState(() => _morningEnabled = !_morningEnabled),
              onTime: () => _chooseTime(true),
            ),
            _reminderTile(
              title: 'ورد المساء',
              subtitle: 'تذكير يومي بورد المساء',
              enabled: _eveningEnabled,
              time: _evening,
              onToggle: () => setState(() => _eveningEnabled = !_eveningEnabled),
              onTime: () => _chooseTime(false),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _busy ? null : _apply,
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('حفظ التذكيرات'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'إشعارات إدارة أثَر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('استقبال إعلانات وتنبيهات الإدارة'),
              subtitle: Text(
                _pushReady
                    ? 'اختياري ويمكن إيقافه في أي وقت. لا يشمل تذكيراتك المحلية.'
                    : 'بانتظار ربط إعدادات مشروع Firebase بهذا التطبيق.',
              ),
              value: _adminBroadcastsEnabled,
              onChanged: _busy || !_pushReady
                  ? null
                  : (value) => setState(() => _adminBroadcastsEnabled = value),
            ),
            const Text(
              'تُرسل الإدارة الإعلانات من لوحة Firebase الرسمية إلى موضوع athaar_all. لا توجد مفاتيح إرسال داخل التطبيق، ولا تُرسل بيانات شخصية إلى خادم خاص بأثر لهذا الغرض.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
}
