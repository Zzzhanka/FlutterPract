import 'package:flutter/material.dart';

// относительные импорты — файлы должны лежать в той же папке lib/screens/
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
              // Фон — надёжно растягиваем по контейнеру
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.asset(
                    'assets/images/ui/main_bg.png',
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    errorBuilder: (c, e, s) => Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ),

              // Кнопки — ряд, чуть ниже и левее
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
