import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/puzzle_level.dart';
import '../storage/level_storage.dart';

class SlidingPuzzleBoard extends StatefulWidget {
  final PuzzleLevel level;
  final String imagePath;
  final int gridSize;
  final bool paused;
  final VoidCallback? onWin;

  const SlidingPuzzleBoard({
    Key? key,
    required this.level,
    required this.imagePath,
    this.gridSize = 3,
    this.paused = false,
    this.onWin,
  }) : super(key: key);

  @override
  State<SlidingPuzzleBoard> createState() => _SlidingPuzzleBoardState();
}

class _SlidingPuzzleBoardState extends State<SlidingPuzzleBoard>
    with TickerProviderStateMixin {
  late List<List<int>> board;
  late int emptyX;
  late int emptyY;
  ui.Image? image;
  bool isShuffling = true;
  bool isWon = false;
  late Timer timer;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    _initBoard();
    _loadImage();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SlidingPuzzleBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paused != oldWidget.paused) {
      if (widget.paused) {
        timer.cancel();
      } else {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!widget.paused && mounted && !isWon) {
        setState(() => seconds++);
      }
    });
  }

  void _initBoard() {
    final n = widget.gridSize;
    board = List.generate(n, (i) => List.generate(n, (j) => i * n + j));
    emptyX = n - 1;
    emptyY = n - 1;
    board[emptyX][emptyY] = -1; // пустая клетка

    _shuffleBoard();
  }

  void _shuffleBoard() {
    final random = Random();
    const moves = [Offset(0, 1), Offset(1, 0), Offset(0, -1), Offset(-1, 0)];
    for (int i = 0; i < 200; i++) {
      final move = moves[random.nextInt(4)];
      final newX = emptyX + move.dx.toInt();
      final newY = emptyY + move.dy.toInt();
      if (newX >= 0 &&
          newX < widget.gridSize &&
          newY >= 0 &&
          newY < widget.gridSize) {
        _swapTiles(newX, newY);
      }
    }
    setState(() => isShuffling = false);
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load(widget.imagePath);
    final img = await decodeImageFromList(data.buffer.asUint8List());
    setState(() => image = img);
  }

  void _swapTiles(int x, int y) {
    final temp = board[emptyX][emptyY];
    board[emptyX][emptyY] = board[x][y];
    board[x][y] = temp;
    emptyX = x;
    emptyY = y;
  }

  bool _canMove(int x, int y) {
    return (x == emptyX && (y - emptyY).abs() == 1) ||
        (y == emptyY && (x - emptyX).abs() == 1);
  }

  void _moveTile(int x, int y) {
    if (isWon || isShuffling || widget.paused) return;
    if (_canMove(x, y)) {
      setState(() {
        _swapTiles(x, y);
      });
      _checkWin();
    }
  }

  void _checkWin() {
    int count = 0;
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        if (i == widget.gridSize - 1 && j == widget.gridSize - 1) continue;
        if (board[i][j] != count) return;
        count++;
      }
    }

    setState(() {
      isWon = true;
    });

    timer.cancel();
    _saveProgress();
    widget.onWin?.call();
  }

  void _saveProgress() async {
    final stars = seconds < 20
        ? 3
        : seconds < 40
        ? 2
        : 1;
    await LevelStorage.saveLevelResult(widget.level.id, stars);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    // Берём минимальную сторону экрана
    final boardSide = min(media.width, media.height) * 0.55;

    // Защита от слишком большого размера
    final size = boardSide.clamp(200.0, 420.0);

    final tileSize = size / widget.gridSize;

    if (image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            for (int i = 0; i < widget.gridSize; i++)
              for (int j = 0; j < widget.gridSize; j++)
                if (board[i][j] != -1)
                  Positioned(
                    left: j * tileSize,
                    top: i * tileSize,
                    child: GestureDetector(
                      onTap: () => _moveTile(i, j),
                      child: CustomPaint(
                        size: Size(tileSize, tileSize),
                        painter: _PuzzleTilePainter(
                          image!,
                          board[i][j],
                          widget.gridSize,
                        ),
                      ),
                    ),
                  ),
            if (isWon)
              Container(
                width: size,
                height: size,
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Text(
                    'Победа!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PuzzleTilePainter extends CustomPainter {
  final ui.Image image;
  final int index;
  final int gridSize;

  _PuzzleTilePainter(this.image, this.index, this.gridSize);

  @override
  void paint(Canvas canvas, Size size) {
    final tileX = index ~/ gridSize;
    final tileY = index % gridSize;

    final srcRect = Rect.fromLTWH(
      tileY * (image.width / gridSize),
      tileX * (image.height / gridSize),
      image.width / gridSize,
      image.height / gridSize,
    );

    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint();
    canvas.drawImageRect(image, srcRect, dstRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
