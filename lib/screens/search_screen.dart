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
  String _selectedCategory = 'All';

  final _allGames = const [
    _SearchGameItem(
      'Sudoku',
      'Classic number puzzle',
      FontAwesomeIcons.tableCells,
      AppTheme.accentBlue,
      true,
      '/sudokuScreen',
      'Logic',
    ),
    _SearchGameItem(
      'Word Hunt',
      'Find hidden words',
      FontAwesomeIcons.font,
      AppTheme.softPurple,
      false,
      '/word-hunt',
      'Words',
    ),
    _SearchGameItem(
      'Memory',
      'Test your memory',
      FontAwesomeIcons.brain,
      AppTheme.warmOrange,
      false,
      '/memory',
      'Brain',
    ),
    _SearchGameItem(
      'Maze',
      'Find the exit',
      FontAwesomeIcons.route,
      Color(0xFF26A69A),
      false,
      '/maze',
      'Strategy',
    ),
  ];

  List<_SearchGameItem> _filteredGames = [];

  @override
  void initState() {
    super.initState();
    _filteredGames = _allGames;
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGames = _allGames.where((g) {
        final matchesQuery =
            query.isEmpty ||
            g.title.toLowerCase().contains(query) ||
            g.subtitle.toLowerCase().contains(query) ||
            g.category.toLowerCase().contains(query);
        final matchesCategory =
            _selectedCategory == 'All' || g.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Search', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Find your next puzzle',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 20),
              _buildResultsHeader(),
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
      onChanged: (_) => _applyFilters(),
      decoration: InputDecoration(
        hintText: 'Search puzzles...',
        hintStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 10),
          child: Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              )
            : null,
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Logic', 'Words', 'Brain', 'Strategy'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () {
              _selectedCategory = cat;
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.grey.shade200,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedCategory == 'All' ? 'All Games' : _selectedCategory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '${_filteredGames.length} ${_filteredGames.length == 1 ? 'game' : 'games'}',
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGameList() {
    if (_filteredGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.faceSadTear,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No games found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different search or category',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredGames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildGameTile(_filteredGames[index]),
    );
  }

  Widget _buildGameTile(_SearchGameItem game) {
    return GestureDetector(
      onTap: () => context.push(game.route),
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
              width: 52,
              height: 52,
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
                  Row(
                    children: [
                      Text(
                        game.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (!game.isAvailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Soon',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: game.isAvailable
                    ? game.color.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: game.isAvailable ? game.color : AppTheme.textSecondary,
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
  final bool isAvailable;
  final String route;
  final String category;

  const _SearchGameItem(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.isAvailable,
    this.route,
    this.category,
  );
}
