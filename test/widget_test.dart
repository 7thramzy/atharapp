import 'package:athaar/app/athaar_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Athaar application', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AthaarApp()));

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(AthaarApp), findsOneWidget);
    expect(find.text('مرحباً بك في أثَر'), findsOneWidget);
  });
}
