import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import '../theme/app_theme.dart';
import '../localization/app_localization.dart';

enum ChessMode { none, friend, bot }

enum ChessBotDifficulty { easy, medium, hard, expert }

// Piece types
const int empty = 0;
const int wPawn = 1, wKnight = 2, wBishop = 3, wRook = 4, wQueen = 5, wKing = 6;
const int bPawn = 7,
    bKnight = 8,
    bBishop = 9,
    bRook = 10,
    bQueen = 11,
    bKing = 12;

bool isWhite(int p) => p >= 1 && p <= 6;
bool isBlack(int p) => p >= 7 && p <= 12;
bool isAlly(int p, bool whiteToMove) => whiteToMove ? isWhite(p) : isBlack(p);
bool isEnemy(int p, bool whiteToMove) => whiteToMove ? isBlack(p) : isWhite(p);

String pieceUnicode(int p) {
  switch (p) {
    case wKing:
      return '♔';
    case wQueen:
      return '♕';
    case wRook:
      return '♖';
    case wBishop:
      return '♗';
    case wKnight:
      return '♘';
    case wPawn:
      return '♙';
    case bKing:
      return '♚';
    case bQueen:
      return '♛';
    case bRook:
      return '♜';
    case bBishop:
      return '♝';
    case bKnight:
      return '♞';
    case bPawn:
      return '♟';
    default:
      return '';
  }
}

Widget pieceWidget(int p, double size) {
  switch (p) {
    case wKing:
      return WhiteKing(size: size);
    case wQueen:
      return WhiteQueen(size: size);
    case wRook:
      return WhiteRook(size: size);
    case wBishop:
      return WhiteBishop(size: size);
    case wKnight:
      return WhiteKnight(size: size);
    case wPawn:
      return WhitePawn(size: size);
    case bKing:
      return BlackKing(size: size);
    case bQueen:
      return BlackQueen(size: size);
    case bRook:
      return BlackRook(size: size);
    case bBishop:
      return BlackBishop(size: size);
    case bKnight:
      return BlackKnight(size: size);
    case bPawn:
      return BlackPawn(size: size);
    default:
      return const SizedBox.shrink();
  }
}

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});
  @override
  ChessScreenState createState() => ChessScreenState();
}

class ChessScreenState extends State<ChessScreen> {
  ChessMode _mode = ChessMode.none;
  ChessBotDifficulty _botDifficulty = ChessBotDifficulty.easy;
  bool _gameStarted = false;

  // Board state: 8x8, row 0 = rank 8 (black side), row 7 = rank 1 (white side)
  List<List<int>> _board = [];
  bool _whiteToMove = true;
  int? _selectedRow, _selectedCol;
  List<List<int>> _validMoves = [];
  bool _gameOver = false;
  String _gameResult = '';
  bool _botThinking = false;

  // Castling rights
  bool _whiteKingSideCastle = true, _whiteQueenSideCastle = true;
  bool _blackKingSideCastle = true, _blackQueenSideCastle = true;

  // En passant target square (row, col) or null
  List<int>? _enPassantTarget;

  // Last move for highlighting
  List<int>? _lastMoveFrom, _lastMoveTo;

  void _initBoard() {
    _board = [
      [bRook, bKnight, bBishop, bQueen, bKing, bBishop, bKnight, bRook],
      [bPawn, bPawn, bPawn, bPawn, bPawn, bPawn, bPawn, bPawn],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [wPawn, wPawn, wPawn, wPawn, wPawn, wPawn, wPawn, wPawn],
      [wRook, wKnight, wBishop, wQueen, wKing, wBishop, wKnight, wRook],
    ];
    _whiteToMove = true;
    _selectedRow = null;
    _selectedCol = null;
    _validMoves = [];
    _gameOver = false;
    _gameResult = '';
    _botThinking = false;
    _whiteKingSideCastle = true;
    _whiteQueenSideCastle = true;
    _blackKingSideCastle = true;
    _blackQueenSideCastle = true;
    _enPassantTarget = null;
    _lastMoveFrom = null;
    _lastMoveTo = null;
  }

