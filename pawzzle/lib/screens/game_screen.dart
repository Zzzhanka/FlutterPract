import 'dart:async';
import 'package:flutter/material.dart';
import '../models/puzzle_level.dart';
import '../widgets/sliding_puzzle_board.dart';
import 'level_select_screen.dart';

class GameScreen extends StatefulWidget {
  final PuzzleLevel level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isPaused = false;
  late Stopwatch _stopwatch;
  late Timer _timer;
  String _formattedTime = '00:00';
  late String imagePath;

  int _resetCounter = 0; // ключ для перезапуска виджета

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _startTimer();
    imagePath = 'assets/images/gameArt/${widget.level.id}.png';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() {
          final seconds = _stopwatch.elapsed.inSeconds;
          final minutes = seconds ~/ 60;
          final remaining = seconds % 60;
          _formattedTime =
              '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void _onWin() {
    _stopwatch.stop();
    _timer.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Победа!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Время: $_formattedTime'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('На выбор уровней'),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _stopwatch.stop();
        _showPauseMenu();
      } else {
        _stopwatch.start();
      }
    });
  }

  void _restartLevel() {
    Navigator.pop(context); // закрыть окно паузы
    setState(() {
      _resetCounter++; // обновляем ключ для ребилда
      _isPaused = false;
      _stopwatch
        ..reset()
        ..start();
    });
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Пауза',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _pauseButton(Icons.home, 'Главное меню', () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
              const SizedBox(height: 10),
              _pauseButton(Icons.restart_alt, 'Рестарт', _restartLevel),
              const SizedBox(height: 10),
              _pauseButton(Icons.play_arrow, 'Продолжить', () {
                Navigator.pop(context);
                setState(() {
                  _isPaused = false;
                  _stopwatch.start();
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pauseButton(IconData icon, String text, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(text, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: Colors.indigo.shade100,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ui/tutorial_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Сам пазл
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Таймер над пазлом
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formattedTime,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Пазл
                    SlidingPuzzleBoard(
                      key: ValueKey(_resetCounter),
                      imagePath: imagePath,
                      level: widget.level,
                      onWin: _onWin,
                    ),
                  ],
                ),
              ),

              // Постоянная кнопка паузы
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pause,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
