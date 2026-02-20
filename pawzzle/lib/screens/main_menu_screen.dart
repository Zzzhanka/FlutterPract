import 'package:flutter/material.dart';
import '../models/puzzle_level.dart';
import '../services/level_service.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  double _scalePlay = 1.0;
  double _scaleSettings = 1.0;
  double _scaleHelp = 1.0;
  DailyChallenge? _dailyChallenge;
  PuzzleLevel? _dailyLevel;
  Map<String, dynamic>? _dailyAchievement;

  @override
  void initState() {
    super.initState();
    _loadDailyChallenge();
  }

  Future<void> _loadDailyChallenge() async {
    _dailyChallenge = await LevelService.instance.fetchTodayDailyChallenge();
    print('Daily challenge: $_dailyChallenge');

    if (_dailyChallenge != null) {
      if (_dailyChallenge!.type == 'level') {
        _dailyLevel = await LevelService.instance.getLevelById(
          _dailyChallenge!.id as int,
        );
      } else if (_dailyChallenge!.type == 'achievement') {
        _dailyAchievement = await LevelService.instance.getAchievementById(
          _dailyChallenge!.id.toString(),
        );
      }
    }
    setState(() {});
  }

  void _openDailyChallenge() {
    if (_dailyLevel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(level: _dailyLevel!)),
      );
    } else if (_dailyAchievement != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Ежедневная ачивка!'),
          content: Text(_dailyAchievement!['title']),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } else {
      // резервный уровень (если ежедневного нет)
      LevelService.instance.fetchLevels().then((levels) {
        if (levels.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GameScreen(level: levels.first)),
          );
        }
      });
    }
  }

  Widget _buildCircleButton({
    required String imagePath,
    required VoidCallback onTap,
    required double scale,
    required void Function(bool) onHover,
  }) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTapDown: (_) => onHover(true),
        onTapUp: (_) {
          onHover(false);
          onTap();
        },
        onTapCancel: () => onHover(false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            width: 95,
            height: 95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Фон
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.asset(
                    'assets/images/ui/main_bg.png',
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  ),
                ),
              ),

              // Кнопка Daily — всегда активна
              Positioned(
                top: 40,
                right: 30,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.today),
                  label: const Text('Ежедневное испытание'),
                  onPressed: _openDailyChallenge,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              // Основные кнопки
              Positioned(
                bottom: constraints.maxHeight * 0.18,
                left: constraints.maxWidth * 0.22,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCircleButton(
                      imagePath: 'assets/images/ui/play_icon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LevelSelectScreen(),
                          ),
                        );
                      },
                      scale: _scalePlay,
                      onHover: (isHover) {
                        setState(() => _scalePlay = isHover ? 1.08 : 1.0);
                      },
                    ),
                    const SizedBox(width: 26),
                    _buildCircleButton(
                      imagePath: 'assets/images/ui/settings_icon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      scale: _scaleSettings,
                      onHover: (isHover) {
                        setState(() => _scaleSettings = isHover ? 1.08 : 1.0);
                      },
                    ),
                    const SizedBox(width: 26),
                    _buildCircleButton(
                      imagePath: 'assets/images/ui/help_icon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TutorialScreen(),
                          ),
                        );
                      },
                      scale: _scaleHelp,
                      onHover: (isHover) {
                        setState(() => _scaleHelp = isHover ? 1.08 : 1.0);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
