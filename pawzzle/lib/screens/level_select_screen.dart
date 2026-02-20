import 'package:flutter/material.dart';
import '../models/puzzle_level.dart';
import '../models/daily_level.dart'; // ✅ импорт модели DailyLevel
import 'game_screen.dart';
import 'main_menu_screen.dart';
import '../services/level_service.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late Future<List<PuzzleLevel>> _levelsFuture;
  final PageController _pageController = PageController();

  DailyLevel? _dailyLevel;
  Map<String, dynamic>? _dailyAchievement;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _levelsFuture = LevelService.instance.fetchLevels();
    _loadDaily();
  }

  Future<void> _loadDaily() async {
    final dailyChallenge = await LevelService.instance
        .fetchTodayDailyChallenge();
    if (dailyChallenge != null && dailyChallenge.type == 'level') {
      final level = await LevelService.instance.getLevelById(dailyChallenge.id);
      // открываем уровень
    } else if (dailyChallenge != null && dailyChallenge.type == 'achievement') {
      final ach = await LevelService.instance.getAchievementById(
        dailyChallenge.id,
      );
      // показываем ачивку
    }
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
                  // --- Страницы уровней ---
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
                            vertical: 20,
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
                              const SizedBox(height: 10),

                              // --- Сетка уровней ---
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
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1.5,
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
                                                ).then((_) {
                                                  setState(() {
                                                    _levelsFuture = LevelService
                                                        .instance
                                                        .fetchLevels();
                                                  });
                                                });
                                              },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.asset(
                                                'assets/images/ui/level_bg.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 18,
                                              child: Text(
                                                'Lv. ${level.id}',
                                                style: TextStyle(
                                                  fontSize: 14,
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
                                                width: 20,
                                                height: 20,
                                              )
                                            else
                                              Positioned(
                                                bottom: 18,
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
                                                            horizontal: 1.5,
                                                          ),
                                                      child: Image.asset(
                                                        'assets/images/ui/star_icon.png',
                                                        width: 16,
                                                        height: 16,
                                                        color: earned
                                                            ? Colors.yellow
                                                            : const Color.fromARGB(
                                                                80,
                                                                114,
                                                                114,
                                                                114,
                                                              ),
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
                              const SizedBox(height: 5),
                              Text(
                                'Страница ${pageIndex + 1} / $totalPages',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // --- Кнопка ежедневного уровня ---
                  if (_dailyLevel != null)
                    Positioned(
                      bottom: 120,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  level: PuzzleLevel(
                                    id: 999,
                                    title: _dailyLevel!.title,
                                    imagePath: _dailyLevel!.imagePath,
                                    grid: _dailyLevel!.gridSize,
                                    shuffleMoves: _dailyLevel!.shuffleMoves,
                                    page: 0,
                                    isLocked: false,
                                  ),
                                ),
                              ),
                            );

                            if (result == true) {
                              await LevelService.instance.addCoins(
                                _dailyLevel!.rewardCoins,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '+${_dailyLevel!.rewardCoins} монет!',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Ежедневный уровень'),
                        ),
                      ),
                    ),

                  // --- Кнопка ежедневной ачивки ---
                  if (_dailyAchievement != null)
                    Positioned(
                      bottom: 60,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await LevelService.instance.addCoins(
                              _dailyAchievement!['reward_coins'],
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ачивка выполнена! +${_dailyAchievement!['reward_coins']} монет',
                                ),
                              ),
                            );
                          },
                          child: Text(_dailyAchievement!['title']),
                        ),
                      ),
                    ),

                  // --- Левая стрелка ---
                  Positioned(
                    left: 15,
                    top: MediaQuery.of(context).size.height / 2 - 30,
                    child: GestureDetector(
                      onTap: _prevPage,
                      child: Opacity(
                        opacity: _currentPage > 0 ? 1.0 : 0.3,
                        child: Image.asset(
                          'assets/images/ui/arrow_left.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),

                  // --- Правая стрелка ---
                  Positioned(
                    right: 15,
                    top: MediaQuery.of(context).size.height / 2 - 30,
                    child: GestureDetector(
                      onTap: _nextPage,
                      child: Opacity(
                        opacity: _currentPage < totalPages - 1 ? 1.0 : 0.3,
                        child: Image.asset(
                          'assets/images/ui/arrow_right.png',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),

                  // --- Кнопка выхода в главное меню ---
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainMenuScreen(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/ui/home_icon.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
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
