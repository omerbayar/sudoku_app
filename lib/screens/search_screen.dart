import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../localization/app_localization.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  List<_SearchGameItem> get _allGames => [
    _SearchGameItem(
      translate('sudoku'),
      translate('classic_number_puzzle'),
      FontAwesomeIcons.tableCells,
      AppColors.gameBlue,
      true,
      '/sudokuScreen',
      'Logic',
    ),
    _SearchGameItem(
      translate('reversi'),
      translate('flip_and_conquer'),
      FontAwesomeIcons.circleHalfStroke,
      AppColors.gameTeal,
      true,
      '/reversi',
      'Strategy',
    ),
    _SearchGameItem(
      translate('chess'),
      translate('master_the_board'),
      FontAwesomeIcons.chess,
      const Color(0xFFEF5350),
      true,
      '/chess',
      'Strategy',
    ),
    _SearchGameItem(
      translate('coin_flip'),
      translate('coin_flip_subtitle'),
      FontAwesomeIcons.coins,
      const Color(0xFFDAA520),
      true,
      '/coin-flip',
      'Luck',
    ),
    _SearchGameItem(
      translate('word_hunt'),
      translate('find_hidden_words'),
      FontAwesomeIcons.font,
      AppColors.gamePurple,
      false,
      '/word-hunt',
      'Words',
    ),
    _SearchGameItem(
      translate('memory'),
      translate('test_your_memory'),
      FontAwesomeIcons.brain,
      AppColors.gameOrange,
      false,
      '/memory',
      'Brain',
    ),
    _SearchGameItem(
      translate('maze'),
      translate('find_the_exit'),
      FontAwesomeIcons.route,
      AppColors.gameTeal,
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
        final matchQ =
            query.isEmpty ||
            g.title.toLowerCase().contains(query) ||
            g.subtitle.toLowerCase().contains(query) ||
            g.category.toLowerCase().contains(query);
        final matchC =
            _selectedCategory == 'All' || g.category == _selectedCategory;
        return matchQ && matchC;
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
    final c = context.appColors;
    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                translate('search'),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                translate('find_your_next_puzzle'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              _buildSearchBar(c),
              const SizedBox(height: 16),
              _buildCategoryChips(c),
              const SizedBox(height: 20),
              _buildResultsHeader(c),
              const SizedBox(height: 12),
              Expanded(child: _buildGameList(c)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppColors c) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => _applyFilters(),
      decoration: InputDecoration(
        hintText: translate('search_puzzles'),
        hintStyle: TextStyle(color: c.textSecondary),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 16,
            color: c.textSecondary,
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

  Widget _buildCategoryChips(AppColors c) {
    final categories = ['All', 'Logic', 'Words', 'Brain', 'Strategy', 'Luck'];
    final categoryLabels = {
      'All': translate('all'),
      'Logic': translate('logic'),
      'Words': translate('words'),
      'Brain': translate('brain'),
      'Strategy': translate('strategy'),
      'Luck': translate('luck_game'),
    };
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final sel = cat == _selectedCategory;
          return GestureDetector(
            onTap: () {
              _selectedCategory = cat;
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: sel ? c.accent : c.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? c.accent : c.border),
              ),
              alignment: Alignment.center,
              child: Text(
                categoryLabels[cat] ?? cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                  color: sel ? Colors.white : c.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader(AppColors c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedCategory == 'All'
              ? translate('all_games')
              : {
                      'Logic': translate('logic'),
                      'Words': translate('words'),
                      'Brain': translate('brain'),
                      'Strategy': translate('strategy'),
                      'Luck': translate('luck_game'),
                    }[_selectedCategory] ??
                    _selectedCategory,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '${_filteredGames.length} ${_filteredGames.length == 1 ? translate('game_singular') : translate('game_plural')}',
          style: TextStyle(fontSize: 13, color: c.textSecondary),
        ),
      ],
    );
  }

  Widget _buildGameList(AppColors c) {
    if (_filteredGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.faceSadTear,
              size: 48,
              color: c.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              translate('no_games_found'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              translate('try_different_search'),
              style: TextStyle(color: c.textSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: _filteredGames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildGameTile(_filteredGames[index], c),
    );
  }

  Widget _buildGameTile(_SearchGameItem game, AppColors c) {
    return GestureDetector(
      onTap: () => context.push(game.route),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
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
                            color: c.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            translate('soon'),
                            style: TextStyle(
                              fontSize: 10,
                              color: c.textSecondary,
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
                    style: TextStyle(fontSize: 13, color: c.textSecondary),
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
                    : c.divider,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: game.isAvailable ? game.color : c.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchGameItem {
  final String title, subtitle, category, route;
  final IconData icon;
  final Color color;
  final bool isAvailable;
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
