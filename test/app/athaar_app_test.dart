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
    'shows only published platform installers in the download center',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: SettingsScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('تنزيل التطبيق'), findsOneWidget);
      expect(find.text('Android — نسخة اختبار'), findsOneWidget);
      expect(find.text('Windows — مثبت تجريبي'), findsOneWidget);
      expect(find.text('iPhone و iPad'), findsOneWidget);
      expect(find.text('النسخة الخفيفة'), findsOneWidget);
      expect(find.textContaining('غير منشور بعد'), findsOneWidget);
      expect(find.textContaining('لم تُبنَ نسخة خفيفة مستقلة'), findsOneWidget);
    },
  );
}
