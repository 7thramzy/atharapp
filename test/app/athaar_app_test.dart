import 'package:athaar/app/athaar_app.dart';
import 'package:athaar/features/settings/presentation/settings_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the refreshed Arabic home screen on startup', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: AthaarApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('أهلاً بك في أثَر'), findsOneWidget);
    expect(find.text('مسارك'), findsOneWidget);
    expect(find.text('القرآن الكريم'), findsOneWidget);
  });

  testWidgets(
    'does not expose stale test downloads before production signing',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('تنزيل التطبيق'), findsOneWidget);
      expect(
        find.textContaining('روابط النسخ التجريبية أزيلت من واجهة المستخدم'),
        findsOneWidget,
      );

      // No temporary test release, expiring Actions run, or unpublished
      // platform package is presented as a distributable download.
      expect(find.text('Android — نسخة اختبار'), findsNothing);
      expect(find.text('Windows — مثبت تجريبي'), findsNothing);
      expect(find.text('iPhone و iPad'), findsNothing);
      expect(find.text('النسخة الخفيفة'), findsNothing);
      expect(find.textContaining('v0.2.1-test'), findsNothing);
      expect(find.textContaining('45697658826'), findsNothing);
    },
  );
}
