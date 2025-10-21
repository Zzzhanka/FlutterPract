import 'package:flutter/material.dart';
import '../models/puzzle_level.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late Future<List<PuzzleLevel>> _levelsFuture;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _levelsFuture = PuzzleLevel.loadLevels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PuzzleLevel>>(
        future: _levelsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final levels = snapshot.data!;
          final pageCount = (levels.length / 15).ceil();

          return Stack(
            children: [
              // фон
              Positioned.fill(
                child: Image.asset(
                  'assets/images/ui/tutorial_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              // контент
              PageView.builder(
                controller: _pageController,
                itemCount: pageCount,
                itemBuilder: (context, pageIndex) {
                  final start = pageIndex * 15;
                  final end = (start + 15).clamp(0, levels.length);
                  final pageLevels = levels.sublist(start, end);

                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1,
                        ),
                    itemCount: pageLevels.length,
                    itemBuilder: (context, i) {
                      final lvl = pageLevels[i];

                      return GestureDetector(
                        onTap: () {
                          if (!lvl.isLocked) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(level: lvl),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // фон карточки
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: AssetImage(
                                    lvl.isLocked
                                        ? 'assets/images/ui/locked_bg.png'
                                        : lvl.imagePath.isNotEmpty
                                        ? lvl.imagePath
                                        : 'assets/images/ui/level_placeholder.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // замочек
                            if (lvl.isLocked)
                              const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 36,
                              ),
                            // номер уровня
                            Positioned(
                              bottom: 40,
                              child: Text(
                                'Уровень ${lvl.id}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // звёзды
                            if (!lvl.isLocked)
                              Positioned(
                                bottom: 10,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Image.asset(
                                        'assets/images/ui/star.png',
                                        height: 18,
                                        color: index < lvl.stars
                                            ? Colors.yellow
                                            : Colors.grey[400],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              // индикатор страниц
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pageCount, (index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double selected = 0;
                          if (_pageController.hasClients) {
                            selected = _pageController.page ?? 0;
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: selected.round() == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected.round() == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