  void _startGame(ChessMode mode, [ChessBotDifficulty? difficulty]) {
    setState(() {
      _mode = mode;
      if (difficulty != null) _botDifficulty = difficulty;
      _gameStarted = true;
      _initBoard();
    });
  }

  // ─── MOVE GENERATION ───

  List<List<int>> _getLegalMoves(int row, int col) {
    final piece = _board[row][col];
    if (piece == empty) return [];
    final raw = _getRawMoves(row, col, piece);
    // Filter out moves that leave own king in check
    final legal = <List<int>>[];
    for (final m in raw) {
      if (_isMoveSafe(row, col, m[0], m[1])) {
        legal.add(m);
      }
    }
    return legal;
  }

  List<List<int>> _getRawMoves(int row, int col, int piece) {
    final moves = <List<int>>[];
    final white = isWhite(piece);

    switch (piece) {
      case wPawn:
        _addPawnMoves(moves, row, col, -1, true);
        break;
      case bPawn:
        _addPawnMoves(moves, row, col, 1, false);
        break;
      case wKnight:
      case bKnight:
        _addKnightMoves(moves, row, col, white);
        break;
      case wBishop:
      case bBishop:
        _addSlidingMoves(moves, row, col, white, [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ]);
        break;
      case wRook:
      case bRook:
        _addSlidingMoves(moves, row, col, white, [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ]);
        break;
      case wQueen:
      case bQueen:
        _addSlidingMoves(moves, row, col, white, [
          [-1, -1],
          [-1, 0],
          [-1, 1],
          [0, -1],
          [0, 1],
          [1, -1],
          [1, 0],
          [1, 1],
        ]);
        break;
      case wKing:
      case bKing:
        _addKingMoves(moves, row, col, white);
        break;
    }
    return moves;
  }

  void _addPawnMoves(List<List<int>> moves, int r, int c, int dir, bool white) {
    final startRow = white ? 6 : 1;
    // Forward
    if (_inBounds(r + dir, c) && _board[r + dir][c] == empty) {
      moves.add([r + dir, c]);
      // Double push
      if (r == startRow && _board[r + dir * 2][c] == empty) {
        moves.add([r + dir * 2, c]);
      }
    }
    // Captures
    for (final dc in [-1, 1]) {
      final nr = r + dir, nc = c + dc;
      if (!_inBounds(nr, nc)) continue;
      if (_board[nr][nc] != empty &&
          (white ? isBlack(_board[nr][nc]) : isWhite(_board[nr][nc]))) {
        moves.add([nr, nc]);
      }
      // En passant
      if (_enPassantTarget != null &&
          _enPassantTarget![0] == nr &&
          _enPassantTarget![1] == nc) {
        moves.add([nr, nc]);
      }
    }
  }

