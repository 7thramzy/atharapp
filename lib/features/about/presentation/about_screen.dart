import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  String _text(BuildContext context, String ar, String en) =>
      _isArabic(context) ? ar : en;

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(context, 'تعذّر فتح الرابط الخارجي.', 'Unable to open the link.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_text(context, 'حول أثَر والمصادر', 'About Athaar & sources')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أثَر | Athaar',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _text(
                      context,
                      'رفيق محلي للقراءة والذكر والحفظ. لا يتطلب حساباً في النسخة الحالية.',
                      'A local companion for Quran reading, adhkar and memorization. No account is required in the current version.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SourceCard(
            title: _text(context, 'نص القرآن الكريم — Tanzil', 'Quran text — Tanzil'),
            subtitle: 'Tanzil Project · Uthmani v1.1',
            details: _text(
              context,
              'النص العربي المحلي في وضع القراءة النصي هو Tanzil Uthmani v1.1. يضم 114 سورة و6,236 آية. بصمة الملف المصدر SHA-256: 4b91f9e6e8ac645d039e4ed85b3be492e795232a31cd22d668ac58238722e26f. يُعرض النص كما تم الحصول عليه دون تعديل؛ وتبقى أي تطبيعات بحثية منفصلة عن النص المعروض. شروط Tanzil تتطلب نسبة المصدر ورابطه وعدم تغيير النص.',
              'The local Arabic text in the text-reading mode is Tanzil Uthmani v1.1: 114 surahs and 6,236 ayahs. Source-file SHA-256: 4b91f9e6e8ac645d039e4ed85b3be492e795232a31cd22d668ac58238722e26f. The displayed canonical text is kept verbatim; any search normalization is separate. Tanzil requires attribution, a source link and no alteration of the text.',
            ),
            license: 'CC BY 3.0 · Verbatim use · No text modification',
            onOpen: () => _open(context, Uri.https('tanzil.net', '/download/')),
            onLicense: () => _open(
              context,
              Uri.https('tanzil.net', '/docs/Text_License'),
            ),
          ),
          const SizedBox(height: 10),
          _SourceCard(
            title: _text(context, 'مصحف حفص ذو 604 صفحات — QCF', '604-page Hafs Mushaf — QCF'),
            subtitle: 'qcf_quran_plus 0.1.1 · QCF / Hafs',
            details: _text(
              context,
              'يعرض أثَر المصحف بترتيب صفحات حفص عن عاصم باستخدام الحزمة qcf_quran_plus 0.1.1. صفحة الحزمة تنص على أن كود الحزمة مرخّص MIT وتصف الخطوط بأنها خطوط QCF الرسمية. رخصة MIT المنشورة تخص كود الحزمة؛ ولم نعثر داخل مستودع الحزمة على إشعار منفصل يحدد رخصة ملفات الخطوط وبيانات الصفحات أو تصريحاً مستقلاً بإعادة توزيعها. نذكر مصدر الأصول كما وصفه ناشر الحزمة ولا ندّعي ملكيتها أو أن مجمع الملك فهد صادق على تطبيق أثَر. يلزم توثيق إذن الملفات الثنائية نفسها قبل اعتماد التوزيع العام.',
              'Athaar renders the 604-page Hafs Mushaf using qcf_quran_plus 0.1.1. The package page states that its package code is MIT-licensed and describes the fonts as official QCF fonts. The published MIT licence applies to the package code; we did not find a separate font/page-data licence notice or standalone redistribution permission in the package repository. We credit the assets as described by the package publisher, do not claim ownership, and do not imply endorsement by King Fahd Complex. Written confirmation for the bundled binary assets is still required before unrestricted public distribution.',
            ),
            license: 'Package code: MIT · QCF font/page asset terms: separate confirmation pending',
            onOpen: () => _open(
              context,
              Uri.https('pub.dev', '/packages/qcf_quran_plus/versions/0.1.1'),
            ),
            onLicense: () => _open(
              context,
              Uri.https('github.com', '/hussein12347/qcf_quran_plus'),
            ),
            warning: true,
          ),
          const SizedBox(height: 10),
          _SourceCard(
            title: _text(context, 'التفسير — الجامع الوجيز', 'Tafsir — Al-Jami’ Al-Wajiz'),
            subtitle: 'Sheikh Dr. Ayman Fathih Al-Amer · v1.2.3',
            details: _text(
              context,
              'يُطلب نص التفسير للآية المختارة من الإصدار المثبت ويُعرض دون تعديل. يُنسب إلى المؤلف ويُربط بمصدره. لا يتم تضمين قاعدة التفسير أو تخزين نسخة غير متصلة في الإصدار الحالي.',
              'The selected ayah’s tafsir is fetched from the pinned edition and shown unchanged, with author and source attribution. The tafsir database is not bundled and is not currently available offline.',
            ),
            license: 'CC BY-ND 4.0 · Attribution required · No adaptations',
            onOpen: () => _open(
              context,
              Uri.https('github.com', '/spa5k/tafsir_api/tree/v1.2.3'),
            ),
            onLicense: () => _open(
              context,
              Uri.https('github.com', '/yamanamr/quran-tafsir-jami-wajiz/blob/main/LICENSE'),
            ),
          ),
          const SizedBox(height: 10),
          _SourceCard(
            title: _text(context, 'ترجمات معاني القرآن', 'Translations of Quran meanings'),
            subtitle: 'QuranEnc API',
            details: _text(
              context,
              'يتم جلب قائمة الترجمات ونص الآية والحواشي عند الطلب من QuranEnc. تعرض الواجهة اسم النسخة وإصدارها ووصفها والاتجاه ومصدرها. تختلف حقوق كل ترجمة عن الأخرى؛ لذلك لا يُضمّن أثَر قاعدة ترجمات ثابتة.',
              'The translation catalogue, ayah text and footnotes are fetched on demand from QuranEnc. The app displays the edition title, version, description, direction and source. Rights differ by translation, so Athaar does not bundle a static translations database.',
            ),
            license: 'Per-edition terms · Attribute the publisher/translator',
            onOpen: () => _open(
              context,
              Uri.https('quranenc.com', '/ar/home/api'),
            ),
            onLicense: () => _open(
              context,
              Uri.https('quranenc.com', '/en/home/about/conditions'),
            ),
          ),
          const SizedBox(height: 10),
          _SourceCard(
            title: _text(context, 'التلاوات الصوتية', 'Recitations'),
            subtitle: 'AlQuran Cloud / Islamic Network',
            details: _text(
              context,
              'يمكن بث الآية عند الاتصال بالإنترنت، أو تنزيل سورة بطلب المستخدم للاستماع دون اتصال. تُحفظ الملفات في مساحة أثَر الخاصة على الجهاز، ويمكن حذفها من شاشة التلاوة. لا يرفع أثَر التسجيلات ولا يعيد استضافتها ولا يتيح تصدير الملفات. حقوق التسجيلات تعود إلى القراء أو أصحاب الحقوق، وقد يطلب صاحب التسجيل إيقاف إتاحته. الاستخدام الحالي تعليمي وشخصي فقط.',
              'Ayahs can be streamed online, or a user can explicitly download a surah for offline listening. Files stay in Athaar’s private app storage and can be deleted from the recitation screen. Athaar does not upload, re-host or export recordings. Recordings remain copyrighted by their reciters/rightsholders, who may request removal. Current use is personal and educational.',
            ),
            license: 'Provider terms · Reciter copyrights remain with their owners',
            onOpen: () => _open(
              context,
              Uri.https('alquran.cloud', '/cdn'),
            ),
            onLicense: () => _open(
              context,
              Uri.https('alquran.cloud', '/terms-and-conditions'),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _text(
                  context,
                  'ملاحظة مهمة: ظهور المصدر في هذه الصفحة لا يعني أن أثَر يملك المحتوى. نلتزم بنسبة المصادر وقيودها، وسنعطل أي مورد إذا سُحبت إتاحته أو تعذّر إثبات حق استخدامه.',
                  'Important: listing a source here does not mean Athaar owns the content. We provide attribution, respect source limitations and will disable a resource if access is withdrawn or its use cannot be substantiated.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.title,
    required this.subtitle,
    required this.details,
    required this.license,
    required this.onOpen,
    required this.onLicense,
    this.warning = false,
  });

  final String title;
  final String subtitle;
  final String details;
  final String license;
  final VoidCallback onOpen;
  final VoidCallback onLicense;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            )),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            )),
            const SizedBox(height: 10),
            Text(details, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65)),
            const SizedBox(height: 10),
            Text(
              license,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: warning ? colors.error : colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'المصدر'
                        : 'Source',
                  ),
                ),
                TextButton.icon(
                  onPressed: onLicense,
                  icon: const Icon(Icons.gavel_rounded, size: 16),
                  label: Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'الترخيص والتوثيق'
                        : 'Licence & documentation',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
