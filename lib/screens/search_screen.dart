import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  final _allGames = [
    _SearchGameItem(
      'Sudoku',
      'Classic number puzzle',
      FontAwesomeIcons.tableCells,
      AppTheme.accentBlue,
      true,
      '/sudokuScreen',
    ),
    _SearchGameItem(
      'Word Hunt',
      'Find hidden words',
      FontAwesomeIcons.font,
      AppTheme.softPurple,
      false,
      '',
    ),
    _SearchGameItem(
      'Memory',
      'Test your memory',
      FontAwesomeIcons.brain,
      AppTheme.warmOrange,
      false,
      '',
    ),
    _SearchGameItem(
      'Maze',
      'Find the exit',
      FontAwesomeIcons.route,
      const Color(0xFF26A69A),
      false,
      '',
    ),
  ];

  List<_SearchGameItem> _filteredGames = [];

  @override
  void initState() {
    super.initState();
    _filteredGames = _allGames;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredGames = _allGames;
      } else {
        _filteredGames = _allGames
            .where((g) => g.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text('Search', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              Text('All Games', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Expanded(child: _buildGameList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _onSearch,
      decoration: InputDecoration(
        hintText: 'Search puzzles...',
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: const Icon(
          FontAwesomeIcons.magnifyingGlass,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchController.clear();
                  _onSearch('');
                },
              )
            : null,
      ),
    );
  }

  Widget _buildGameList() {
    if (_filteredGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.magnifyingGlass,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No games found',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredGames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final game = _filteredGames[index];
        return _buildGameTile(game);
      },
    );
  }

  Widget _buildGameTile(_SearchGameItem game) {
    return GestureDetector(
      onTap: game.isActive ? () => context.push(game.route) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: game.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(game.icon, size: 22, color: game.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (game.isActive)
              const Icon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: AppTheme.textSecondary,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchGameItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;
  final String route;

  const _SearchGameItem(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.isActive,
    this.route,
  );
}
