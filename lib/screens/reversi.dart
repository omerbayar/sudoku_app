import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../localization/app_localization.dart';

enum ReversiMode { none, friend, bot }

enum BotDifficulty { easy, medium, hard, expert }

class ReversiScreen extends StatefulWidget {
  const ReversiScreen({super.key});

  @override
  ReversiScreenState createState() => ReversiScreenState();
}

class ReversiScreenState extends State<ReversiScreen> {
  static const int boardSize = 8;

  ReversiMode _mode = ReversiMode.none;
  BotDifficulty _botDifficulty = BotDifficulty.easy;
  bool _gameStarted = false;

  // 0 = empty, 1 = black, 2 = white
  List<List<int>> _board = [];
  int _currentPlayer = 1;
  bool _gameOver = false;
  int _blackCount = 2;
  int _whiteCount = 2;
  List<List<bool>> _validMoves = [];
  bool _botThinking = false;

  void _initBoard() {
    _board = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    _board[3][3] = 2;
    _board[3][4] = 1;
    _board[4][3] = 1;
    _board[4][4] = 2;
    _currentPlayer = 1;
    _gameOver = false;
    _botThinking = false;
    _updateCounts();
    _calculateValidMoves();
  }

  void _startGame(ReversiMode mode, [BotDifficulty? difficulty]) {
    setState(() {
      _mode = mode;
      if (difficulty != null) _botDifficulty = difficulty;
      _gameStarted = true;
      _initBoard();
    });
  }

