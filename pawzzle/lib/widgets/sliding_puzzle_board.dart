import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/puzzle_level.dart';
import '../storage/level_storage.dart';

class SlidingPuzzleBoard extends StatefulWidget {
  final PuzzleLevel level;
  const SlidingPuzzleBoard({super.key, required this.level});

  @override
  State<SlidingPuzzleBoard> createState() => _SlidingPuzzleBoardState();
}

class _SlidingPuzzleBoardState extends State<SlidingPuzzleBoard>
    with SingleTickerProviderStateMixin {
  late List<int> _tiles;
  late int _emptyIndex;
  late Ticker _ticker;
  double _elapsed = 0;

  @override
  void initState() {
    super.initState();
    _initPuzzle();
    _ticker = createTicker((elapsed) {
      setState(() => _elapsed = elapsed.inSeconds.toDouble());
    });
    _ticker.start();
  }

  void _initPuzzle() {
    _tiles = List.generate(16, (i) => i);
    _emptyIndex = 15;
    _shuffle();
  }

  void _shuffle() {
    final rand = Random();
    for (int i = 0; i < 500; i++) {
      final moves = _availableMoves();
      final move = moves[rand.nextInt(moves.length)];
      _swap(move);
    }
  }

  List<int> _availableMoves() {
    final moves = <int>[];
    final row = _emptyIndex ~/ 4;
    final col = _emptyIndex % 4;
    if (row > 0) moves.add(_emptyIndex - 4);
    if (row < 3) moves.add(_emptyIndex + 4);
    if (col > 0) moves.add(_emptyIndex - 1);
    if (col < 3) moves.add(_emptyIndex + 1);
    return moves;
  }

  void _swap(int tileIndex) {
    setState(() {
      final temp = _tiles[tileIndex];
      _tiles[tileIndex] = _tiles[_emptyIndex];
      _tiles[_emptyIndex] = temp;
      _emptyIndex = tileIndex;
    });
  }

  bool _isSolved() {
    for (int i = 0; i < 16; i++) {
      if (_tiles[i] != i) return false;
    }
    return true;
  }

  void _onTileTap(int index) {
    if (_availableMoves().contains(index)) {
      _swap(index);
      if (_isSolved()) {
        _ticker.stop();
        _showWinDialog(context);
      }
    }
  }

  void _showWinDialog(BuildContext context) async {
    int stars = 1;
    if (_elapsed < 30)
      stars = 3;
    else if (_elapsed < 60)
      stars = 2;

    await LevelStorage.unlockNextLevel(widget.level.id);
    await LevelStorage.saveStars(widget.level.id, stars);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        title: const Text('Победа!'),
        content: Text('Вы собрали пазл за $_elapsed сек.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(widget.level.imagePath);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '⏱ ${_elapsed.toStringAsFixed(1)} сек',
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 320,
          height: 320,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: 16,
            itemBuilder: (context, i) {
              final tile = _tiles[i];
              if (tile == 15) return const SizedBox.shrink();
              final row = tile ~/ 4;
              final col = tile % 4;
              return GestureDetector(
                onTap: () => _onTileTap(i),
                child: ClipRect(
                  child: Align(
                    alignment: Alignment((col / 1.5) - 1, (row / 1.5) - 1),
                    widthFactor: 0.25,
                    heightFactor: 0.25,
                    child: image,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
