import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/level_data.dart';

class SupabaseProgressService {
  final _client = Supabase.instance.client;
  final String table = 'progress';

  /// Загрузить прогресс
  Future<List<LevelData>> loadProgress(List<LevelData> baseLevels) async {
    final response = await _client.from(table).select();

    if (response.isEmpty) return baseLevels;

    final saved = Map.fromEntries(
      (response as List).map((row) => MapEntry(row['id'], row)),
    );

    return baseLevels.map((lvl) {
      if (saved.containsKey(lvl.id)) {
        final row = saved[lvl.id];
        return lvl.copyWith(
          bestTime: row['best_time'] != null
              ? (row['best_time'] as num).toDouble()
              : null,
          stars: row['stars'] ?? 0,
          unlocked: row['unlocked'] ?? false,
        );
      }
      return lvl;
    }).toList();
  }

  /// Сохранить прогресс уровня
  Future<void> saveLevel(LevelData level) async {
    await _client.from(table).upsert({
      'id': level.id,
      'best_time': level.bestTime,
      'stars': level.stars,
      'unlocked': level.unlocked,
    });
  }
}
