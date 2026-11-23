import 'package:athaar/app/athaar_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Arabic home screen on startup', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AthaarApp()));

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('مرحباً بك في أثَر'), findsOneWidget);
    expect(find.text('مسارك في أثَر'), findsOneWidget);
  });
}
