import 'dart:async';

import 'package:athaar/core/design_system/athaar_colors.dart';
import 'package:athaar/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) {
    unawaited(context.push<void>('/settings'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.2),
        ),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            onPressed: () => _openSettings(context),
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              l10n.homeGreeting,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeSubtitle,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: colors.onSurfaceVariant, height: 1.6),
            ),
            const SizedBox(height: 24),
            _WelcomeCard(
              title: l10n.heroTitle,
              description: l10n.heroDescription,
              actionLabel: l10n.exploreSettings,
              onPressed: () => _openSettings(context),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.yourPath,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _FeaturePreviewCard(
              icon: Icons.menu_book_rounded,
              title: l10n.quranTitle,
              description: l10n.quranDescription,
              status: l10n.inPreparation,
            ),
            const SizedBox(height: 10),
            _FeaturePreviewCard(
              icon: Icons.auto_awesome_rounded,
              title: l10n.adhkarTitle,
              description: l10n.adhkarDescription,
              status: l10n.inPreparation,
            ),
            const SizedBox(height: 10),
            _FeaturePreviewCard(
              icon: Icons.school_rounded,
              title: l10n.memorizationTitle,
              description: l10n.memorizationDescription,
              status: l10n.inPreparation,
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.phonelink_lock_rounded,
                      color: AthaarColors.petrol,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.privacyNote,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.55,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF006F88), Color(0xFF075567)],
        ),
        boxShadow: [
          BoxShadow(
            color: AthaarColors.petrol.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.spa_rounded, color: Colors.white, size: 23),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonal(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AthaarColors.petrol,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _FeaturePreviewCard extends StatelessWidget {
  const _FeaturePreviewCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String description;
  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AthaarColors.petrol.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AthaarColors.petrol),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
