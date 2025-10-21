import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle_level.dart';
import '../widgets/sliding_puzzle_board.dart';

class GameScreen extends StatefulWidget {
  final PuzzleLevel level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int starsEarned = 0;
  bool completed = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveProgress(Duration time, int moves) async {
    final prefs = await SharedPreferences.getInstance();

    // --- Логика получения звёзд ---
    // <30 секунд → 3 звезды, <60 → 2, иначе 1
    if (time.inSeconds < 30) {
      starsEarned = 3;
    } else if (time.inSeconds < 60) {
      starsEarned = 2;
    } else {
      starsEarned = 1;
    }

    // сохраняем звёзды (если больше прежнего)
    final currentStars = prefs.getInt('level_${widget.level.id}_stars') ?? 0;
    if (starsEarned > currentStars) {
      await prefs.setInt('level_${widget.level.id}_stars', starsEarned);
    }

    // разблокируем следующий уровень
    final nextId = widget.level.id + 1;
    await prefs.setBool('level_${nextId}_unlocked', true);
  }

  void _onWin(Duration time, int moves) async {
    if (completed) return; // чтобы не показывалось дважды
    completed = true;
    await _saveProgress(time, moves);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Победа 🎉', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Уровень ${widget.level.id} завершён!'),
            const SizedBox(height: 10),
            Text(
              'Время: ${_formatTime(time)}\nХоды: $moves',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  i < starsEarned ? Icons.star : Icons.star_border,
                  color: i < starsEarned ? Colors.amber : Colors.grey,
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // вернуться к выбору уровня
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('К уровням'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                completed = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Повторить'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ui/tutorial_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Уровень ${widget.level.id}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48), // для выравнивания
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Center(
                  child: SlidingPuzzleBoard(
                    imagePath: widget.level.imagePath,
                    grid: widget.level.grid,
                    shuffleMoves: widget.level.shuffleMoves,
                    onWin: _onWin,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
