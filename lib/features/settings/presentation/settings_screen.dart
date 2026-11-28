import 'package:athaar/core/design_system/athaar_colors.dart';
import 'package:athaar/core/design_system/theme_mode_controller.dart';
import 'package:athaar/core/localization/locale_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'الإعدادات',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          _SectionCard(
            title: 'اللغة',
            icon: Icons.language_rounded,
            child: Column(
              children: [
                RadioGroup<String>(
                  groupValue: locale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(value));
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        value: 'ar',
                        title: Text('العربية'),
                      ),
                      Divider(height: 1),
                      RadioListTile<String>(
                        value: 'en',
                        title: Text('English'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'المظهر',
            icon: Icons.palette_outlined,
            child: Column(
              children: [
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
                      label: Text('النظام'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text('فاتح'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text('داكن'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(selection.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'تنزيل التطبيق',
            icon: Icons.download_rounded,
            child: const Text(
              'روابط النسخ التجريبية أزيلت من واجهة المستخدم. ستظهر روابط Android وWindows وiPhone هنا بعد اعتماد ملفات إنتاج موقعة وثابتة.',
            ),
          ),
          const SizedBox(height: 14),
          _SettingsRow(
            icon: Icons.text_fields_rounded,
            title: 'الخط وحجم النص',
            onTap: () => _showInfo(
              context,
              'إعدادات الخط',
              'سيتم توفير التحكم بحجم الخط في تحديث لاحق.',
            ),
          ),
          _SettingsRow(
            icon: Icons.notifications_none_rounded,
            title: 'الإشعارات',
            onTap: () => _showInfo(
              context,
              'الإشعارات',
              'إعدادات الإشعارات قيد الإعداد.',
            ),
          ),
          _SettingsRow(
            icon: Icons.verified_user_outlined,
            title: 'الخصوصية والأمان',
            onTap: () => _showInfo(
              context,
              'معلومات البيانات',
              'الملاحظات والإشارات والتقدم الشخصي تُحفظ محلياً. عند طلب التفسير أو الترجمة أو التلاوة، يتصل التطبيق بمزود الخدمة المعني لجلب المحتوى. سياسة الخصوصية التفصيلية مؤجلة، وستُضاف قبل النشر العام.',
            ),
          ),
          _SettingsRow(
            icon: Icons.info_outline_rounded,
            title: 'حول التطبيق والمصادر',
            onTap: () => context.push('/about'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF203B36) : const Color(0xFFE1EEDC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF28745B),
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'أثَر — مصادر موثقة\nالنص القرآني المرجعي محفوظ دون تعديل',
                    style: TextStyle(
                      color: colors.onSurface,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        onDestinationSelected: (i) {
          const paths = ['/', '/impact', '/memorization', '/settings'];
          if (i != 3) context.go(paths[i]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            label: 'إنجازاتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border_rounded),
            label: 'المفضلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  static Future<void> _showInfo(
    BuildContext context,
    String title,
    String message,
  ) => showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إغلاق'),
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AthaarColors.petrol),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: AthaarColors.petrol),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: onTap,
    ),
  );
}
