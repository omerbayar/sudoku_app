import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../localization/app_localization.dart';

class CoinFlipScreen extends StatefulWidget {
  const CoinFlipScreen({super.key});

  @override
  State<CoinFlipScreen> createState() => _CoinFlipScreenState();
}

class _CoinFlipScreenState extends State<CoinFlipScreen>
    with SingleTickerProviderStateMixin {
  // null = henüz atılmadı, true = yazı, false = tura
  bool? _result;
  bool _isFlipping = false;
  int _headsCount = 0;
  int _tailsCount = 0;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isFlipping = false);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCoin() {
    if (_isFlipping) return;
    setState(() {
      _isFlipping = true;
      _result = _random.nextBool();
      if (_result!) {
        _headsCount++;
      } else {
        _tailsCount++;
      }
    });
    _controller.forward();
  }

  void _resetStats() {
    setState(() {
      _result = null;
      _headsCount = 0;
      _tailsCount = 0;
    });
  }

  int get _totalFlips => _headsCount + _tailsCount;

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
        title: Text(translate('coin_flip')),
        actions: [
          if (_totalFlips > 0)
            IconButton(
              onPressed: _resetStats,
              icon: const Icon(FontAwesomeIcons.arrowRotateLeft, size: 18),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            _buildCoin(c),
            const SizedBox(height: 32),
            _buildResultText(c),
            const Spacer(flex: 1),
            _buildFlipButton(c),
            const SizedBox(height: 24),
            if (_totalFlips > 0) _buildStats(c),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCoin(AppColors c) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * pi * 4; // 4 tam dönüş
        final showBack = ((_flipAnimation.value * 4) % 1) > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(angle),
          child: _buildCoinFace(c, showBack && _isFlipping),
        );
      },
    );
  }

  Widget _buildCoinFace(AppColors c, bool showAlternate) {
    final isHeads = _result ?? true;
    final displayHeads = showAlternate ? !isHeads : isHeads;

    final Color coinColor = displayHeads
        ? const Color(0xFFFFD700)
        : const Color(0xFFC0C0C0);
    final Color coinDarkColor = displayHeads
        ? const Color(0xFFDAA520)
        : const Color(0xFF808080);

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [coinColor, coinDarkColor],
        ),
        boxShadow: [
          BoxShadow(
            color: coinDarkColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: coinDarkColor.withValues(alpha: 0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: _result == null
            ? Icon(
                FontAwesomeIcons.question,
                size: 48,
                color: Colors.white.withValues(alpha: 0.8),
              )
            : Text(
                displayHeads ? translate('heads') : translate('tails'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildResultText(AppColors c) {
    if (_result == null) {
      return Text(
        translate('coin_flip_subtitle'),
        style: TextStyle(fontSize: 18, color: c.textSecondary),
      );
    }
    return AnimatedOpacity(
      opacity: _isFlipping ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          Text(
            _result! ? translate('heads') : translate('tails'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: _result!
                  ? const Color(0xFFDAA520)
                  : const Color(0xFF808080),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipButton(AppColors c) {
    return GestureDetector(
      onTap: _isFlipping ? null : _flipCoin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isFlipping
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : [const Color(0xFFFFD700), const Color(0xFFDAA520)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFFDAA520,
              ).withValues(alpha: _isFlipping ? 0.0 : 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          translate('tap_to_flip'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStats(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              translate('heads_count'),
              _headsCount,
              const Color(0xFFDAA520),
              c,
            ),
            Container(width: 1, height: 36, color: c.divider),
            _buildStatItem(translate('total_flips'), _totalFlips, c.accent, c),
            Container(width: 1, height: 36, color: c.divider),
            _buildStatItem(
              translate('tails_count'),
              _tailsCount,
              const Color(0xFF808080),
              c,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, AppColors c) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: c.textSecondary)),
      ],
    );
  }
}
