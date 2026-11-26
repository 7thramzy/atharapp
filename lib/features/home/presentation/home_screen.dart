import 'package:athaar/core/design_system/athaar_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.spa_rounded, color: AthaarColors.mutedGold, size: 27),
            const SizedBox(width: 8),
            Text('أثَر', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () => context.push<void>('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Text('أهلاً بك في أثَر', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('خطوات صغيرة تصنع أثراً طيباً', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant)),
            const SizedBox(height: 20),
            _JourneyCard(onTap: () => context.push<void>('/quran')),
            const SizedBox(height: 22),
            Row(children: [
              const Expanded(child: Divider(color: AthaarColors.mutedGold)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text('مسارك', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              const Expanded(child: Divider(color: AthaarColors.mutedGold)),
            ]),
            const SizedBox(height: 12),
            _PathTile(icon: Icons.menu_book_rounded, title: 'القرآن الكريم',
              subtitle: 'قراءة وتدبّر', onTap: () => context.push<void>('/quran')),
            _PathTile(icon: Icons.grain_rounded, title: 'الأذكار',
              subtitle: 'طمأنينة في كل حين', onTap: () => context.push<void>('/adhkar')),
            _PathTile(icon: Icons.bookmark_added_rounded, title: 'الحفظ والمراجعة',
              subtitle: 'ثبّت وتذكّر دائماً', onTap: () => context.push<void>('/memorization')),
            _PathTile(icon: Icons.insights_rounded, title: 'أثري الشخصي',
              subtitle: 'تابع أثر خطواتك', onTap: () => context.push<void>('/impact')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: const Color(0xFFE1EEDC), borderRadius: BorderRadius.circular(18)),
              child: const Row(children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFF28745B), size: 28),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('خصوصيتك أولويتنا', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF174E42))),
                  SizedBox(height: 3),
                  Text('تُحفظ بيانات القراءة محلياً، وتتصل خدمات الدراسة بمصادرها عند طلبها', style: TextStyle(fontSize: 12, color: Color(0xFF37665A))),
                ])),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _AthaarNavigation(selectedIndex: 0),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft,
        colors: [Color(0xFF087C83), Color(0xFF004D5C)]),
      boxShadow: [BoxShadow(color: AthaarColors.petrol.withValues(alpha: .18), blurRadius: 18, offset: const Offset(0, 8))],
    ),
    child: Row(children: [
      Container(width: 76, height: 88,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.eco_rounded, color: Color(0xFFD8C18D), size: 48)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('رحلتك نحو أثر دائم', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(backgroundColor: AthaarColors.mutedGold, foregroundColor: Colors.white),
          child: const Text('اكتشف رحلتك'),
        ),
      ])),
    ]),
  );
}

class _PathTile extends StatelessWidget {
  const _PathTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 9),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(width: 46, height: 46,
        decoration: BoxDecoration(color: AthaarColors.petrol.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: AthaarColors.petrol)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: onTap,
    ),
  );
}

class _AthaarNavigation extends StatelessWidget {
  const _AthaarNavigation({required this.selectedIndex});
  final int selectedIndex;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: (index) {
      const paths = ['/', '/impact', '/memorization', '/settings'];
      if (index != selectedIndex) context.go(paths[index]);
    },
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
      NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'إنجازاتي'),
      NavigationDestination(icon: Icon(Icons.star_border_rounded), selectedIcon: Icon(Icons.star_rounded), label: 'المفضلة'),
      NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'حسابي'),
    ],
  );
}
