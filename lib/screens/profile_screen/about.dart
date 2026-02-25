import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localization.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        ),
        title: Text(translate("about")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAppIcon(c),
            const SizedBox(height: 20),
            Text(
              translate("puzzle_hub"),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              translate("version"),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _buildInfoCard(c),
            const SizedBox(height: 16),
            _buildLinksCard(c),
            const SizedBox(height: 32),
            Text(
              translate("copyright"),
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon(AppColors c) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
      child: const Icon(
        FontAwesomeIcons.puzzlePiece,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInfoCard(AppColors c) {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          _infoTile(
            FontAwesomeIcons.gamepad,
            translate("games_available"),
            translate("four_puzzles"),
            c,
          ),
          Divider(height: 1, indent: 72, endIndent: 20, color: c.divider),
          _infoTile(
            FontAwesomeIcons.code,
            translate("developer"),
            translate("developer_name"),
            c,
          ),
        ],
      ),
    );
  }

  Widget _buildLinksCard(AppColors c) {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          _linkTile(
            FontAwesomeIcons.star,
            translate("rate_the_app"),
            AppColors.gameOrange,
            c,
          ),
          Divider(height: 1, indent: 72, endIndent: 20, color: c.divider),
          _linkTile(
            FontAwesomeIcons.shareNodes,
            translate("share_with_friends"),
            AppColors.gameBlue,
            c,
          ),
          Divider(height: 1, indent: 72, endIndent: 20, color: c.divider),
          _linkTile(
            FontAwesomeIcons.envelope,
            translate("send_feedback"),
            AppColors.gamePurple,
            c,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value, AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.accentLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: c.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
          Text(value, style: TextStyle(fontSize: 13, color: c.textSecondary)),
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String title, Color color, AppColors c) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
      ),
      trailing: Icon(
        FontAwesomeIcons.chevronRight,
        size: 12,
        color: c.textSecondary,
      ),
    );
  }
}
