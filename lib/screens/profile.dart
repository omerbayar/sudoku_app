import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildProfileHeader(),
              const SizedBox(height: 28),
              _buildStatsRow(),
              const SizedBox(height: 28),
              _buildSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            FontAwesomeIcons.user,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text('Player', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('Puzzle Enthusiast', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          'Games',
          '0',
          FontAwesomeIcons.gamepad,
          AppTheme.accentBlue,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Wins',
          '0',
          FontAwesomeIcons.trophy,
          AppTheme.warmOrange,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Streak',
          '0',
          FontAwesomeIcons.fire,
          AppTheme.softPurple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
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
      child: Column(
        children: [
          _buildSettingsTile(
            FontAwesomeIcons.palette,
            'Appearance',
            'Theme & display',
          ),
          _divider(),
          _buildSettingsTile(
            FontAwesomeIcons.bell,
            'Notifications',
            'Reminders & alerts',
          ),
          _divider(),
          _buildSettingsTile(
            FontAwesomeIcons.chartBar,
            'Statistics',
            'Your game history',
          ),
          _divider(),
          _buildSettingsTile(
            FontAwesomeIcons.circleInfo,
            'About',
            'App info & credits',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
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
