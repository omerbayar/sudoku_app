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
    final currentLocale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceLight,
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
            _buildSection([_buildLanguageTile(currentLocale)]),
            const SizedBox(height: 16),
            _buildSection([
              _buildTile(
                FontAwesomeIcons.palette,
                translate("appearance"),
                translate("theme_display"),
              ),
              _divider(),
              _buildTile(
                FontAwesomeIcons.bell,
                translate("notifications"),
                translate("reminders_alerts"),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageTile(String currentLocale) {
    final languageLabel = currentLocale == 'tr' ? 'Türkçe' : 'English';

    return ListTile(
      onTap: () => _showLanguagePicker(currentLocale),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.lightGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          FontAwesomeIcons.language,
          size: 18,
          color: AppTheme.darkGreen,
        ),
      ),
      title: Text(
        translate("language"),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        languageLabel,
        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: AppTheme.textSecondary,
      ),
    );
  }

  void _showLanguagePicker(String currentLocale) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate("select_language"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  'English',
                  '🇬🇧',
                  'en',
                  currentLocale == 'en',
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  'Türkçe',
                  '🇹🇷',
                  'tr',
                  currentLocale == 'tr',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String label,
    String flag,
    String langCode,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        MyApp.setLocale(context, Locale(langCode));
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
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
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                FontAwesomeIcons.circleCheck,
                size: 20,
                color: AppTheme.primaryGreen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.lightGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: AppTheme.darkGreen),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(
        FontAwesomeIcons.chevronRight,
        size: 14,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 76,
      endIndent: 20,
      color: Colors.grey.shade100,
    );
  }
}
