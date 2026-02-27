import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'screens/dashboard.dart';
import 'screens/sudoku.dart';
import 'screens/profile_screen/profile.dart';
import 'screens/profile_screen/about.dart';
import 'screens/profile_screen/appearance.dart';
import 'screens/profile_screen/settings.dart';
import 'screens/search_screen.dart';
import 'screens/coming_soon_screen.dart';
import 'screens/login_screen.dart';
import 'main.dart' show authService;
import 'localization/app_localization.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  refreshListenable: authService,
  redirect: (context, state) {
    final loggedIn = authService.isLoggedIn;
    final isLoginRoute = state.uri.path == '/login';
    if (!loggedIn && !isLoginRoute) return '/login';
    if (loggedIn && isLoginRoute) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/profile/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile/appearance',
          builder: (context, state) => const AppearanceScreen(),
        ),
        GoRoute(
          path: '/sudokuScreen',
          builder: (context, state) => const SudokuScreen(),
        ),
        GoRoute(
          path: '/word-hunt',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Word Hunt',
            description:
                'Find hidden words in a grid of letters.\nTest your vocabulary and pattern recognition.',
            icon: FontAwesomeIcons.font,
            colorStart: Color(0xFF7E57C2),
            colorEnd: Color(0xFF5E35B1),
          ),
        ),
        GoRoute(
          path: '/memory',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Memory',
            description:
                'Flip cards and match pairs.\nTrain your memory with increasing difficulty.',
            icon: FontAwesomeIcons.brain,
            colorStart: Color(0xFFFF7043),
            colorEnd: Color(0xFFE64A19),
          ),
        ),
        GoRoute(
          path: '/maze',
          builder: (context, state) => const ComingSoonScreen(
            title: 'Maze',
            description:
                'Navigate through complex mazes.\nFind the shortest path to the exit.',
            icon: FontAwesomeIcons.route,
            colorStart: Color(0xFF26A69A),
            colorEnd: Color(0xFF00897B),
          ),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.house),
              activeIcon: const Icon(FontAwesomeIcons.house),
              label: translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.magnifyingGlass),
              activeIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
              label: translate('search'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(FontAwesomeIcons.user),
              activeIcon: const Icon(FontAwesomeIcons.solidUser),
              label: translate('profile'),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == '/') return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}
