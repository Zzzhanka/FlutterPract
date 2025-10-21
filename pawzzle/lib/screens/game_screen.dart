import 'package:flutter/material.dart';
import '../models/puzzle_level.dart';
import '../widgets/sliding_puzzle_board.dart';

class GameScreen extends StatefulWidget {
  final PuzzleLevel level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _completed = false;

  void _onPuzzleCompleted() {
    setState(() => _completed = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ui/tutorial_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  'Уровень ${widget.level.id}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Center(
                    child: SlidingPuzzleBoard(
                      imagePath: widget.level.imagePath,
                      grid: widget.level.grid,
                      shuffleMoves: widget.level.shuffleMoves,
                      onCompleted: _onPuzzleCompleted,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_completed)
                  Column(
                    children: [
                      const Text(
                        'Пазл собран! 🎉',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Назад к уровням',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
