import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../localization/app_localization.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  SudokuScreenState createState() => SudokuScreenState();
}

class SudokuScreenState extends State<SudokuScreen> {
  String _selectedDifficulty = 'Easy';
  bool _gameStarted = false;
  int? _selectedRow;
  int? _selectedCol;
  bool _notesMode = false;

  List<List<int>> _board = List.generate(9, (_) => List.filled(9, 0));
  List<List<bool>> _fixed = List.generate(9, (_) => List.filled(9, false));
  List<List<int>> _solution = List.generate(9, (_) => List.filled(9, 0));
  List<List<Set<int>>> _notes = List.generate(
    9,
    (_) => List.generate(9, (_) => <int>{}),
  );
  List<List<bool>> _errors = List.generate(9, (_) => List.filled(9, false));

  int _hintCount = 81;
  int _mistakeCount = 0;
  static const int _maxMistakes = 81;

  void _startGame() {
    final board = _generateSudoku();
    final clues = _getClueCount(_selectedDifficulty);
    final random = Random();
    _solution = board.map((r) => List<int>.from(r)).toList();
    _board = board.map((r) => List<int>.from(r)).toList();
    _fixed = List.generate(9, (_) => List.filled(9, false));
    _notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    _errors = List.generate(9, (_) => List.filled(9, false));
    _hintCount = 81;
    _mistakeCount = 0;
    int cellsToRemove = 81 - clues;
    while (cellsToRemove > 0) {
      int r = random.nextInt(9), c = random.nextInt(9);
      if (_board[r][c] != 0) {
        _board[r][c] = 0;
        cellsToRemove--;
      }
    }
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        _fixed[r][c] = _board[r][c] != 0;
      }
    }
    setState(() {
      _gameStarted = true;
      _selectedRow = null;
      _selectedCol = null;
      _notesMode = false;
    });
  }

  int _getClueCount(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 38;
      case 'Medium':
        return 30;
      case 'Hard':
        return 25;
      case 'Expert':
        return 20;
      default:
        return 38;
    }
  }

  List<List<int>> _generateSudoku() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    final random = Random();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) {
          List<int> nums = List.generate(9, (i) => i + 1)..shuffle(random);
          for (int num in nums) {
            if (_isValidPlacement(grid, r, c, num)) {
              grid[r][c] = num;
              if (_fillGrid(grid)) return true;
              grid[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidPlacement(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num || grid[i][col] == num) return false;
    }
    int boxRow = (row ~/ 3) * 3, boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }

  void _onCellTap(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _onNumberInput(int number) {
    if (_selectedRow == null ||
        _selectedCol == null ||
        _fixed[_selectedRow!][_selectedCol!]) {
      return;
    }
    setState(() {
      if (_notesMode) {
        final notes = _notes[_selectedRow!][_selectedCol!];
        notes.contains(number) ? notes.remove(number) : notes.add(number);
        _board[_selectedRow!][_selectedCol!] = 0;
      } else {
        _notes[_selectedRow!][_selectedCol!].clear();
        _board[_selectedRow!][_selectedCol!] = number;
        if (number != _solution[_selectedRow!][_selectedCol!]) {
          _errors[_selectedRow!][_selectedCol!] = true;
          _mistakeCount++;
          if (_mistakeCount >= _maxMistakes) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _showGameOverDialog(),
            );
          }
        } else {
          _errors[_selectedRow!][_selectedCol!] = false;
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkWin());
        }
      }
    });
  }

  void _onErase() {
    if (_selectedRow == null ||
        _selectedCol == null ||
        _fixed[_selectedRow!][_selectedCol!]) {
      return;
    }
    setState(() {
      _board[_selectedRow!][_selectedCol!] = 0;
      _notes[_selectedRow!][_selectedCol!].clear();
      _errors[_selectedRow!][_selectedCol!] = false;
    });
  }

  void _onHint() {
    if (_hintCount <= 0) return;
    List<List<int>> emptyCells = [];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!_fixed[r][c] && _board[r][c] != _solution[r][c]) {
          emptyCells.add([r, c]);
        }
      }
    }
    if (emptyCells.isEmpty) return;
    final cell = emptyCells[Random().nextInt(emptyCells.length)];
    setState(() {
      _board[cell[0]][cell[1]] = _solution[cell[0]][cell[1]];
      _errors[cell[0]][cell[1]] = false;
      _notes[cell[0]][cell[1]].clear();
      _fixed[cell[0]][cell[1]] = true;
      _hintCount--;
    });
    _checkWin();
  }

  void _checkWin() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_board[r][c] != _solution[r][c]) return;
      }
    }
    _showWinDialog();
  }

  void _showWinDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              FontAwesomeIcons.trophy,
              color: AppColors.gameOrange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(translate("congratulations")),
          ],
        ),
        content: Text(translate("sudoku_solved")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dc).pop();
              if (mounted) setState(() => _gameStarted = false);
            },
            child: Text(translate("new_game")),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dc) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              FontAwesomeIcons.faceSadTear,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(translate("game_over")),
          ],
        ),
        content: Text(translate("three_mistakes")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dc).pop();
              if (mounted) setState(() => _gameStarted = false);
            },
            child: Text(translate("ok")),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final c = context.appColors;
    showDialog(
      context: context,
      builder: (dc) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.accentLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.circleQuestion,
                        size: 20,
                        color: c.accent,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        translate("what_is_sudoku"),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(dc).pop(),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: c.textSecondary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.accentLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate("short_history"),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translate("sudoku_history"),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate("how_to_play"),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _HelpRule(number: '1', text: translate("rule_1")),
                      const SizedBox(height: 8),
                      _HelpRule(number: '2', text: translate("rule_2")),
                      const SizedBox(height: 8),
                      _HelpRule(number: '3', text: translate("rule_3")),
                      const SizedBox(height: 8),
                      _HelpRule(number: '4', text: translate("rule_4")),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gameBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translate("tips"),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gameBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translate("tips_text"),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        title: Text(translate("sudoku")),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(FontAwesomeIcons.circleQuestion, size: 20),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            if (!_gameStarted) ...[
              const SizedBox(height: 8),
              _buildDifficultySelector(c),
              const SizedBox(height: 24),
              _buildPlaceholderBoard(c),
              const SizedBox(height: 24),
              _buildStartButton(),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 4),
              _buildGameInfo(c),
              const SizedBox(height: 12),
              _buildBoard(c),
              const SizedBox(height: 12),
              _buildActionBar(c),
              const SizedBox(height: 8),
              _buildNumberPad(c),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo(AppColors c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: c.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _selectedDifficulty,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: c.accent,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(FontAwesomeIcons.xmark, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              '$_mistakeCount / $_maxMistakes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(AppColors c) {
    final difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: difficulties.map((d) {
          final sel = d == _selectedDifficulty;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? c.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                    color: sel ? Colors.white : c.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaceholderBoard(AppColors c) {
    return Expanded(
      child: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.tableCells,
                size: 64,
                color: c.accent.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Sudoku Board',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                translate("select_difficulty_start"),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _startGame,
        icon: const Icon(FontAwesomeIcons.play, size: 16),
        label: Text(
          translate("start_game", {"difficulty": _selectedDifficulty}),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(AppColors c) {
    final boardSize = MediaQuery.of(context).size.width - 32;
    final cellSize = boardSize / 9;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: c.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              Column(
                children: List.generate(
                  9,
                  (row) => Row(
                    children: List.generate(
                      9,
                      (col) => _buildCell(row, col, cellSize, c),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: _GridPainter(c.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, double size, AppColors c) {
    final isSelected = row == _selectedRow && col == _selectedCol;
    final isFixed = _fixed[row][col];
    final value = _board[row][col];
    final hasError = _errors[row][col];
    final notes = _notes[row][col];
    bool isHighlighted = false;
    if (_selectedRow != null && _selectedCol != null) {
      if (row == _selectedRow || col == _selectedCol) isHighlighted = true;
      int selBoxR = (_selectedRow! ~/ 3) * 3,
          selBoxC = (_selectedCol! ~/ 3) * 3;
      if ((row ~/ 3) * 3 == selBoxR && (col ~/ 3) * 3 == selBoxC) {
        isHighlighted = true;
      }
    }
    bool isSameNumber = false;
    if (_selectedRow != null && _selectedCol != null) {
      int sv = _board[_selectedRow!][_selectedCol!];
      if (sv != 0 && value == sv) isSameNumber = true;
    }
    Color bgColor = c.card;
    if (isSelected) {
      bgColor = c.accent.withValues(alpha: 0.2);
    } else if (isSameNumber) {
      bgColor = c.accent.withValues(alpha: 0.1);
    } else if (isHighlighted) {
      bgColor = c.surface;
    }

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(color: c.divider, width: 0.5),
            bottom: BorderSide(color: c.divider, width: 0.5),
          ),
        ),
        child: Center(
          child: value != 0
              ? Text(
                  '$value',
                  style: TextStyle(
                    fontSize: size * 0.5,
                    fontWeight: isFixed ? FontWeight.w700 : FontWeight.w500,
                    color: hasError
                        ? Colors.red
                        : isFixed
                        ? c.textPrimary
                        : c.accent,
                  ),
                )
              : notes.isNotEmpty
              ? _buildNotesGrid(notes, size, c)
              : null,
        ),
      ),
    );
  }

  Widget _buildNotesGrid(Set<int> notes, double cellSize, AppColors c) {
    final noteSize = cellSize / 3;
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Wrap(
        children: List.generate(9, (i) {
          final num = i + 1;
          return SizedBox(
            width: noteSize,
            height: noteSize,
            child: Center(
              child: Text(
                notes.contains(num) ? '$num' : '',
                style: TextStyle(
                  fontSize: noteSize * 0.6,
                  color: c.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionBar(AppColors c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: FontAwesomeIcons.eraser,
          label: translate("erase"),
          onTap: _onErase,
          c: c,
        ),
        _buildActionButton(
          icon: FontAwesomeIcons.pencil,
          label: translate("notes"),
          onTap: () => setState(() => _notesMode = !_notesMode),
          isActive: _notesMode,
          c: c,
        ),
        _buildActionButton(
          icon: FontAwesomeIcons.lightbulb,
          label: translate("hint_count", {"count": _hintCount.toString()}),
          onTap: _onHint,
          c: c,
        ),
        _buildActionButton(
          icon: FontAwesomeIcons.arrowRotateLeft,
          label: translate("restart"),
          onTap: () => setState(() => _gameStarted = false),
          c: c,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppColors c,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? c.accent : c.card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: c.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : c.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: c.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (i) {
          final num = i + 1;
          int count = 0;
          for (int r = 0; r < 9; r++) {
            for (int cc = 0; cc < 9; cc++) {
              if (_board[r][cc] == num) count++;
            }
          }
          final isComplete = count >= 9;
          return GestureDetector(
            onTap: isComplete ? null : () => _onNumberInput(num),
            child: Container(
              width: 34,
              height: 50,
              decoration: BoxDecoration(
                color: isComplete ? c.divider : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$num',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isComplete ? c.textSecondary : c.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _HelpRule extends StatelessWidget {
  final String number;
  final String text;
  const _HelpRule({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, height: 1.4, color: c.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final cellSize = size.width / 9;
    for (int i = 0; i <= 3; i++) {
      double pos = i * cellSize * 3;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}
