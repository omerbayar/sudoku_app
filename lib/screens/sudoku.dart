import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  SudokuScreenState createState() => SudokuScreenState();
}

class SudokuScreenState extends State<SudokuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(
            CupertinoIcons.chevron_back,
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text("Sudoku"),
      ),
      body: ListView(children: [Center(child: Text('Sudoku Screen'))]),
    );
  }
}
