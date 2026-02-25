import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../localization/app_localization.dart';
import '../main.dart' show appearanceSettings;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(c)),
            SliverToBoxAdapter(child: _buildFeaturedCard(c)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              sliver: _buildGameGrid(c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate("wassup_welcome"),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                translate("brainiac_hub"),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          _ThemeToggle(c: c),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: GestureDetector(
        onTap: () => context.push('/sudokuScreen'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                c.accent,
                HSLColor.fromColor(c.accent).withLightness(0.3).toColor(),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        translate("popular"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      translate("sudoku"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      translate("challenge_your_mind"),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        translate("play_now"),
                        style: TextStyle(
                          color: c.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  FontAwesomeIcons.tableCells,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverGrid _buildGameGrid(AppColors c) {
    final games = [
      _GameItem(
        translate("sudoku"),
        FontAwesomeIcons.tableCells,
        const Color(0xFF42A5F5),
        const Color(0xFF1E88E5),
        true,
        '/sudokuScreen',
      ),
      _GameItem(
        translate("word_hunt"),
        FontAwesomeIcons.font,
        const Color(0xFF7E57C2),
        const Color(0xFF5E35B1),
        false,
        '/word-hunt',
      ),
      _GameItem(
        translate("memory"),
        FontAwesomeIcons.brain,
        const Color(0xFFFF7043),
        const Color(0xFFE64A19),
        false,
        '/memory',
      ),
      _GameItem(
        translate("maze"),
        FontAwesomeIcons.route,
        const Color(0xFF26A69A),
        const Color(0xFF00897B),
        false,
        '/maze',
      ),
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildGameCard(games[index]),
        childCount: games.length,
      ),
    );
  }

  Widget _buildGameCard(_GameItem game) {
    return GestureDetector(
      onTap: () => context.push(game.route),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [game.colorStart, game.colorEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: game.colorEnd.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                game.icon,
                size: 80,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(game.icon, size: 22, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.isActive
                        ? translate("tap_to_play")
                        : translate("coming_soon"),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            if (!game.isActive)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    translate("soon"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final AppColors c;
  const _ThemeToggle({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appearanceSettings,
      builder: (context, _) {
        final isDark =
            appearanceSettings.themeMode == ThemeModeOption.dark ||
            (appearanceSettings.themeMode == ThemeModeOption.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);
        final accent = context.appColors.accent;

        return GestureDetector(
          onTap: () {
            appearanceSettings.setThemeMode(
              isDark ? ThemeModeOption.light : ThemeModeOption.dark,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            width: 64,
            height: 34,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : accent.withValues(alpha: 0.15),
              border: Border.all(
                color: isDark ? Colors.white12 : accent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  alignment: isDark
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF3A3A3A) : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black26
                              : accent.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isDark
                          ? FontAwesomeIcons.moon
                          : FontAwesomeIcons.solidSun,
                      size: 14,
                      color: Color(
                        0xFFFFD54F,
                      ), //isDark ? const Color(0xFFFFD54F) : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GameItem {
  final String title;
  final IconData icon;
  final Color colorStart;
  final Color colorEnd;
  final bool isActive;
  final String route;
  const _GameItem(
    this.title,
    this.icon,
    this.colorStart,
    this.colorEnd,
    this.isActive,
    this.route,
  );
}
