import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../main.dart' show appearanceSettings;

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final settings = appearanceSettings;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        ),
        title: const Text('Appearance'),
      ),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          final c = context.appColors;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Theme'),
                const SizedBox(height: 12),
                _buildThemeSelector(settings, c),
                const SizedBox(height: 28),
                _sectionTitle('Accent Color'),
                const SizedBox(height: 12),
                _buildAccentColorPicker(settings, c),
                const SizedBox(height: 28),
                _sectionTitle('Font Size'),
                const SizedBox(height: 12),
                _buildFontScaleSlider(settings, c),
                const SizedBox(height: 28),
                _buildPreviewCard(settings, c),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildThemeSelector(AppearanceSettings settings, AppColors c) {
    final options = [
      (ThemeModeOption.light, FontAwesomeIcons.sun, 'Light'),
      (ThemeModeOption.dark, FontAwesomeIcons.moon, 'Dark'),
      (ThemeModeOption.system, FontAwesomeIcons.circleHalfStroke, 'System'),
    ];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: options.map((opt) {
          final sel = settings.themeMode == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => settings.setThemeMode(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? c.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      opt.$2,
                      size: 20,
                      color: sel ? Colors.white : c.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt.$3,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                        color: sel ? Colors.white : c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAccentColorPicker(AppearanceSettings settings, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: List.generate(availableAccentColors.length, (index) {
          final ac = availableAccentColors[index];
          final sel = settings.accentColorIndex == index;
          return GestureDetector(
            onTap: () => settings.setAccentColor(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ac.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel ? ac.color : Colors.transparent,
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: ac.color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: sel
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFontScaleSlider(AppearanceSettings settings, AppColors c) {
    final accent = settings.accentColor.color;
    final labels = {0.85: 'Small', 1.0: 'Default', 1.1: 'Large', 1.2: 'XL'};
    final currentLabel = labels.entries
        .reduce(
          (a, b) =>
              (settings.fontScale - a.key).abs() <
                  (settings.fontScale - b.key).abs()
              ? a
              : b,
        )
        .value;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
          Slider(
            value: settings.fontScale,
            min: 0.85,
            max: 1.2,
            divisions: 7,
            activeColor: accent,
            inactiveColor: accent.withValues(alpha: 0.15),
            onChanged: (v) => settings.setFontScale(v),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(AppearanceSettings settings, AppColors c) {
    final accent = settings.accentColor.color;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent,
            HSLColor.fromColor(accent).withLightness(0.35).toColor(),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(FontAwesomeIcons.eye, size: 16, color: Colors.white70),
              SizedBox(width: 8),
              Text(
                'Preview',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This is how your app looks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18 * settings.fontScale,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Colors, fonts, and theme will update across the entire app in real time.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14 * settings.fontScale,
            ),
          ),
        ],
      ),
    );
  }
}
