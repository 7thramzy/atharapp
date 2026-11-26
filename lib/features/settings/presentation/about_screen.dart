import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _tanzilUrl = 'https://tanzil.net/docs/Text_License';
  static const _qcfUrl = 'https://github.com/hussein12347/qcf_quran_plus';
  static const _kfgqpcUrl = 'https://qurancomplex.gov.sa/';
  static const _tafsirUrl = 'https://github.com/yamanamr/quran-tafsir-jami-wajiz/blob/main/LICENSE';
  static const _quranEncUrl = 'https://quranenc.com/en/home/about/conditions';
  static const _audioTermsUrl = 'https://alquran.cloud/terms-and-conditions';

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر فتح رابط المصدر.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('حول أثَر ومصادره')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'أثَر',
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'تطبيق للقراءة والذكر والحفظ والتعلّم، مع إبقاء التقدّم الشخصي على الجهاز قدر الإمكان.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          _SourceCard(
            title: 'نص القرآن الكريم — Tanzil Uthmani v1.1',
            status: 'معتمد للنص العربي المعروض دون تعديل',
            statusColor: Colors.green,
            description:
                'المصدر المرجعي للنص العربي داخل أثَر هو مشروع Tanzil، رواية/رسم Uthmani، الإصدار 1.1. حجم ملف المصدر 1,384,612 بايت، وبصمة SHA-256: 4b91f9e6e8ac645d039e4ed85b3be492e795232a31cd22d668ac58238722e26f. يجب إبقاء النص كما ورد، ونسبه إلى Tanzil Project، وإظهار رابط المصدر. أي تطبيع للبحث يجب أن يكون منفصلاً عن النص القرآني الأصلي.',
            attribution: 'Tanzil Project · Uthmani v1.1 · CC BY 3.0 مع شروط Tanzil الإضافية',
            onOpen: () => _open(context, _tanzilUrl),
          ),
          _SourceCard(
            title: 'عرض المصحف — qcf_quran_plus 0.1.1',
            status: 'الكود MIT؛ حقوق الأصول المرفقة تحتاج إثباتاً مستقلاً',
            statusColor: Colors.orange,
            description:
                'تستخدم أثَر الحزمة لعرض مصحف حفص ذي الصفحات الـ604 والخطوط/بيانات التخطيط المرفقة. رخصة MIT تخص كود الحزمة ولا تمنح تلقائياً حقوق إعادة توزيع كل خط أو بيانات صفحات أو أصول طرف ثالث. لذلك نذكر الحزمة ومصدرها صراحةً، ولا نزعم أن جميع أصول QCF حصلت على موافقة توزيع نهائية قبل توثيق الملف الدقيق والجهة المالكة وشروطها. يظل نص Tanzil هو المرجع العربي المستقل ولا يُعدّل بواسطة محرك العرض.',
            attribution:
                'qcf_quran_plus 0.1.1 · مستودع الحزمة · مرجع الجهة الرسمية KFGQPC',
            onOpen: () => _open(context, _qcfUrl),
            secondaryUrl: _kfgqpcUrl,
            secondaryLabel: 'الموقع الرسمي لمجمع الملك فهد',
          ),
          _SourceCard(
            title: 'التفسير — الجامع الوجيز',
            status: 'يُعرض من المصدر دون تعديل',
            statusColor: Colors.green,
            description:
                'الجامع الوجيز في تفسير آي الكتاب العزيز، تأليف الشيخ الدكتور أيمن فاتح آل عامر. النسخة المستخدمة مثبتة عند spa5k/tafsir_api v1.2.3. النص يُعرض حرفياً مع نسبة المؤلف والمصدر، ولا يُعاد صياغته أو تعديله.',
            attribution: 'Dr. Ayman Fathih Al-Amer · CC BY-ND 4.0 · v1.2.3',
            onOpen: () => _open(context, _tafsirUrl),
          ),
          _SourceCard(
            title: 'ترجمات معاني القرآن — QuranEnc',
            status: 'اتصال مباشر؛ الحقوق حسب كل طبعة',
            statusColor: Colors.orange,
            description:
                'تُحمّل قائمة الترجمات والنصوص والحواشي عند طلبها من QuranEnc. يُعرض اسم الطبعة وإصدارها ووصفها كما يقدّمها الناشر. لا يعني توفر الترجمة أن كل الترجمات لها رخصة واحدة، ولا تُضمّن قاعدة ترجمات كاملة دون مراجعة رخصة كل طبعة.',
            attribution: 'QuranEnc · Attribution and edition terms apply',
            onOpen: () => _open(context, _quranEncUrl),
          ),
          _SourceCard(
            title: 'التلاوات — AlQuran Cloud / Islamic Network',
            status: 'بث مباشر وتنزيل يطلبه المستخدم للاستماع الشخصي/التعليمي',
            statusColor: Colors.green,
            description:
                'يمكن للمستخدم تشغيل التلاوة عبر الإنترنت أو تنزيل ملف السورة إلى مساحة أثَر الخاصة على جهازه للاستماع دون اتصال. لا يرفع التطبيق الملفات ولا يعيد استضافتها ولا يتيح تصديرها من مساحة التطبيق. حقوق التسجيل تبقى للقارئ أو صاحب الحق؛ يجب إظهار اسم القارئ والمصدر، وحذف الملف إذا سُحبت إتاحته. يجب مراجعة الشروط مجدداً قبل أي اشتراك أو إعلان أو نشاط تجاري.',
            attribution: 'AlQuran Cloud / Islamic Network · Reciter retains recording copyright',
            onOpen: () => _open(context, _audioTermsUrl),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'تنويه مهم: توثيق المصدر والرخصة لا يعني امتلاك أثَر للمحتوى. عند تغيّر المصدر أو شروطه أو سحب الإذن، قد يتم إيقاف المورد أو حذفه من التطبيق. النص القرآني المرجعي لا يُحرّف ولا يُعاد تحريره.',
                style: textTheme.bodyMedium?.copyWith(height: 1.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.attribution,
    required this.onOpen,
    this.secondaryUrl,
    this.secondaryLabel,
  });

  final String title;
  final String status;
  final Color statusColor;
  final String description;
  final String attribution;
  final VoidCallback onOpen;
  final String? secondaryUrl;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined, size: 18, color: statusColor),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.65)),
            const SizedBox(height: 8),
            Text(attribution, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('الرخصة / المصدر'),
                  ),
                  if (secondaryUrl != null)
                    TextButton(
                      onPressed: () => launchUrl(
                        Uri.parse(secondaryUrl!),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(secondaryLabel ?? 'مصدر إضافي'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