  void _updateCounts() {
    _blackCount = 0;
    _whiteCount = 0;
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (_board[r][c] == 1) _blackCount++;
        if (_board[r][c] == 2) _whiteCount++;
      }
    }
  }

  void _calculateValidMoves() {
    _validMoves = List.generate(
      boardSize,
      (_) => List.filled(boardSize, false),
    );
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (_board[r][c] == 0 && _getFlips(r, c, _currentPlayer).isNotEmpty) {
          _validMoves[r][c] = true;
        }
      }
    }
  }

  List<List<int>> _getFlips(int row, int col, int player) {
    final opponent = player == 1 ? 2 : 1;
    final flips = <List<int>>[];
    const directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];
    for (final dir in directions) {
      final dirFlips = <List<int>>[];
      int r = row + dir[0], c = col + dir[1];
      while (r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          _board[r][c] == opponent) {
        dirFlips.add([r, c]);
        r += dir[0];
        c += dir[1];
      }
      if (dirFlips.isNotEmpty &&
          r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          _board[r][c] == player) {
        flips.addAll(dirFlips);
      }
    }
    return flips;
  }

  bool _hasValidMoves(int player) {
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (_board[r][c] == 0 && _getFlips(r, c, player).isNotEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  List<List<int>> _getAllValidMoves(int player) {
    final moves = <List<int>>[];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (_board[r][c] == 0 && _getFlips(r, c, player).isNotEmpty) {
          moves.add([r, c]);
        }
      }
    }
    return moves;
  }

  void _makeMove(int row, int col) {
    if (_gameOver || _board[row][col] != 0 || _botThinking) return;
    final flips = _getFlips(row, col, _currentPlayer);
    if (flips.isEmpty) return;

    setState(() {
      _board[row][col] = _currentPlayer;
      for (final flip in flips) {
        _board[flip[0]][flip[1]] = _currentPlayer;
      }
      _advanceTurn();
    });
  }

  void _advanceTurn() {
    final nextPlayer = _currentPlayer == 1 ? 2 : 1;
    if (_hasValidMoves(nextPlayer)) {
      _currentPlayer = nextPlayer;
    } else if (!_hasValidMoves(_currentPlayer)) {
      _gameOver = true;
    }
    _updateCounts();
    _calculateValidMoves();

    if (_gameOver) {
      _showGameOverDialog();
    } else if (_mode == ReversiMode.bot && _currentPlayer == 2 && !_gameOver) {
      _doBotMove();
    }
  }

  void _doBotMove() {
    _botThinking = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final move = _getBotMove();
      if (move != null) {
        _board[move[0]][move[1]] = 2;
        final flips = _getFlips(move[0], move[1], 2);
        for (final flip in flips) {
          _board[flip[0]][flip[1]] = 2;
        }
      }
      _botThinking = false;
      _advanceTurn();
      setState(() {});
    });
  }

  List<int>? _getBotMove() {
    final moves = _getAllValidMoves(2);
    if (moves.isEmpty) return null;
    switch (_botDifficulty) {
      case BotDifficulty.easy:
        return _botEasy(moves);
      case BotDifficulty.medium:
        return _botMedium(moves);
      case BotDifficulty.hard:
        return _botHard(moves);
      case BotDifficulty.expert:
        return _botExpert(moves);
    }
  }

  // Easy: random move
  List<int> _botEasy(List<List<int>> moves) {
    return moves[Random().nextInt(moves.length)];
  }

  // Medium: maximize flips
  List<int> _botMedium(List<List<int>> moves) {
    int bestScore = -1;
    List<int> bestMove = moves[0];
    for (final m in moves) {
      final score = _getFlips(m[0], m[1], 2).length;
      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
      }
    }
    return bestMove;
  }

  // Corner/edge weights for positional strategy
  static const List<List<int>> _posWeights = [
    [100, -20, 10, 5, 5, 10, -20, 100],
    [-20, -50, -2, -2, -2, -2, -50, -20],
    [10, -2, 1, 1, 1, 1, -2, 10],
    [5, -2, 1, 0, 0, 1, -2, 5],
    [5, -2, 1, 0, 0, 1, -2, 5],
    [10, -2, 1, 1, 1, 1, -2, 10],
    [-20, -50, -2, -2, -2, -2, -50, -20],
    [100, -20, 10, 5, 5, 10, -20, 100],
  ];

  // Hard: positional strategy
  List<int> _botHard(List<List<int>> moves) {
    int bestScore = -1000;
    List<int> bestMove = moves[0];
    for (final m in moves) {
      final flips = _getFlips(m[0], m[1], 2).length;
      final posScore = _posWeights[m[0]][m[1]] + flips;
      if (posScore > bestScore) {
        bestScore = posScore;
        bestMove = m;
      }
    }
    return bestMove;
  }

  // Expert: minimax 1-ply lookahead with positional weights
  List<int> _botExpert(List<List<int>> moves) {
    int bestScore = -100000;
    List<int> bestMove = moves[0];
    for (final m in moves) {
      // simulate move
      final boardCopy = _board.map((r) => List<int>.from(r)).toList();
      boardCopy[m[0]][m[1]] = 2;
      final flips = _getFlips(m[0], m[1], 2);
      for (final f in flips) {
        boardCopy[f[0]][f[1]] = 2;
      }

      // evaluate: our positional score minus opponent's best response
      int score = _posWeights[m[0]][m[1]] + flips.length * 2;

      // check opponent responses
      int opponentBest = -100000;
      for (int r = 0; r < boardSize; r++) {
        for (int c = 0; c < boardSize; c++) {
          if (boardCopy[r][c] == 0) {
            final oppFlips = _getFlipsOnBoard(boardCopy, r, c, 1);
            if (oppFlips.isNotEmpty) {
              final oppScore = _posWeights[r][c] + oppFlips.length * 2;
              if (oppScore > opponentBest) opponentBest = oppScore;
            }
          }
        }
      }
      if (opponentBest > -100000) score -= opponentBest;

      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
      }
    }
    return bestMove;
  }

  List<List<int>> _getFlipsOnBoard(
    List<List<int>> board,
    int row,
    int col,
    int player,
  ) {
    final opponent = player == 1 ? 2 : 1;
    final flips = <List<int>>[];
    const directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1],
    ];
    for (final dir in directions) {
      final dirFlips = <List<int>>[];
      int r = row + dir[0], c = col + dir[1];
      while (r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          board[r][c] == opponent) {
        dirFlips.add([r, c]);
        r += dir[0];
        c += dir[1];
      }
      if (dirFlips.isNotEmpty &&
          r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          board[r][c] == player) {
        flips.addAll(dirFlips);
      }
    }
    return flips;
  }

  void _showGameOverDialog() {
    String result;
    if (_blackCount > _whiteCount) {
      result = translate("black_wins");
    } else if (_whiteCount > _blackCount) {
      result = translate("white_wins");
    } else {
      result = translate("draw");
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final c = ctx.appColors;
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(translate("game_over"), textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                result,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$_blackCount - $_whiteCount",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _gameStarted = false;
                  _mode = ReversiMode.none;
                });
              },
              child: Text(translate("reversi_menu")),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _initBoard());
              },
              child: Text(translate("new_game")),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    final c = context.appColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(translate("what_is_reversi")),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translate("short_history"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                translate("reversi_history"),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                translate("how_to_play"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              ...[
                translate("reversi_rule_1"),
                translate("reversi_rule_2"),
                translate("reversi_rule_3"),
                translate("reversi_rule_4"),
              ].map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(r, style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(translate("ok")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    if (!_gameStarted) return _buildModeSelection(c);
    if (_mode == ReversiMode.friend) return _buildFriendGame(c);
    return _buildBotGame(c);
  }

  // ─── MODE SELECTION ───

  Widget _buildModeSelection(AppColors c) {
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        ),
        title: Text(translate("reversi")),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(CupertinoIcons.question_circle, size: 24),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Reversi icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  CupertinoIcons.circle_grid_3x3_fill,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                translate("reversi"),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translate("reversi_subtitle"),
                style: TextStyle(fontSize: 15, color: c.textSecondary),
              ),
              const SizedBox(height: 40),

              // VS Friend
              _buildModeCard(
                c,
                icon: CupertinoIcons.person_2_fill,
                title: translate("vs_friend"),
                subtitle: translate("vs_friend_desc"),
                gradient: const [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                onTap: () => _startGame(ReversiMode.friend),
              ),
              const SizedBox(height: 16),

              // VS Bot
              _buildModeCard(
                c,
                icon: CupertinoIcons.desktopcomputer,
                title: translate("vs_bot"),
                subtitle: translate("vs_bot_desc"),
                gradient: const [Color(0xFF66BB6A), Color(0xFF388E3C)],
                onTap: () => _showBotDifficultySheet(c),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    AppColors c, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showBotDifficultySheet(AppColors c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  translate("select_difficulty"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                ...[
                  (BotDifficulty.easy, translate("easy"), "🟢"),
                  (BotDifficulty.medium, translate("medium"), "🟡"),
                  (BotDifficulty.hard, translate("hard"), "🟠"),
                  (BotDifficulty.expert, translate("expert"), "🔴"),
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _startGame(ReversiMode.bot, item.$1);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: c.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          children: [
                            Text(item.$3, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 14),
                            Text(
                              item.$2,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: c.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: c.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── BOT GAME (normal orientation) ───

  Widget _buildBotGame(AppColors c) {
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => setState(() {
            _gameStarted = false;
            _mode = ReversiMode.none;
          }),
          icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        ),
        title: Text("${translate("reversi")} - ${translate("vs_bot")}"),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(CupertinoIcons.question_circle, size: 24),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildScoreBar(c),
          const SizedBox(height: 10),
          _buildTurnIndicator(c),
          const SizedBox(height: 10),
          Expanded(child: _buildBoard(c, false)),
          const SizedBox(height: 8),
          _buildActionBar(c),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── FRIEND GAME (two-player, phone rotated) ───

  Widget _buildFriendGame(AppColors c) {
    final isBlackTurn = _currentPlayer == 1;
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top player area (white - rotated 180°)
            Expanded(
              flex: 2,
              child: Transform.rotate(
                angle: 3.14159,
                child: _buildPlayerArea(
                  c,
                  playerName: translate("player_2"),
                  discColor: Colors.white,
                  count: _whiteCount,
                  isActive: !isBlackTurn && !_gameOver,
                  label: translate("white"),
                ),
              ),
            ),
            // Board in the middle
            Expanded(flex: 7, child: _buildBoard(c, false)),
            // Bottom player area (black - normal)
            Expanded(
              flex: 2,
              child: _buildPlayerArea(
                c,
                playerName: translate("player_1"),
                discColor: Colors.black,
                count: _blackCount,
                isActive: isBlackTurn && !_gameOver,
                label: translate("black"),
                showActions: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerArea(
    AppColors c, {
    required String playerName,
    required Color discColor,
    required int count,
    required bool isActive,
    required String label,
    bool showActions = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Player info
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: discColor,
              border: Border.all(
                color: isActive ? c.accent : Colors.grey.shade400,
                width: isActive ? 3 : 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: c.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "$label: ",
                      style: TextStyle(fontSize: 13, color: c.textSecondary),
                    ),
                    Text(
                      "$count",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          translate("your_turn"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (showActions) ...[
            GestureDetector(
              onTap: () => setState(() {
                _gameStarted = false;
                _mode = ReversiMode.none;
              }),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border),
                ),
                child: Icon(
                  CupertinoIcons.xmark,
                  size: 16,
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _initBoard()),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(CupertinoIcons.refresh, size: 16, color: c.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ───

  Widget _buildScoreBar(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreChip(
            c,
            translate("black"),
            _blackCount,
            Colors.black,
            _currentPlayer == 1,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "VS",
              style: TextStyle(
                color: c.accent,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          _buildScoreChip(
            c,
            translate("white"),
            _whiteCount,
            Colors.white,
            _currentPlayer == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(
    AppColors c,
    String label,
    int count,
    Color discColor,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? c.accent.withValues(alpha: 0.15) : c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? c.accent : Colors.grey.withValues(alpha: 0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: discColor,
              border: Border.all(color: Colors.grey, width: 1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(AppColors c) {
    if (_gameOver) return const SizedBox.shrink();
    final text = _botThinking
        ? translate("bot_thinking")
        : (_currentPlayer == 1
              ? translate("black_turn")
              : translate("white_turn"));
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: c.textPrimary.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildBoard(AppColors c, bool rotated) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1B5E20), width: 3),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: boardSize,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: boardSize * boardSize,
            itemBuilder: (context, index) {
              final row = index ~/ boardSize;
              final col = index % boardSize;
              return _buildCell(row, col, c);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, AppColors c) {
    final piece = _board[row][col];
    final isValid = _validMoves[row][col];
    return GestureDetector(
      onTap: isValid && !_botThinking ? () => _makeMove(row, col) : null,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF388E3C),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: piece != 0
              ? FractionallySizedBox(
                  widthFactor: 0.8,
                  heightFactor: 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: piece == 1 ? Colors.black : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                )
              : isValid && !_botThinking
              ? FractionallySizedBox(
                  widthFactor: 0.35,
                  heightFactor: 0.35,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildActionBar(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            c,
            CupertinoIcons.arrow_left,
            translate("reversi_menu"),
            () {
              setState(() {
                _gameStarted = false;
                _mode = ReversiMode.none;
              });
            },
          ),
          const SizedBox(width: 12),
          _buildActionButton(
            c,
            CupertinoIcons.refresh,
            translate("restart"),
            () {
              setState(() => _initBoard());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    AppColors c,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: c.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: c.accent),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: c.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
