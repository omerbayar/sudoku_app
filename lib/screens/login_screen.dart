import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../localization/app_localization.dart';
import '../main.dart' show authService, MyApp;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _regUsernameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _loginObscure = true;
  bool _regObscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regUsernameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _loading = true);
    final success = await authService.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text,
    );
    setState(() => _loading = false);
    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      _showError(translate('login_error'));
    }
  }

  Future<void> _handleRegister() async {
    setState(() => _loading = true);
    final success = await authService.register(
      _regUsernameController.text.trim(),
      _regEmailController.text.trim(),
      _regPasswordController.text,
    );
    setState(() => _loading = false);
    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      _showError(translate('register_error'));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              _buildLogo(c),
              const SizedBox(height: 36),
              _buildTabBar(c),
              const SizedBox(height: 24),
              SizedBox(
                height: 240,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildLoginForm(c), _buildRegisterForm(c)],
                ),
              ),
              _buildGuestButton(c),
              const SizedBox(height: 24),
              _buildLanguageSelector(c),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(AppColors c) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
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
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          translate('brainiac_hub'),
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          translate('login_subtitle'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildTabBar(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: c.textSecondary,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: translate('login')),
          Tab(text: translate('register')),
        ],
      ),
    );
  }

  Widget _buildLoginForm(AppColors c) {
    return Column(
      children: [
        _buildTextField(
          controller: _loginEmailController,
          hint: translate('email'),
          icon: FontAwesomeIcons.envelope,
          c: c,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _loginPasswordController,
          hint: translate('password'),
          icon: FontAwesomeIcons.lock,
          c: c,
          obscure: _loginObscure,
          toggleObscure: () => setState(() => _loginObscure = !_loginObscure),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: Text(
              translate('forgot_password'),
              style: TextStyle(
                color: c.accent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildActionButton(translate('login'), _handleLogin, c),
      ],
    );
  }

  Widget _buildRegisterForm(AppColors c) {
    return Column(
      children: [
        _buildTextField(
          controller: _regUsernameController,
          hint: translate('username'),
          icon: FontAwesomeIcons.user,
          c: c,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _regEmailController,
          hint: translate('email'),
          icon: FontAwesomeIcons.envelope,
          c: c,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _regPasswordController,
          hint: translate('password'),
          icon: FontAwesomeIcons.lock,
          c: c,
          obscure: _regObscure,
          toggleObscure: () => setState(() => _regObscure = !_regObscure),
        ),
        const SizedBox(height: 24),
        _buildActionButton(translate('register'), _handleRegister, c),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required AppColors c,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: TextStyle(color: c.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSecondary),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 18, color: c.textSecondary),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: toggleObscure != null
            ? IconButton(
                onPressed: toggleObscure,
                icon: Icon(
                  obscure ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                  size: 16,
                  color: c.textSecondary,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, AppColors c) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }

  Widget _buildGuestButton(AppColors c) {
    return TextButton(
      onPressed: _loading
          ? null
          : () async {
              await authService.continueAsGuest();
              if (mounted) context.go('/');
            },
      child: Text(
        translate('continue_as_guest'),
        style: TextStyle(
          color: c.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(AppColors c) {
    final currentLocale = Localizations.localeOf(context).languageCode;
    const languages = [
      ('en', '🇬🇧', 'English'),
      ('tr', '🇹🇷', 'Türkçe'),
      ('fr', '🇫🇷', 'Français'),
      ('de', '🇩🇪', 'Deutsch'),
      ('ro', '🇷🇴', 'Română'),
    ];

    final current = languages.firstWhere(
      (l) => l.$1 == currentLocale,
      orElse: () => languages.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: DropdownButton<String>(
        value: current.$1,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(
          FontAwesomeIcons.chevronDown,
          size: 14,
          color: c.textSecondary,
        ),
        dropdownColor: c.card,
        borderRadius: BorderRadius.circular(14),
        style: TextStyle(fontSize: 15, color: c.textPrimary),
        selectedItemBuilder: (context) => languages.map((lang) {
          return Row(
            children: [
              Text(lang.$2, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                lang.$3,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
                ),
              ),
            ],
          );
        }).toList(),
        items: languages.map((lang) {
          final isSelected = lang.$1 == currentLocale;
          return DropdownMenuItem(
            value: lang.$1,
            child: Row(
              children: [
                Text(lang.$2, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lang.$3,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? c.accent : c.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(FontAwesomeIcons.check, size: 14, color: c.accent),
              ],
            ),
          );
        }).toList(),
        onChanged: (code) {
          if (code != null) MyApp.setLocale(context, Locale(code));
        },
      ),
    );
  }
}
