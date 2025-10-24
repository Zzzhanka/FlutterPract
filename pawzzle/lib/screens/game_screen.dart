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
  int _resetCounter = 0;

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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF80AB),
              ),
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
    Navigator.pop(context);
    setState(() {
      _resetCounter++;
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 140),
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/ui/pause_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 28.0,
              ),
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
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _pauseIconButton(Icons.home, () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }),
                      const SizedBox(width: 20),
                      _pauseIconButton(Icons.restart_alt, _restartLevel),
                      const SizedBox(width: 20),
                      _pauseIconButton(Icons.play_arrow, () {
                        Navigator.pop(context);
                        setState(() {
                          _isPaused = false;
                          _stopwatch.start();
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pauseIconButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.pinkAccent.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 32, color: Colors.pinkAccent),
      ),
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
              // --- Контент без Center ---
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 40), // отступ сверху от края экрана
                  // --- Таймер ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ui/timer_bg.png',
                        height: 65,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        _formattedTime,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ), // теперь небольшой зазор между таймером и пазлом
                  // --- Пазл с подложкой ---
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ui/puzzle_bg.png',
                            width: MediaQuery.of(context).size.width * 0.6,
                            fit: BoxFit.contain,
                          ),
                          Transform.scale(
                            scale: 0.7,
                            child: SlidingPuzzleBoard(
                              key: ValueKey(_resetCounter),
                              imagePath: imagePath,
                              level: widget.level,
                              onWin: _onWin,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // небольшой нижний отступ
                ],
              ),

              // --- Кнопка паузы ---
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: _togglePause,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.pinkAccent.withOpacity(0.5),
                        width: 1.5,
                      ),
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
