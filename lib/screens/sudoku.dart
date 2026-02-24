import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

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

  // 9x9 board: 0 means empty
  List<List<int>> _board = List.generate(9, (_) => List.filled(9, 0));
  // Which cells are pre-filled (not editable)
  List<List<bool>> _fixed = List.generate(9, (_) => List.filled(9, false));
  // Solution board
  List<List<int>> _solution = List.generate(9, (_) => List.filled(9, 0));
  // Notes: each cell has a set of candidate numbers
  List<List<Set<int>>> _notes = List.generate(
    9,
    (_) => List.generate(9, (_) => <int>{}),
  );
  // Track errors
  List<List<bool>> _errors = List.generate(9, (_) => List.filled(9, false));

  int _hintCount = 3;
  int _mistakeCount = 0;
  static const int _maxMistakes = 3;

  void _startGame() {
    final board = _generateSudoku();
    final clues = _getClueCount(_selectedDifficulty);
    final random = Random();

    _solution = board.map((r) => List<int>.from(r)).toList();
    _board = board.map((r) => List<int>.from(r)).toList();
    _fixed = List.generate(9, (_) => List.filled(9, false));
    _notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    _errors = List.generate(9, (_) => List.filled(9, false));
    _hintCount = 3;
    _mistakeCount = 0;

    // Remove cells to create puzzle
    int cellsToRemove = 81 - clues;
    while (cellsToRemove > 0) {
      int r = random.nextInt(9);
      int c = random.nextInt(9);
      if (_board[r][c] != 0) {
        _board[r][c] = 0;
        cellsToRemove--;
      }
    }

    // Mark remaining cells as fixed
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
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == num) return false;
      }
    }
    return true;
  }

  void _onCellTap(int row, int col) {
    if (_fixed[row][col]) {
      setState(() {
        _selectedRow = row;
        _selectedCol = col;
      });
      return;
    }
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _onNumberInput(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_fixed[_selectedRow!][_selectedCol!]) return;

    setState(() {
      if (_notesMode) {
        final notes = _notes[_selectedRow!][_selectedCol!];
        if (notes.contains(number)) {
          notes.remove(number);
        } else {
          notes.add(number);
        }
        _board[_selectedRow!][_selectedCol!] = 0;
      } else {
        _notes[_selectedRow!][_selectedCol!].clear();
        _board[_selectedRow!][_selectedCol!] = number;
        if (number != _solution[_selectedRow!][_selectedCol!]) {
          _errors[_selectedRow!][_selectedCol!] = true;
          _mistakeCount++;
          if (_mistakeCount >= _maxMistakes) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showGameOverDialog();
            });
          }
        } else {
          _errors[_selectedRow!][_selectedCol!] = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkWin();
          });
        }
      }
    });
  }

  void _onErase() {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_fixed[_selectedRow!][_selectedCol!]) return;
    setState(() {
      _board[_selectedRow!][_selectedCol!] = 0;
      _notes[_selectedRow!][_selectedCol!].clear();
      _errors[_selectedRow!][_selectedCol!] = false;
    });
  }

  void _onHint() {
    if (_hintCount <= 0) return;
    // Find an empty or wrong cell
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(FontAwesomeIcons.trophy, color: AppTheme.warmOrange, size: 24),
            SizedBox(width: 12),
            Text('Tebrikler!'),
          ],
        ),
        content: const Text('Sudoku bulmacasını başarıyla çözdünüz!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) setState(() => _gameStarted = false);
            },
            child: const Text('Yeni Oyun'),
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(FontAwesomeIcons.faceSadTear, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text('Oyun Bitti'),
          ],
        ),
        content: const Text('3 hata yaptınız. Tekrar deneyin!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (mounted) setState(() => _gameStarted = false);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
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
                        color: AppTheme.lightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.circleQuestion,
                        size: 20,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Sudoku Nedir?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: AppTheme.textSecondary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📖 Kısa Tarihçe',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Sudoku, 18. yüzyılda İsviçreli matematikçi Leonhard Euler\'in '
                        '"Latin Kareleri" çalışmasından ilham alınarak ortaya çıkmıştır. '
                        'Modern hali 1979\'da Amerikalı Howard Garns tarafından '
                        '"Number Place" adıyla tasarlanmış, ardından 1984\'te Japonya\'da '
                        '"Sudoku" (sayı tek olmalı) adıyla büyük popülerlik kazanmıştır. '
                        '2005 yılından itibaren tüm dünyada en sevilen bulmacalardan biri haline gelmiştir.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎮 Nasıl Oynanır?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 10),
                      _HelpRule(
                        number: '1',
                        text:
                            '9×9\'luk ızgaranın her satırında 1-9 arası rakamlar birer kez bulunmalıdır.',
                      ),
                      SizedBox(height: 8),
                      _HelpRule(
                        number: '2',
                        text:
                            'Her sütunda da 1-9 arası rakamlar birer kez yer almalıdır.',
                      ),
                      SizedBox(height: 8),
                      _HelpRule(
                        number: '3',
                        text:
                            'Her 3×3\'lük kutucukta 1-9 arası rakamlar tekrar etmemelidir.',
                      ),
                      SizedBox(height: 8),
                      _HelpRule(
                        number: '4',
                        text:
                            'Önceden yerleştirilmiş sayıları ipucu olarak kullanarak boş hücreleri doldurun.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 İpuçları',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentBlue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Not modunu kullanarak olası sayıları işaretleyin.\n'
                        '• 3 ipucu hakkınız var, zor anlarda kullanın.\n'
                        '• 3 hata yaparsanız oyun sona erer, dikkatli olun!',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: AppTheme.textPrimary,
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceLight,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        ),
        title: const Text('Sudoku'),
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
              _buildDifficultySelector(),
              const SizedBox(height: 24),
              _buildPlaceholderBoard(),
              const SizedBox(height: 24),
              _buildStartButton(),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 4),
              _buildGameInfo(),
              const SizedBox(height: 12),
              _buildBoard(),
              const SizedBox(height: 12),
              _buildActionBar(),
              const SizedBox(height: 8),
              _buildNumberPad(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.lightGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _selectedDifficulty,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkGreen,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(FontAwesomeIcons.xmark, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              '$_mistakeCount / $_maxMistakes',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    final difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: difficulties.map((d) {
          final isSelected = d == _selectedDifficulty;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlaceholderBoard() {
    return Expanded(
      child: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.tableCells,
                size: 64,
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Sudoku Board',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Zorluk seçip oyuna başlayın',
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
        label: Text('Start $_selectedDifficulty Game'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    final boardSize = MediaQuery.of(context).size.width - 32;
    final cellSize = boardSize / 9;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
              // Cells
              Column(
                children: List.generate(9, (row) {
                  return Row(
                    children: List.generate(9, (col) {
                      return _buildCell(row, col, cellSize);
                    }),
                  );
                }),
              ),
              // 3x3 box borders
              IgnorePointer(
                child: CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: _GridPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, double size) {
    final isSelected = row == _selectedRow && col == _selectedCol;
    final isFixed = _fixed[row][col];
    final value = _board[row][col];
    final hasError = _errors[row][col];
    final notes = _notes[row][col];

    // Highlight same row/col/box as selected
    bool isHighlighted = false;
    if (_selectedRow != null && _selectedCol != null) {
      if (row == _selectedRow || col == _selectedCol) {
        isHighlighted = true;
      }
      int selBoxR = (_selectedRow! ~/ 3) * 3;
      int selBoxC = (_selectedCol! ~/ 3) * 3;
      int cellBoxR = (row ~/ 3) * 3;
      int cellBoxC = (col ~/ 3) * 3;
      if (selBoxR == cellBoxR && selBoxC == cellBoxC) {
        isHighlighted = true;
      }
    }

    // Highlight same number
    bool isSameNumber = false;
    if (_selectedRow != null && _selectedCol != null) {
      int selectedVal = _board[_selectedRow!][_selectedCol!];
      if (selectedVal != 0 && value == selectedVal) {
        isSameNumber = true;
      }
    }

    Color bgColor = Colors.white;
    if (isSelected) {
      bgColor = AppTheme.primaryGreen.withValues(alpha: 0.2);
    } else if (isSameNumber) {
      bgColor = AppTheme.primaryGreen.withValues(alpha: 0.1);
    } else if (isHighlighted) {
      bgColor = AppTheme.surfaceLight;
    }

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: BorderSide(color: Colors.grey.shade300, width: 0.5),
            bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
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
                        ? AppTheme.textPrimary
                        : AppTheme.primaryGreen,
                  ),
                )
              : notes.isNotEmpty
              ? _buildNotesGrid(notes, size)
              : null,
        ),
      ),
    );
  }

  Widget _buildNotesGrid(Set<int> notes, double cellSize) {
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
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: FontAwesomeIcons.eraser,
          label: 'Sil',
          onTap: _onErase,
        ),
        _buildActionButton(
          icon: FontAwesomeIcons.pencil,
          label: 'Not',
          onTap: () => setState(() => _notesMode = !_notesMode),
          isActive: _notesMode,
        ),
        _buildActionButton(
          icon: FontAwesomeIcons.lightbulb,
          label: 'İpucu ($_hintCount)',
          onTap: _onHint,
        ),
        _buildActionButton(
          icon: FontAwesomeIcons.arrowRotateLeft,
          label: 'Yeniden',
          onTap: () => setState(() => _gameStarted = false),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
              color: isActive ? AppTheme.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (i) {
          final num = i + 1;
          // Count how many of this number are placed
          int count = 0;
          for (int r = 0; r < 9; r++) {
            for (int c = 0; c < 9; c++) {
              if (_board[r][c] == num) count++;
            }
          }
          final isComplete = count >= 9;

          return GestureDetector(
            onTap: isComplete ? null : () => _onNumberInput(num),
            child: Container(
              width: 34,
              height: 50,
              decoration: BoxDecoration(
                color: isComplete ? Colors.grey.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$num',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isComplete
                          ? Colors.grey.shade400
                          : AppTheme.textPrimary,
                    ),
                  ),
                ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
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
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final cellSize = size.width / 9;

    // Draw 3x3 box borders
    for (int i = 0; i <= 3; i++) {
      double pos = i * cellSize * 3;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
