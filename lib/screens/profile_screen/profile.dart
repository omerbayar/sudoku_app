import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_theme.dart';
import '../../localization/app_localization.dart';
import '../../main.dart' show authService;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: authService,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildProfileHeader(),
                  const SizedBox(height: 28),
                  _buildStatsRow(),
                  const SizedBox(height: 28),
                  _buildSettingsSection(),
                  const SizedBox(height: 16),
                  if (authService.isGuest)
                    _buildLoginPromptButton()
                  else
                    _buildLogoutButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final c = context.appColors;
    final isGuest = authService.isGuest;
    final username = isGuest
        ? translate("guest")
        : (authService.username.isNotEmpty
              ? authService.username
              : translate("player"));
    final email = isGuest
        ? translate("guest_subtitle")
        : (authService.email.isNotEmpty
              ? authService.email
              : translate("puzzle_enthusiast"));
    final initials = isGuest
        ? '?'
        : (username.isNotEmpty ? username[0].toUpperCase() : '?');

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                c.accent,
                HSLColor.fromColor(c.accent).withLightness(0.3).toColor(),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(username, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(email, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildStatsRow() {
    final c = context.appColors;
    return Row(
      children: [
        _buildStatCard(
          translate("games"),
          '0',
          FontAwesomeIcons.gamepad,
          AppColors.gameBlue,
          c,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          translate("wins"),
          '0',
          FontAwesomeIcons.trophy,
          AppColors.gameOrange,
          c,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          translate("streak"),
          '0',
          FontAwesomeIcons.fire,
          AppColors.gamePurple,
          c,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    AppColors c,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    final c = context.appColors;
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
      child: Column(
        children: [
          _buildSettingsTile(
            FontAwesomeIcons.circleInfo,
            translate("about"),
            translate("app_info_credits"),
            onTap: () => context.push('/profile/about'),
          ),
          _divider(c),
          _buildSettingsTile(
            FontAwesomeIcons.gear,
            translate("settings"),
            translate("general_settings"),
            onTap: () => context.push('/profile/settings'),
          ),
          _divider(c),
          _buildSettingsTile(
            FontAwesomeIcons.chartBar,
            translate("statistics"),
            translate("your_game_history"),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    final c = context.appColors;
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
      child: ListTile(
        onTap: () => _showLogoutDialog(c),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            FontAwesomeIcons.rightFromBracket,
            size: 18,
            color: Colors.redAccent,
          ),
        ),
        title: Text(
          translate("logout"),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        trailing: const Icon(
          FontAwesomeIcons.chevronRight,
          size: 14,
          color: Colors.redAccent,
        ),
      ),
    );
  }

  Widget _buildLoginPromptButton() {
    final c = context.appColors;
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
      child: ListTile(
        onTap: () async {
          await authService.logout();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.accentLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            FontAwesomeIcons.rightToBracket,
            size: 18,
            color: c.accent,
          ),
        ),
        title: Text(
          translate("login"),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: c.accent,
          ),
        ),
        trailing: Icon(
          FontAwesomeIcons.chevronRight,
          size: 14,
          color: c.accent,
        ),
      ),
    );
  }

  void _showLogoutDialog(AppColors c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          translate("logout"),
          style: TextStyle(color: c.textPrimary),
        ),
        content: Text(
          translate("logout_confirm"),
          style: TextStyle(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              translate("cancel"),
              style: TextStyle(color: c.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authService.logout();
            },
            child: Text(
              translate("logout"),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    final c = context.appColors;
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

  Widget _divider(AppColors c) {
    return Divider(height: 1, indent: 76, endIndent: 20, color: c.divider);
  }
}