  void _addKnightMoves(List<List<int>> moves, int r, int c, bool white) {
    const offsets = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1],
    ];
    for (final o in offsets) {
      final nr = r + o[0], nc = c + o[1];
      if (_inBounds(nr, nc) && !isAlly(_board[nr][nc], white)) {
        moves.add([nr, nc]);
      }
    }
  }

  void _addSlidingMoves(
    List<List<int>> moves,
    int r,
    int c,
    bool white,
    List<List<int>> dirs,
  ) {
    for (final d in dirs) {
      int nr = r + d[0], nc = c + d[1];
      while (_inBounds(nr, nc)) {
        if (_board[nr][nc] == empty) {
          moves.add([nr, nc]);
        } else {
          if (isEnemy(_board[nr][nc], white)) moves.add([nr, nc]);
          break;
        }
        nr += d[0];
        nc += d[1];
      }
    }
  }

  void _addKingMoves(List<List<int>> moves, int r, int c, bool white) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = r + dr, nc = c + dc;
        if (_inBounds(nr, nc) && !isAlly(_board[nr][nc], white)) {
          moves.add([nr, nc]);
        }
      }
    }
    // Castling
    if (white && r == 7 && c == 4) {
      if (_whiteKingSideCastle &&
          _board[7][5] == empty &&
          _board[7][6] == empty &&
          _board[7][7] == wRook &&
          !_isSquareAttacked(7, 4, false) &&
          !_isSquareAttacked(7, 5, false) &&
          !_isSquareAttacked(7, 6, false)) {
        moves.add([7, 6]);
      }
      if (_whiteQueenSideCastle &&
          _board[7][3] == empty &&
          _board[7][2] == empty &&
          _board[7][1] == empty &&
          _board[7][0] == wRook &&
          !_isSquareAttacked(7, 4, false) &&
          !_isSquareAttacked(7, 3, false) &&
          !_isSquareAttacked(7, 2, false)) {
        moves.add([7, 2]);
      }
    } else if (!white && r == 0 && c == 4) {
      if (_blackKingSideCastle &&
          _board[0][5] == empty &&
          _board[0][6] == empty &&
          _board[0][7] == bRook &&
          !_isSquareAttacked(0, 4, true) &&
          !_isSquareAttacked(0, 5, true) &&
          !_isSquareAttacked(0, 6, true)) {
        moves.add([0, 6]);
      }
      if (_blackQueenSideCastle &&
          _board[0][3] == empty &&
          _board[0][2] == empty &&
          _board[0][1] == empty &&
          _board[0][0] == bRook &&
          !_isSquareAttacked(0, 4, true) &&
          !_isSquareAttacked(0, 3, true) &&
          !_isSquareAttacked(0, 2, true)) {
        moves.add([0, 2]);
      }
    }
  }

  bool _inBounds(int r, int c) => r >= 0 && r < 8 && c >= 0 && c < 8;

  bool _isSquareAttacked(int r, int c, bool byWhite) {
    // Check if square (r,c) is attacked by any piece of color byWhite
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final p = _board[row][col];
        if (p == empty) continue;
        if (byWhite ? !isWhite(p) : !isBlack(p)) continue;
        final moves = _getRawMoves(row, col, p);
        for (final m in moves) {
          if (m[0] == r && m[1] == c) return true;
        }
      }
    }
    return false;
  }

  bool _isMoveSafe(int fromR, int fromC, int toR, int toC) {
    final piece = _board[fromR][fromC];
    final captured = _board[toR][toC];
    final white = isWhite(piece);

    // Simulate move
    _board[toR][toC] = piece;
    _board[fromR][fromC] = empty;

    // Handle en passant capture
    int? epCapturedRow;
    int? epCapturedCol;
    int epCapturedPiece = empty;
    if ((piece == wPawn || piece == bPawn) &&
        _enPassantTarget != null &&
        toR == _enPassantTarget![0] &&
        toC == _enPassantTarget![1]) {
      epCapturedRow = fromR;
      epCapturedCol = toC;
      epCapturedPiece = _board[fromR][toC];
      _board[fromR][toC] = empty;
    }

    // Find king
    int kingR = -1, kingC = -1;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (_board[r][c] == (white ? wKing : bKing)) {
          kingR = r;
          kingC = c;
        }
      }
    }

    final safe = !_isSquareAttacked(kingR, kingC, !white);

    // Undo
    _board[fromR][fromC] = piece;
    _board[toR][toC] = captured;
    if (epCapturedRow != null) {
      _board[epCapturedRow][epCapturedCol!] = epCapturedPiece;
    }

    return safe;
  }

  // ─── MAKE MOVE ───

  void _makeMove(int toR, int toC) {
    if (_selectedRow == null || _gameOver || _botThinking) return;
    final fromR = _selectedRow!, fromC = _selectedCol!;
    final piece = _board[fromR][fromC];

    setState(() {
      _lastMoveFrom = [fromR, fromC];
      _lastMoveTo = [toR, toC];

      // En passant capture
      if ((piece == wPawn || piece == bPawn) &&
          _enPassantTarget != null &&
          toR == _enPassantTarget![0] &&
          toC == _enPassantTarget![1]) {
        _board[fromR][toC] = empty;
      }

      // Set en passant target
      if (piece == wPawn && fromR == 6 && toR == 4) {
        _enPassantTarget = [5, fromC];
      } else if (piece == bPawn && fromR == 1 && toR == 3) {
        _enPassantTarget = [2, fromC];
      } else {
        _enPassantTarget = null;
      }

      // Castling move
      if (piece == wKing && fromC == 4 && toC == 6) {
        _board[7][5] = wRook;
        _board[7][7] = empty;
      } else if (piece == wKing && fromC == 4 && toC == 2) {
        _board[7][3] = wRook;
        _board[7][0] = empty;
      } else if (piece == bKing && fromC == 4 && toC == 6) {
        _board[0][5] = bRook;
        _board[0][7] = empty;
      } else if (piece == bKing && fromC == 4 && toC == 2) {
        _board[0][3] = bRook;
        _board[0][0] = empty;
      }

      // Update castling rights
      if (piece == wKing) {
        _whiteKingSideCastle = false;
        _whiteQueenSideCastle = false;
      }
      if (piece == bKing) {
        _blackKingSideCastle = false;
        _blackQueenSideCastle = false;
      }
      if (piece == wRook && fromR == 7 && fromC == 7) {
        _whiteKingSideCastle = false;
      }
      if (piece == wRook && fromR == 7 && fromC == 0) {
        _whiteQueenSideCastle = false;
      }
      if (piece == bRook && fromR == 0 && fromC == 7) {
        _blackKingSideCastle = false;
      }
      if (piece == bRook && fromR == 0 && fromC == 0) {
        _blackQueenSideCastle = false;
      }

      _board[toR][toC] = piece;
      _board[fromR][fromC] = empty;
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = [];

      // Pawn promotion
      if (piece == wPawn && toR == 0) {
        _showPromotionDialog(toR, toC, true);
        return;
      } else if (piece == bPawn && toR == 7) {
        if (_mode == ChessMode.bot) {
          // Bot auto-promotes to queen
          _board[toR][toC] = bQueen;
        } else {
          _showPromotionDialog(toR, toC, false);
          return;
        }
      }

      _whiteToMove = !_whiteToMove;
      _checkGameState();

      if (_mode == ChessMode.bot && !_whiteToMove && !_gameOver) {
        _doBotMove();
      }
    });
  }

  void _showPromotionDialog(int row, int col, bool white) {
    final pieces = white
        ? [wQueen, wRook, wBishop, wKnight]
        : [bQueen, bRook, bBishop, bKnight];
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
          title: Text(translate("promote_pawn"), textAlign: TextAlign.center),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: pieces
                .map(
                  (p) => GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _board[row][col] = p;
                        _whiteToMove = !_whiteToMove;
                        _checkGameState();
                        if (_mode == ChessMode.bot &&
                            !_whiteToMove &&
                            !_gameOver) {
                          _doBotMove();
                        }
                      });
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Center(child: pieceWidget(p, 36)),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  void _checkGameState() {
    // Check if current player has any legal moves
    bool hasLegal = false;
    for (int r = 0; r < 8 && !hasLegal; r++) {
      for (int c = 0; c < 8 && !hasLegal; c++) {
        if (isAlly(_board[r][c], _whiteToMove)) {
          if (_getLegalMoves(r, c).isNotEmpty) hasLegal = true;
        }
      }
    }

    if (!hasLegal) {
      _gameOver = true;
      // Find king
      int kingR = -1, kingC = -1;
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (_board[r][c] == (_whiteToMove ? wKing : bKing)) {
            kingR = r;
            kingC = c;
          }
        }
      }
      final inCheck = _isSquareAttacked(kingR, kingC, !_whiteToMove);
      if (inCheck) {
        _gameResult = _whiteToMove
            ? translate("black_wins_chess")
            : translate("white_wins_chess");
      } else {
        _gameResult = translate("stalemate");
      }
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _showGameOverDialog();
      });
    }
  }

  // ─── BOT AI ───

  void _doBotMove() {
    _botThinking = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final move = _getBotMove();
      if (move != null) {
        _selectedRow = move[0];
        _selectedCol = move[1];
        _makeMove(move[2], move[3]);
      }
      _botThinking = false;
      setState(() {});
    });
  }

  List<int>? _getBotMove() {
    final allMoves = <List<int>>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        if (isBlack(_board[r][c])) {
          for (final m in _getLegalMoves(r, c)) {
            allMoves.add([r, c, m[0], m[1]]);
          }
        }
      }
    }
    if (allMoves.isEmpty) return null;

    switch (_botDifficulty) {
      case ChessBotDifficulty.easy:
        return allMoves[Random().nextInt(allMoves.length)];
      case ChessBotDifficulty.medium:
        return _botMedium(allMoves);
      case ChessBotDifficulty.hard:
        return _botHard(allMoves);
      case ChessBotDifficulty.expert:
        return _botExpert(allMoves);
    }
  }

  static const Map<int, int> _pieceValues = {
    wPawn: 100,
    bPawn: 100,
    wKnight: 320,
    bKnight: 320,
    wBishop: 330,
    bBishop: 330,
    wRook: 500,
    bRook: 500,
    wQueen: 900,
    bQueen: 900,
    wKing: 20000,
    bKing: 20000,
  };

  int _evaluateBoard() {
    int score = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = _board[r][c];
        if (p == empty) continue;
        final val = _pieceValues[p] ?? 0;
        score += isWhite(p)
            ? -val
            : val; // Bot is black, positive = good for bot
      }
    }
    return score;
  }

  List<int> _botMedium(List<List<int>> moves) {
    // Prefer captures, then random
    final captures = moves.where((m) => _board[m[2]][m[3]] != empty).toList();
    if (captures.isNotEmpty) {
      // Pick highest value capture
      captures.sort(
        (a, b) =>
            (_pieceValues[_board[b[2]][b[3]]] ?? 0) -
            (_pieceValues[_board[a[2]][a[3]]] ?? 0),
      );
      return captures.first;
    }
    return moves[Random().nextInt(moves.length)];
  }

  List<int> _botHard(List<List<int>> moves) {
    int bestScore = -999999;
    List<int> bestMove = moves[0];
    for (final m in moves) {
      final saved = _simulateMove(m);
      final score = _evaluateBoard();
      _undoSimulation(m, saved);
      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
      }
    }
    return bestMove;
  }

  List<int> _botExpert(List<List<int>> moves) {
    int bestScore = -999999;
    List<int> bestMove = moves[0];
    for (final m in moves) {
      final saved = _simulateMove(m);
      // Look one move ahead for white's response
      int worstResponse = 999999;
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
          if (isWhite(_board[r][c])) {
            for (final wm in _getLegalMoves(r, c)) {
              final saved2 = _simulateMoveRaw(r, c, wm[0], wm[1]);
              final eval = _evaluateBoard();
              _undoSimulationRaw(r, c, wm[0], wm[1], saved2);
              if (eval < worstResponse) worstResponse = eval;
            }
          }
        }
      }
      _undoSimulation(m, saved);
      final score = worstResponse == 999999 ? _evaluateBoard() : worstResponse;
      if (score > bestScore) {
        bestScore = score;
        bestMove = m;
      }
    }
    return bestMove;
  }

  int _simulateMove(List<int> m) {
    final captured = _board[m[2]][m[3]];
    _board[m[2]][m[3]] = _board[m[0]][m[1]];
    _board[m[0]][m[1]] = empty;
    return captured;
  }

  void _undoSimulation(List<int> m, int captured) {
    _board[m[0]][m[1]] = _board[m[2]][m[3]];
    _board[m[2]][m[3]] = captured;
  }

  int _simulateMoveRaw(int fr, int fc, int tr, int tc) {
    final captured = _board[tr][tc];
    _board[tr][tc] = _board[fr][fc];
    _board[fr][fc] = empty;
    return captured;
  }

  void _undoSimulationRaw(int fr, int fc, int tr, int tc, int captured) {
    _board[fr][fc] = _board[tr][tc];
    _board[tr][tc] = captured;
  }

  // ─── DIALOGS ───

  void _showGameOverDialog() {
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
          content: Text(
            _gameResult,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _gameStarted = false;
                  _mode = ChessMode.none;
                });
              },
              child: Text(translate("chess_menu")),
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
        title: Text(translate("what_is_chess")),
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
                translate("chess_history"),
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
                translate("chess_rule_1"),
                translate("chess_rule_2"),
                translate("chess_rule_3"),
                translate("chess_rule_4"),
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

  // ─── CELL TAP ───

  void _onCellTap(int row, int col) {
    if (_gameOver || _botThinking) return;
    final piece = _board[row][col];

    // If a piece is selected and tapping a valid move target
    if (_selectedRow != null) {
      final isValid = _validMoves.any((m) => m[0] == row && m[1] == col);
      if (isValid) {
        _makeMove(row, col);
        return;
      }
    }

    // Select own piece
    if (piece != empty && isAlly(piece, _whiteToMove)) {
      setState(() {
        _selectedRow = row;
        _selectedCol = col;
        _validMoves = _getLegalMoves(row, col);
      });
    } else {
      setState(() {
        _selectedRow = null;
        _selectedCol = null;
        _validMoves = [];
      });
    }
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    if (!_gameStarted) return _buildModeSelection(c);
    if (_mode == ChessMode.friend) return _buildFriendGame(c);
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
        title: Text(translate("chess")),
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
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC62828).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.bold,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                translate("chess"),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                translate("chess_subtitle"),
                style: TextStyle(fontSize: 15, color: c.textSecondary),
              ),
              const SizedBox(height: 40),
              _buildModeCard(
                c,
                icon: CupertinoIcons.person_2_fill,
                title: translate("vs_friend"),
                subtitle: translate("vs_friend_desc"),
                gradient: const [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                onTap: () => _startGame(ChessMode.friend),
              ),
              const SizedBox(height: 16),
              _buildModeCard(
                c,
                icon: CupertinoIcons.desktopcomputer,
                title: translate("vs_bot"),
                subtitle: translate("vs_bot_desc"),
                gradient: const [Color(0xFFEF5350), Color(0xFFC62828)],
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
          boxShadow: [
            BoxShadow(
              color: gradient[1].withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
      builder: (ctx) => SafeArea(
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
                (ChessBotDifficulty.easy, translate("easy"), "🟢"),
                (ChessBotDifficulty.medium, translate("medium"), "🟡"),
                (ChessBotDifficulty.hard, translate("hard"), "🟠"),
                (ChessBotDifficulty.expert, translate("expert"), "🔴"),
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _startGame(ChessMode.bot, item.$1);
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
      ),
    );
  }

  // ─── BOT GAME ───

  Widget _buildBotGame(AppColors c) {
    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => setState(() {
            _gameStarted = false;
            _mode = ChessMode.none;
          }),
          icon: const Icon(CupertinoIcons.chevron_back, size: 24),
        ),
        title: Text("${translate("chess")} - ${translate("vs_bot")}"),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(CupertinoIcons.question_circle, size: 24),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildGameHeader(c),
          const SizedBox(height: 12),
          _buildChessBoard(c, false),
          const SizedBox(height: 12),
          _buildActionBar(c),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── FRIEND GAME ───

  Widget _buildFriendGame(AppColors c) {
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: Transform.rotate(
                angle: 3.14159,
                child: _buildPlayerArea(
                  c,
                  playerName: translate("player_2"),
                  pieceType: bKing,
                  isActive: !_whiteToMove && !_gameOver,
                  label: translate("black"),
                  isBlackSide: true,
                ),
              ),
            ),
            Expanded(child: _buildChessBoard(c, false)),
            SizedBox(
              height: 70,
              child: _buildPlayerArea(
                c,
                playerName: translate("player_1"),
                pieceType: wKing,
                isActive: _whiteToMove && !_gameOver,
                label: translate("white"),
                isBlackSide: false,
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
    required int pieceType,
    required bool isActive,
    required String label,
    required bool isBlackSide,
    bool showActions = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBlackSide
                  ? const Color(0xFF333333)
                  : const Color(0xFFF0EDE8),
              border: Border.all(
                color: isActive
                    ? c.accent
                    : (isBlackSide
                          ? const Color(0xFF555555)
                          : const Color(0xFFCCC8C3)),
                width: isActive ? 2.5 : 1,
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
            child: Center(child: pieceWidget(pieceType, 24)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          translate("your_turn"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
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
                _mode = ChessMode.none;
              }),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.border),
                ),
                child: Icon(
                  CupertinoIcons.xmark,
                  size: 14,
                  color: c.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => setState(() => _initBoard()),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(CupertinoIcons.refresh, size: 14, color: c.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ───

  Widget _buildGameHeader(AppColors c) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: c.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPlayerChip(c, true, _whiteToMove && !_gameOver),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _gameOver
                  ? const Icon(
                      CupertinoIcons.flag_fill,
                      size: 18,
                      color: Colors.orange,
                    )
                  : _botThinking
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.accent,
                      ),
                    )
                  : Icon(
                      _whiteToMove
                          ? CupertinoIcons.arrow_left
                          : CupertinoIcons.arrow_right,
                      size: 16,
                      key: ValueKey(_whiteToMove),
                      color: c.accent,
                    ),
            ),
          ),
          Expanded(
            child: _buildPlayerChip(c, false, !_whiteToMove && !_gameOver),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerChip(AppColors c, bool whitePlayer, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? c.accent.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? c.accent.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: whitePlayer
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (!whitePlayer) ...[
            pieceWidget(bKing, 24),
            const SizedBox(width: 8),
          ],
          Text(
            whitePlayer ? translate("white") : translate("black"),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          if (whitePlayer) ...[
            const SizedBox(width: 8),
            pieceWidget(wKing, 24),
          ],
        ],
      ),
    );
  }

  Widget _buildChessBoard(AppColors c, bool flipped) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.maxWidth;
          final cellSize = (side - 12) / 8; // account for padding
          return SizedBox(
            width: side,
            height: side,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF5D4037),
                border: Border.all(color: const Color(0xFF3E2723), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Column(
                  children: List.generate(8, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(8, (col) {
                          final isLight = (row + col) % 2 == 0;
                          final piece = _board[row][col];
                          final isSelected =
                              _selectedRow == row && _selectedCol == col;
                          final isValidTarget = _validMoves.any(
                            (m) => m[0] == row && m[1] == col,
                          );
                          final isLastFrom =
                              _lastMoveFrom != null &&
                              _lastMoveFrom![0] == row &&
                              _lastMoveFrom![1] == col;
                          final isLastTo =
                              _lastMoveTo != null &&
                              _lastMoveTo![0] == row &&
                              _lastMoveTo![1] == col;

                          Color bgColor = isLight
                              ? const Color(0xFFF0D9B5)
                              : const Color(0xFFB58863);
                          if (isSelected) {
                            bgColor = const Color(
                              0xFFF6F669,
                            ).withValues(alpha: 0.8);
                          } else if (isLastFrom || isLastTo) {
                            bgColor = isLight
                                ? const Color(0xFFF7EC6C).withValues(alpha: 0.6)
                                : const Color(
                                    0xFFDAC34B,
                                  ).withValues(alpha: 0.6);
                          }

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _onCellTap(row, col),
                              child: Container(
                                decoration: BoxDecoration(color: bgColor),
                                child: Stack(
                                  children: [
                                    if (piece != empty)
                                      Center(
                                        child: pieceWidget(
                                          piece,
                                          cellSize * 0.8,
                                        ),
                                      ),
                                    if (isValidTarget && piece == empty)
                                      Center(
                                        child: Container(
                                          width: cellSize * 0.28,
                                          height: cellSize * 0.28,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withValues(
                                              alpha: 0.18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (isValidTarget && piece != empty)
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black.withValues(
                                                alpha: 0.25,
                                              ),
                                              width: 3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              cellSize * 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
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
            translate("chess_menu"),
            () {
              setState(() {
                _gameStarted = false;
                _mode = ChessMode.none;
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
