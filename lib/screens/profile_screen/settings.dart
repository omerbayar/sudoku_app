import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localization.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        ),
        title: Text(translate("settings")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSection([_buildLanguageTile(currentLocale, c)], c),
            const SizedBox(height: 16),
            _buildSection([
              _buildTile(
                FontAwesomeIcons.palette,
                translate("appearance"),
                translate("theme_display"),
                onTap: () => context.push('/profile/appearance'),
                c: c,
              ),
              Divider(height: 1, indent: 76, endIndent: 20, color: c.divider),
              _buildTile(
                FontAwesomeIcons.bell,
                translate("notifications"),
                translate("reminders_alerts"),
                c: c,
              ),
            ], c),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children, AppColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageTile(String currentLocale, AppColors c) {
    final languageLabel = currentLocale == 'tr' ? 'Türkçe' : 'English';
    return ListTile(
      onTap: () => _showLanguagePicker(currentLocale, c),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.accentLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(FontAwesomeIcons.language, size: 18, color: c.accent),
      ),
      title: Text(
        translate("language"),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
      subtitle: Text(
        languageLabel,
        style: TextStyle(fontSize: 13, color: c.textSecondary),
      ),
      trailing: Icon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: c.textSecondary,
      ),
    );
  }

  void _showLanguagePicker(String currentLocale, AppColors c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate("select_language"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                'English',
                '🇬🇧',
                'en',
                currentLocale == 'en',
                c,
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                'Türkçe',
                '🇹🇷',
                'tr',
                currentLocale == 'tr',
                c,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String label,
    String flag,
    String langCode,
    bool isSelected,
    AppColors c,
  ) {
    return GestureDetector(
      onTap: () {
        MyApp.setLocale(context, Locale(langCode));
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? c.accent.withValues(alpha: 0.1) : c.cardElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? c.accent : c.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? c.accent : c.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(FontAwesomeIcons.circleCheck, size: 20, color: c.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    required AppColors c,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.accentLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: c.accent),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: c.textSecondary),
      ),
      trailing: Icon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: c.textSecondary,
      ),
    );
  }
}
