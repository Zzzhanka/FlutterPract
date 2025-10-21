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

  @override
  void initState() {
    super.initState();
    _levelsFuture = PuzzleLevel.loadLevels();
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
          child: FutureBuilder<List<PuzzleLevel>>(
            future: _levelsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final levels = snapshot.data!;
              final totalPages = (levels.length / 15).ceil();

              return PageView.builder(
                itemCount: totalPages,
                itemBuilder: (context, pageIndex) {
                  final start = pageIndex * 15;
                  final end = (start + 15).clamp(0, levels.length);
                  final pageLevels = levels.sublist(start, end);

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 35,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Выбор уровня',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
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
                                              builder: (_) =>
                                                  GameScreen(level: level),
                                            ),
                                          );
                                        },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // общий фон
                                      Image.asset(
                                        'assets/images/ui/level_bg.png',
                                        fit: BoxFit.cover,
                                      ),

                                      // номер уровня
                                      Positioned(
                                        top: 24,
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

                                      // замок или звёзды
                                      if (level.isLocked)
                                        Image.asset(
                                          'assets/images/ui/lock_icon.png',
                                          width: 18,
                                          height: 18,
                                        )
                                      else
                                        Positioned(
                                          bottom: 24,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(3, (index) {
                                              final isEarned =
                                                  index <
                                                  level
                                                      .stars; // звезда заработана?
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                    ),
                                                child: Image.asset(
                                                  'assets/images/ui/star_icon.png',
                                                  width: 18,
                                                  height: 18,
                                                  color: isEarned
                                                      ? Colors.yellow
                                                      : const Color.fromARGB(
                                                          255,
                                                          96,
                                                          96,
                                                          96,
                                                        ).withOpacity(0.4),
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
                          const SizedBox(height: 20),
                          Text(
                            'Страница ${pageIndex + 1}/$totalPages',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
