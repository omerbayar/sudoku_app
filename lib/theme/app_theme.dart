import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Appearance Settings (state + persistence) ───

enum ThemeModeOption { light, dark, system }

class AccentColor {
  final String name;
  final Color color;
  const AccentColor(this.name, this.color);
}

const List<AccentColor> availableAccentColors = [
  AccentColor('Green', Color(0xFF4CAF50)),
  AccentColor('Blue', Color(0xFF2196F3)),
  AccentColor('Purple', Color(0xFF7E57C2)),
  AccentColor('Orange', Color(0xFFFF7043)),
  AccentColor('Teal', Color(0xFF26A69A)),
  AccentColor('Pink', Color(0xFFEC407A)),
  AccentColor('Indigo', Color(0xFF5C6BC0)),
  AccentColor('Amber', Color(0xFFFFB300)),
];

class AppearanceSettings extends ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.system;
  int _accentColorIndex = 0;
  double _fontScale = 1.0;
  bool _loaded = false;

  ThemeModeOption get themeMode => _themeMode;
  int get accentColorIndex => _accentColorIndex;
  double get fontScale => _fontScale;
  bool get loaded => _loaded;
  AccentColor get accentColor => availableAccentColors[_accentColorIndex];

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeModeOption.values[prefs.getInt('themeMode') ?? 2];
    _accentColorIndex = (prefs.getInt('accentColor') ?? 0).clamp(
      0,
      availableAccentColors.length - 1,
    );
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setAccentColor(int index) async {
    _accentColorIndex = index.clamp(0, availableAccentColors.length - 1);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColor', _accentColorIndex);
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(0.85, 1.2);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', _fontScale);
  }
}

// ─── Context Extension (semantic colors) ───

class AppColors {
  final BuildContext _context;
  const AppColors._(this._context);

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;
  ColorScheme get _scheme => Theme.of(_context).colorScheme;

  // Surfaces
  Color get surface => Theme.of(_context).scaffoldBackgroundColor;
  Color get card => _isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get cardElevated => _isDark ? const Color(0xFF2A2A2A) : Colors.white;

  // Text
  Color get textPrimary =>
      _isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1B2B1B);
  Color get textSecondary =>
      _isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7B6B);

  // Accent (from seed)
  Color get accent => _scheme.primary;
  Color get accentLight => _isDark
      ? _scheme.primary.withValues(alpha: 0.2)
      : _scheme.primary.withValues(alpha: 0.1);
  Color get accentOnPrimary => _scheme.onPrimary;

  // Semantic
  Color get divider => _isDark ? Colors.white10 : const Color(0xFFEEEEEE);
  Color get shadow => Colors.black.withValues(alpha: _isDark ? 0.2 : 0.04);
  Color get shadowMedium =>
      Colors.black.withValues(alpha: _isDark ? 0.3 : 0.06);
  Color get border => _isDark ? Colors.white12 : const Color(0xFFE0E0E0);

  // Fixed game colors (brand — don't change with theme)
  static const Color gameBlue = Color(0xFF42A5F5);
  static const Color gamePurple = Color(0xFF7E57C2);
  static const Color gameOrange = Color(0xFFFF7043);
  static const Color gameTeal = Color(0xFF26A69A);
  static const Color gamePink = Color(0xFFEC407A);
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors => AppColors._(this);
}

// ─── Theme Builder ───

class AppTheme {
  static ThemeData fromSettings(
    AppearanceSettings settings, {
    required bool dark,
  }) {
    final seed = settings.accentColor.color;
    final scale = settings.fontScale;
    return dark
        ? _build(seed: seed, fontScale: scale, brightness: Brightness.dark)
        : _build(seed: seed, fontScale: scale, brightness: Brightness.light);
  }

  static ThemeData _build({
    required Color seed,
    required double fontScale,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAF8);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPri = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF1B2B1B);
    final textSec = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7B6B);
    final inputFill = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final inputBorder = isDark ? Colors.white12 : Colors.grey.shade200;
    final dividerColor = isDark ? Colors.white10 : Colors.grey.shade200;

    double s(double size) => size * fontScale;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme:
          GoogleFonts.interTextTheme(
            ThemeData(brightness: brightness).textTheme,
          ).copyWith(
            headlineLarge: GoogleFonts.inter(
              fontSize: s(28),
              fontWeight: FontWeight.w700,
              color: textPri,
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: s(22),
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
            titleLarge: GoogleFonts.inter(
              fontSize: s(18),
              fontWeight: FontWeight.w600,
              color: textPri,
            ),
            titleMedium: GoogleFonts.inter(
              fontSize: s(16),
              fontWeight: FontWeight.w500,
              color: textPri,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: s(16),
              fontWeight: FontWeight.w400,
              color: textSec,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: s(14),
              fontWeight: FontWeight.w400,
              color: textSec,
            ),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: surface,
        foregroundColor: textPri,
        titleTextStyle: GoogleFonts.inter(
          fontSize: s(20),
          fontWeight: FontWeight.w600,
          color: textPri,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: card,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: card,
        selectedItemColor: seed,
        unselectedItemColor: textSec,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: seed,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(
            fontSize: s(15),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerColor: dividerColor,
    );
  }
}
