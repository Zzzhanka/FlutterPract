// lib/widgets/sliding_puzzle_board.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

class SlidingPuzzleBoard extends StatefulWidget {
  final String imagePath; // путь к картинке уровня
  final int grid; // например 3,4,5
  final int
  shuffleMoves; // количество рандомных легальных перемещений при перемешивании
  final void Function(Duration time, int moves)? onWin; // опционально

  const SlidingPuzzleBoard({
    super.key,
    required this.imagePath,
    this.grid = 4,
    this.shuffleMoves = 100,
    this.onWin,
  });

  @override
  State<SlidingPuzzleBoard> createState() => _SlidingPuzzleBoardState();
}

class _SlidingPuzzleBoardState extends State<SlidingPuzzleBoard>
    with SingleTickerProviderStateMixin {
  ui.Image? _image;
  bool _loading = true;

  late List<int>
  tiles; // значение: 0 — пустая, 1..n-1 — номера кусочков (в решённом состоянии tiles[i]==i)
  int gridSize = 4;
  int moveCount = 0;
  bool solved = false;

  late DateTime _startTime;
  Duration elapsed = Duration.zero;
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    gridSize = widget.grid;
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final data = await rootBundle.load(widget.imagePath);
      final bytes = data.buffer.asUint8List();
      final img = await decodeImageFromList(bytes);
      setState(() {
        _image = img;
        _newGame();
        _loading = false;
      });
      // старт таймера
      _startTime = DateTime.now();
      _ticker = createTicker((_) {
        if (!solved && mounted) {
          setState(() {
            elapsed = DateTime.now().difference(_startTime);
          });
        }
      })..start();
    } catch (e) {
      debugPrint('Ошибка загрузки ассета ${widget.imagePath}: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _newGame() {
    final n = gridSize * gridSize;
    // 0..n-1, 0 — пустая
    tiles = List<int>.generate(n, (i) => i);
    // убедимся, что пустая — в конце (решённое положение)
    // теперь сделаем shuffle, но выполним последовательность легальных перемещений
    final rnd = Random();
    int blankIndex = tiles.indexOf(0);
    for (int k = 0; k < widget.shuffleMoves; k++) {
      final neighbors = _neighbors(blankIndex);
      final swapIndex = neighbors[rnd.nextInt(neighbors.length)];
      _swap(blankIndex, swapIndex);
      blankIndex = swapIndex;
    }
    moveCount = 0;
    solved = false;
    _startTime = DateTime.now();
    elapsed = Duration.zero;
    setState(() {});
  }

  List<int> _neighbors(int index) {
    final row = index ~/ gridSize;
    final col = index % gridSize;
    final List<int> n = [];
    if (row > 0) n.add((row - 1) * gridSize + col);
    if (row < gridSize - 1) n.add((row + 1) * gridSize + col);
    if (col > 0) n.add(row * gridSize + (col - 1));
    if (col < gridSize - 1) n.add(row * gridSize + (col + 1));
    return n;
  }

  void _swap(int a, int b) {
    final t = tiles[a];
    tiles[a] = tiles[b];
    tiles[b] = t;
  }

  bool _canMove(int index) {
    final blank = tiles.indexOf(0);
    final r1 = index ~/ gridSize;
    final c1 = index % gridSize;
    final r2 = blank ~/ gridSize;
    final c2 = blank % gridSize;
    return (r1 - r2).abs() + (c1 - c2).abs() == 1;
  }

  void _tryMove(int index) {
    if (solved) return;
    if (!_canMove(index)) return; // двигаем только в пустую клетку
    final blank = tiles.indexOf(0);
    setState(() {
      _swap(index, blank);
      moveCount++;
      // проверим решение
      if (_isSolved()) {
        solved = true;
        _ticker?.stop();
        // вызов колбека победы (если нужен)
        widget.onWin?.call(elapsed, moveCount);
        Future.delayed(const Duration(milliseconds: 400), _showWinDialog);
      }
    });
  }

  bool _isSolved() {
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) return false;
    }
    return true;
  }

  void _showWinDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Победа! 🎉'),
        content: Text('Время: ${_formatTime(elapsed)}\nХоды: $moveCount'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newGame();
            },
            child: const Text('Сыграть снова'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final boardSize =
        min(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ) *
        0.8;
    final tileSize = boardSize / gridSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // информация
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⏱ ${_formatTime(elapsed)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text(
                'Ходы: $moveCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _newGame,
                child: const Text('Перемешать'),
              ),
            ],
          ),
        ),

        SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: List.generate(tiles.length, (i) {
              final value = tiles[i];
              if (value == 0)
                return const SizedBox.shrink(); // пустая клетка — не рисуем

              final row = i ~/ gridSize;
              final col = i % gridSize;

              final srcRow = value ~/ gridSize;
              final srcCol = value % gridSize;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                left: col * tileSize,
                top: row * tileSize,
                width: tileSize,
                height: tileSize,
                child: GestureDetector(
                  onTap: () => _tryMove(i),
                  child: CustomPaint(
                    painter: _TilePainter(
                      image: _image!,
                      srcCol: srcCol,
                      srcRow: srcRow,
                      grid: gridSize,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.6),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TilePainter extends CustomPainter {
  final ui.Image image;
  final int srcCol;
  final int srcRow;
  final int grid;

  _TilePainter({
    required this.image,
    required this.srcCol,
    required this.srcRow,
    required this.grid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final srcW = image.width / grid;
    final srcH = image.height / grid;

    final src = Rect.fromLTWH(srcCol * srcW, srcRow * srcH, srcW, srcH);
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint();
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant _TilePainter old) {
    return old.srcCol != srcCol ||
        old.srcRow != srcRow ||
        old.grid != grid ||
        old.image != image;
  }
}
