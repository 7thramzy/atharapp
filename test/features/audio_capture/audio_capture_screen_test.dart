import 'dart:async';

import 'package:athaar/app/athaar_app.dart';
import 'package:athaar/features/audio_capture/audio_capture_gateway.dart';
import 'package:athaar/features/audio_capture/audio_capture_screen.dart';
import 'package:athaar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioCaptureScreen', () {
    late FakeAudioCaptureGateway gateway;

    setUp(() => gateway = FakeAudioCaptureGateway());

    testWidgets('home shortcut opens the audio route', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [_gatewayOverride(gateway)],
          child: const AthaarApp(),
        ),
      );
      await tester.pumpAndSettle();

      final entry = find.text('تسجيل صوتي خاص');
      await tester.ensureVisible(entry);
      await tester.tap(entry);
      await tester.pumpAndSettle();

      expect(find.text('تسجيل صوتي محلي'), findsOneWidget);
    });

    testWidgets('shows accessible record, playback, and delete controls',
        (tester) async {
      gateway.playCompleter = Completer<void>();
      await tester.pumpWidget(_testApp(gateway));
      await tester.pumpAndSettle();

      expect(find.text('صوتك يبقى على جهازك'), findsOneWidget);
      expect(find.text('ابدأ التسجيل'), findsOneWidget);
      expect(
        find.text(
          'لا يُرفع التسجيل ولا يُحفظ في سجل دائم. يبقى مؤقتاً أثناء وجودك '
          'في هذه الشاشة ثم يُحذف عند مغادرتها. لا يوجد بث لتلاوات أو تقييم '
          'آلي في هذه الميزة.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('audio-start')));
      await tester.pumpAndSettle();
      expect(find.text('التسجيل جارٍ الآن'), findsOneWidget);
      expect(find.text('إيقاف التسجيل'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('audio-stop-recording')));
      await tester.pumpAndSettle();
      expect(
        find.text('اكتمل التسجيل المؤقت. يمكنك الاستماع إليه أو حذفه.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('audio-play')), findsOneWidget);
      expect(find.byKey(const ValueKey('audio-delete')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('audio-play')));
      await tester.pump();
      expect(find.text('إيقاف التشغيل'), findsOneWidget);
      expect(gateway.playedPaths, [FakeAudioCaptureGateway.recordingPath]);

      await tester.tap(find.byKey(const ValueKey('audio-stop-playback')));
      await tester.pumpAndSettle();
      expect(find.text('استمع إلى التسجيل'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('audio-delete')));
      await tester.pumpAndSettle();
      expect(find.text('جاهز للتسجيل عند طلبك'), findsOneWidget);
      expect(gateway.deletedPaths, [FakeAudioCaptureGateway.recordingPath]);
    });

    testWidgets('explains microphone denial without starting a recording',
        (tester) async {
      gateway.permissionGranted = false;
      await tester.pumpWidget(_testApp(gateway));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('audio-start')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'لم يُمنح إذن الميكروفون. يمكنك السماح به من إعدادات الجهاز ثم المحاولة مجدداً.',
        ),
        findsOneWidget,
      );
      expect(gateway.startCalls, 0);
      expect(find.text('ابدأ التسجيل'), findsOneWidget);
    });
  });
}

Widget _testApp(FakeAudioCaptureGateway gateway) => ProviderScope(
  overrides: [_gatewayOverride(gateway)],
  child: MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar'),
    home: const AudioCaptureScreen(),
  ),
);

_gatewayOverride(FakeAudioCaptureGateway gateway) =>
    audioCaptureGatewayProvider.overrideWith((ref) {
      ref.onDispose(() => unawaited(gateway.dispose()));
      return gateway;
    });

class FakeAudioCaptureGateway implements AudioCaptureGateway {
  static const recordingPath = '/tmp/athaar_capture_widget_test.wav';

  bool permissionGranted = true;
  int startCalls = 0;
  int disposeCalls = 0;
  Completer<void>? playCompleter;
  final List<String> playedPaths = [];
  final List<String> deletedPaths = [];

  @override
  Future<void> prepare() async {}

  @override
  Future<bool> requestMicrophonePermission() async => permissionGranted;

  @override
  Future<String> startRecording() async {
    startCalls++;
    return recordingPath;
  }

  @override
  Future<String?> stopRecording() async => recordingPath;

  @override
  Future<void> cancelRecording() async {}

  @override
  Future<void> play(String filePath) {
    playedPaths.add(filePath);
    return playCompleter?.future ?? Future<void>.value();
  }

  @override
  Future<void> stopPlayback() async {
    if (playCompleter != null && !playCompleter!.isCompleted) {
      playCompleter!.complete();
    }
  }

  @override
  Future<void> deleteRecording(String filePath) async {
    deletedPaths.add(filePath);
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    if (playCompleter != null && !playCompleter!.isCompleted) {
      playCompleter!.complete();
    }
  }
}
