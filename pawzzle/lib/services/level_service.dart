import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/puzzle_level.dart';

class LevelService {
  static final LevelService instance = LevelService._internal();
  LevelService._internal();

  final supabase = Supabase.instance.client;

  Future<List<PuzzleLevel>> fetchLevels() async {
    final response = await supabase
        .from('levels')
        .select('id, title, image_path, grid_size, shuffle_moves, page');

    final progressResponse = await supabase
        .from('progress')
        .select('level_id, unlocked, best_time, best_stars');

    final progressMap = {
      for (var row in progressResponse) row['level_id']: row,
    };

    return response.map<PuzzleLevel>((data) {
      final levelId = data['id'];
      final progress = progressMap[levelId];

      return PuzzleLevel(
        id: levelId,
        title: data['title'] ?? "Level $levelId",
        imagePath: data['image_path'],
        grid: data['grid_size'],
        shuffleMoves: data['shuffle_moves'],
        page: data['page'],
        isLocked: !(progress?['unlocked'] ?? (levelId == 1)),
        bestTime: progress?['best_time'],
        bestStars: progress?['best_stars'],
      );
    }).toList();
  }

  Future<void> saveLevelResult({
    required int levelId,
    required int stars,
    required int time,
  }) async {
    await supabase.from('progress').upsert({
      'level_id': levelId,
      'best_stars': stars,
      'best_time': time,
      'unlocked': true,
    });

    // ✅ разблокируем следующий уровень
    await unlockNextLevel(levelId);
  }

  Future<void> unlockNextLevel(int passedLevelId) async {
    final nextId = passedLevelId + 1;

    await supabase.from('progress').upsert({
      'level_id': nextId,
      'unlocked': true,
    });
  }
}
