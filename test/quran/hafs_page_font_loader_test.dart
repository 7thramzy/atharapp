import 'package:athaar/features/quran/data/hafs_page_font_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads a Hafs page font set from bundled assets into memory', () async {
    await HafsPageFontLoader.ensurePageLoaded(1);

    expect(HafsPageFontLoader.isPageLoaded(1), isTrue);
  });

  test('coalesces concurrent loads for one page', () async {
    await Future.wait([
      HafsPageFontLoader.ensurePageLoaded(2),
      HafsPageFontLoader.ensurePageLoaded(2),
    ]);

    expect(HafsPageFontLoader.isPageLoaded(2), isTrue);
  });

  test('rejects pages outside the 604-page Mushaf', () async {
    await expectLater(
      HafsPageFontLoader.ensurePageLoaded(0),
      throwsRangeError,
    );
    await expectLater(
      HafsPageFontLoader.ensurePageLoaded(605),
      throwsRangeError,
    );
  });
}
