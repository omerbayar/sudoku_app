import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../localization/app_localization.dart';

const _fingerColors = [
  Color(0xFFEF5350), // kırmızı
  Color(0xFF42A5F5), // mavi
  Color(0xFF66BB6A), // yeşil
  Color(0xFFFFCA28), // sarı
  Color(0xFFAB47BC), // mor
  Color(0xFFFF7043), // turuncu
  Color(0xFF26C6DA), // cyan
  Color(0xFFEC407A), // pembe
  Color(0xFF8D6E63), // kahve
  Color(0xFF78909C), // gri-mavi
];

class FingerPickScreen extends StatefulWidget {
  const FingerPickScreen({super.key});

  @override
  State<FingerPickScreen> createState() => _FingerPickScreenState();
}

enum _GamePhase { waiting, countdown, chosen, done }

class _FingerPickScreenState extends State<FingerPickScreen>
    with SingleTickerProviderStateMixin {
  // pointer id -> (position, colorIndex)
  final Map<int, _FingerData> _fingers = {};
  int _nextColorIndex = 0;
  _GamePhase _phase = _GamePhase.waiting;
  Timer? _countdownTimer;
  int _secondsLeft = 5;
  int? _chosenPointerId;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _secondsLeft = 5;
    _phase = _GamePhase.countdown;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          timer.cancel();
          _pickWinner();
        }
      });
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    setState(() {
      _phase = _GamePhase.waiting;
      _secondsLeft = 5;
    });
  }

  void _pickWinner() {
    if (_fingers.isEmpty) {
      _resetGame();
      return;
    }
    final ids = _fingers.keys.toList();
    final winnerId = ids[Random().nextInt(ids.length)];
    setState(() {
      _chosenPointerId = winnerId;
      _phase = _GamePhase.chosen;
    });
    // 3 saniye sonra done fazına geç
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _phase == _GamePhase.chosen) {
        setState(() => _phase = _GamePhase.done);
      }
    });
  }

  void _resetGame() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    setState(() {
      _fingers.clear();
      _nextColorIndex = 0;
      _phase = _GamePhase.waiting;
      _secondsLeft = 5;
      _chosenPointerId = null;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_phase == _GamePhase.chosen || _phase == _GamePhase.done) return;
    setState(() {
      _fingers[event.pointer] = _FingerData(
        position: event.localPosition,
        colorIndex: _nextColorIndex % _fingerColors.length,
      );
      _nextColorIndex++;
    });
    // 2+ parmak varsa ve countdown başlamamışsa başlat
    if (_fingers.length >= 2 && _phase == _GamePhase.waiting) {
      _startCountdown();
    }
    // Yeni parmak eklendiyse countdown'ı sıfırla
    if (_phase == _GamePhase.countdown) {
      _countdownTimer?.cancel();
      _startCountdown();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_phase == _GamePhase.chosen || _phase == _GamePhase.done) return;
    if (_fingers.containsKey(event.pointer)) {
      setState(() {
        _fingers[event.pointer] = _FingerData(
          position: event.localPosition,
          colorIndex: _fingers[event.pointer]!.colorIndex,
        );
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_phase == _GamePhase.chosen || _phase == _GamePhase.done) return;
    setState(() {
      _fingers.remove(event.pointer);
    });
    // Parmak sayısı 2'nin altına düştüyse countdown'ı iptal et
    if (_fingers.length < 2 && _phase == _GamePhase.countdown) {
      _cancelCountdown();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_phase == _GamePhase.chosen || _phase == _GamePhase.done) return;
    setState(() {
      _fingers.remove(event.pointer);
    });
    if (_fingers.length < 2 && _phase == _GamePhase.countdown) {
      _cancelCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: GestureDetector(
          onTap: _phase == _GamePhase.done ? _resetGame : null,
          child: Stack(
            children: [
              // Parmak daireleri
              ..._buildFingerCircles(),
              // Üst bilgi
              _buildOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFingerCircles() {
    final List<Widget> circles = [];
    for (final entry in _fingers.entries) {
      final id = entry.key;
      final data = entry.value;
      final color = _fingerColors[data.colorIndex];
      final isChosen = _phase == _GamePhase.chosen && id == _chosenPointerId;
      final isEliminated =
          _phase == _GamePhase.chosen && id != _chosenPointerId;

      circles.add(
        AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          left: data.position.dx - (isChosen ? 55 : 45),
          top: data.position.dy - (isChosen ? 55 : 45),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isEliminated ? 0.2 : 1.0,
            child: _buildCircle(color, isChosen),
          ),
        ),
      );
    }
    return circles;
  }

  Widget _buildCircle(Color color, bool isChosen) {
    final size = isChosen ? 110.0 : 90.0;
    if (isChosen) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + _pulseController.value * 0.15;
          return Transform.scale(
            scale: scale,
            child: _circleWidget(color, size, true),
          );
        },
      );
    }
    return _circleWidget(color, size, false);
  }

  Widget _circleWidget(Color color, double size, bool isChosen) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.7),
        border: Border.all(
          color: isChosen ? Colors.white : color,
          width: isChosen ? 4 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isChosen ? 0.8 : 0.4),
            blurRadius: isChosen ? 30 : 15,
            spreadRadius: isChosen ? 5 : 0,
          ),
        ],
      ),
      child: isChosen
          ? const Center(
              child: Icon(Icons.star_rounded, color: Colors.white, size: 36),
            )
          : null,
    );
  }

  Widget _buildOverlay() {
    return SafeArea(
      child: Column(
        children: [
          // Geri butonu ve başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
                Text(
                  translate('guess_mode'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Durum mesajı
          _buildStatusMessage(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    String text;
    Color color = Colors.white60;
    double fontSize = 18;

    switch (_phase) {
      case _GamePhase.waiting:
        if (_fingers.isEmpty) {
          text = translate('finger_place_fingers');
        } else {
          text = translate('finger_min_fingers');
        }
      case _GamePhase.countdown:
        text = translate(
          'finger_countdown',
        ).replaceAll('{seconds}', '$_secondsLeft');
        color = Colors.white;
        fontSize = 48;
      case _GamePhase.chosen:
        text = translate('finger_chosen');
        color = Colors.white;
        fontSize = 28;
      case _GamePhase.done:
        text = translate('finger_tap_to_restart');
        color = Colors.white60;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        text,
        key: ValueKey('$_phase-$_secondsLeft'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FingerData {
  final Offset position;
  final int colorIndex;
  const _FingerData({required this.position, required this.colorIndex});
}
