import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Omer's Puzzle App"),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 8),
              Expanded(child: _buildGameGrid()),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     context.push('/sudokuScreen');
      //   },
      //   tooltip: 'Play Sudoku',
      //   icon: const Icon(FontAwesomeIcons.playstation),
      //   label: const Text('Play Sudoku'),
      // ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose a puzzle to play",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Different puzzles are making, coming soon.🙋🏼‍♂️",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  //game grid
  Widget _buildGameGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildGameCard(
          title: 'Sudoku',
          icon: FontAwesomeIcons.tableCells,
          color: Colors.blue,
          onTap: () => context.push('/sudokuScreen'),
        ),
        _buildGameCard(
          title: 'Coming Soon',
          icon: FontAwesomeIcons.puzzlePiece,
          color: Colors.purple,
          onTap: () {},
        ),
        _buildGameCard(
          title: 'Coming Soon',
          icon: FontAwesomeIcons.brain,
          color: Colors.orange,
          onTap: () {},
        ),
        _buildGameCard(
          title: 'Coming Soon',
          icon: FontAwesomeIcons.gamepad,
          color: Colors.green,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGameCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
