import 'package:athaar/app/router/app_router.dart';
import 'package:athaar/core/design_system/athaar_theme.dart';
import 'package:athaar/core/design_system/theme_mode_controller.dart';
import 'package:athaar/core/localization/locale_controller.dart';
import 'package:athaar/l10n/generated/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AthaarApp extends ConsumerWidget {
  const AthaarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Athaar',
      debugShowCheckedModeBanner: false,
      theme: AthaarTheme.light,
      darkTheme: AthaarTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
