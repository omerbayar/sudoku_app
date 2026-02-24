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
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceLight,
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
            _buildAppIcon(),
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
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildLinksCard(context),
            const SizedBox(height: 32),
            const SizedBox(height: 6),
            Text(
              translate("copyright"),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
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

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          _infoTile(
            FontAwesomeIcons.gamepad,
            translate("games_available"),
            translate("four_puzzles"),
          ),
          _divider(),
          _infoTile(
            FontAwesomeIcons.code,
            translate("developer"),
            translate("developer_name"),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksCard(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          _linkTile(
            FontAwesomeIcons.star,
            translate("rate_the_app"),
            AppTheme.warmOrange,
          ),
          _divider(),
          _linkTile(
            FontAwesomeIcons.shareNodes,
            translate("share_with_friends"),
            AppTheme.accentBlue,
          ),
          _divider(),
          _linkTile(
            FontAwesomeIcons.envelope,
            translate("send_feedback"),
            AppTheme.softPurple,
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppTheme.darkGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String title, Color color) {
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(
        FontAwesomeIcons.chevronRight,
        size: 12,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 20,
      color: Colors.grey.shade100,
    );
  }
}
