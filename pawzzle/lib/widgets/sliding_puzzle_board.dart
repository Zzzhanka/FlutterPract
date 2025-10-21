import 'dart:math';
import 'package:flutter/material.dart';

class SlidingPuzzleBoard extends StatefulWidget {
  final String imagePath;
  final int grid;
  final int shuffleMoves;
  final VoidCallback onCompleted;

  const SlidingPuzzleBoard({
    super.key,
    required this.imagePath,
    required this.grid,
    required this.shuffleMoves,
    required this.onCompleted,
  });

  @override
  State<SlidingPuzzleBoard> createState() => _SlidingPuzzleBoardState();
}

class _SlidingPuzzleBoardState extends State<SlidingPuzzleBoard> {
  late List<int> _tiles;
  late int _emptyIndex;

  @override
  void initState() {
    super.initState();
    _resetPuzzle();
  }

  void _resetPuzzle() {
    final gridSize = widget.grid * widget.grid;
    _tiles = List.generate(gridSize, (i) => i);
    _emptyIndex = gridSize - 1;

    final rand = Random();
    for (int i = 0; i < widget.shuffleMoves; i++) {
      final moves = _getMovableTiles();
      final move = moves[rand.nextInt(moves.length)];
      _swapTiles(move);
    }
    setState(() {});
  }

  List<int> _getMovableTiles() {
    final x = _emptyIndex % widget.grid;
    final y = _emptyIndex ~/ widget.grid;
    final moves = <int>[];

    if (x > 0) moves.add(_emptyIndex - 1);
    if (x < widget.grid - 1) moves.add(_emptyIndex + 1);
    if (y > 0) moves.add(_emptyIndex - widget.grid);
    if (y < widget.grid - 1) moves.add(_emptyIndex + widget.grid);

    return moves;
  }

  void _swapTiles(int index) {
    final temp = _tiles[index];
    _tiles[index] = _tiles[_emptyIndex];
    _tiles[_emptyIndex] = temp;
    _emptyIndex = index;
  }

  void _onTap(int index) {
    if (_getMovableTiles().contains(index)) {
      setState(() {
        _swapTiles(index);
        if (_isSolved()) widget.onCompleted();
      });
    }
  }

  bool _isSolved() {
    for (int i = 0; i < _tiles.length; i++) {
      if (_tiles[i] != i) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;
    final tileSize = size / widget.grid;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: List.generate(_tiles.length, (i) {
          if (i == _emptyIndex) return const SizedBox.shrink();
          final x = (_tiles.indexOf(i) % widget.grid) * tileSize;
          final y = (_tiles.indexOf(i) ~/ widget.grid) * tileSize;
          final srcX = (i % widget.grid) / widget.grid;
          final srcY = (i ~/ widget.grid) / widget.grid;

          return AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            left: x,
            top: y,
            child: GestureDetector(
              onTap: () => _onTap(_tiles.indexOf(i)),
              child: ClipRect(
                child: Align(
                  alignment: Alignment(-1 + srcX * 2, -1 + srcY * 2),
                  widthFactor: 1 / widget.grid,
                  heightFactor: 1 / widget.grid,
                  child: Image.asset(
                    widget.imagePath,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
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
