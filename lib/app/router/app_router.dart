import 'package:athaar/features/home/presentation/home_screen.dart';
import 'package:athaar/features/mvp/presentation/mvp_screens.dart';
import 'package:athaar/features/quran/presentation/hafs_mushaf_screen.dart';
import 'package:athaar/features/settings/presentation/settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/quran',
        name: 'quran',
        builder: (context, state) => const QuranScreen(),
        routes: [
          GoRoute(
            path: 'mushaf',
            name: 'quran-mushaf-hafs',
            builder: (context, state) => const HafsMushafScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/adhkar',
        name: 'adhkar',
        builder: (context, state) => const AdhkarScreen(),
      ),
      GoRoute(
        path: '/memorization',
        name: 'memorization',
        builder: (context, state) => const MemorizationScreen(),
      ),
      GoRoute(
        path: '/impact',
        name: 'impact',
        builder: (context, state) => const PersonalImpactScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
