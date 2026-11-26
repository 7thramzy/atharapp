import 'package:athaar/app/athaar_app.dart';
import 'package:athaar/features/settings/presentation/settings_screen.dart';
import 'package:athaar/features/about/presentation/about_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the refreshed Arabic home screen on startup', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AthaarApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('أهلاً بك في أثَر'), findsOneWidget);
    expect(find.text('مسارك'), findsOneWidget);
    expect(find.text('القرآن الكريم'), findsOneWidget);
  });
  testWidgets('shows only published platform installers in the download center', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('تنزيل التطبيق'), findsOneWidget);
    expect(find.text('Android'), findsOneWidget);
    expect(find.text('Windows'), findsOneWidget);
    expect(find.textContaining('رابط تنزيل'), findsNothing);
    expect(find.text('iPhone و iPad'), findsOneWidget);
    expect(find.text('النسخة الخفيفة'), findsOneWidget);
    expect(find.textContaining('غير منشور بعد'), findsNothing);
    expect(find.textContaining('لم تُبنَ أو تُختبر بعد'), findsOneWidget);
  });

  testWidgets('About screen shows Quran and QCF source credits', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tanzil Project'), findsWidgets);
    expect(find.textContaining('qcf_quran_plus 0.1.1'), findsWidgets);
    expect(find.textContaining('4b91f9e6e8ac645d'), findsOneWidget);
    expect(find.textContaining('لا ندّعي ملكيتها'), findsOneWidget);
  });

}
