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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _levelsFuture = PuzzleLevel.loadLevels();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
          child: FutureBuilder<List<PuzzleLevel>>(
            future: _levelsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final levels = snapshot.data!;
              final totalPages = (levels.length / 15).ceil();

              return Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: totalPages,
                    itemBuilder: (context, pageIndex) {
                      final start = pageIndex * 15;
                      final end = (start + 15).clamp(0, levels.length);
                      final pageLevels = levels.sublist(start, end);

                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 30,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Выбор уровня',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: Center(
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                        ),
                                    itemCount: pageLevels.length,
                                    itemBuilder: (context, i) {
                                      final level = pageLevels[i];
                                      return GestureDetector(
                                        onTap: level.isLocked
                                            ? null
                                            : () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => GameScreen(
                                                      level: level,
                                                    ),
                                                  ),
                                                ).then(
                                                  (_) => setState(() {
                                                    _levelsFuture =
                                                        PuzzleLevel.loadLevels();
                                                  }),
                                                );
                                              },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/ui/level_bg.png',
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              top: 22,
                                              child: Text(
                                                'Lv. ${level.id}',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: level.isLocked
                                                      ? Colors.grey.shade400
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (level.isLocked)
                                              Image.asset(
                                                'assets/images/ui/lock_icon.png',
                                                width: 22,
                                                height: 22,
                                              )
                                            else
                                              Positioned(
                                                bottom: 20,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: List.generate(3, (
                                                    index,
                                                  ) {
                                                    final earned =
                                                        index < level.stars;
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 2,
                                                          ),
                                                      child: Image.asset(
                                                        'assets/images/ui/star_icon.png',
                                                        width: 18,
                                                        height: 18,
                                                        color: earned
                                                            ? Colors.yellow
                                                            : Colors.white24,
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Страница ${pageIndex + 1} / $totalPages',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  if (_currentPage > 0)
                    Positioned(
                      left: 10,
                      top: MediaQuery.of(context).size.height / 2 - 30,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _prevPage,
                      ),
                    ),

                  if (_currentPage < totalPages - 1)
                    Positioned(
                      right: 10,
                      top: MediaQuery.of(context).size.height / 2 - 30,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: _nextPage,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
