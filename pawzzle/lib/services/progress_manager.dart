import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_data.dart';

class ProgressManager {
  static const String _key = 'puzzle_progress';

  static Future<Map<int, LevelData>> loadProgress(
    List<LevelData> baseLevels,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) {
      // по умолчанию: открыт только первый уровень
      final map = {for (var l in baseLevels) l.id: l};
      map[1] = LevelData(
        id: baseLevels[0].id,
        image: baseLevels[0].image,
        grid: baseLevels[0].grid,
        shuffle: baseLevels[0].shuffle,
        unlocked: true,
      );
      return map;
    }

    final decoded = json.decode(data) as Map<String, dynamic>;
    final map = {for (var l in baseLevels) l.id: l};
    decoded.forEach((id, val) {
      map[int.parse(id)] = LevelData.fromJson(val, map[int.parse(id)]!);
    });
    return map;
  }

  static Future<void> saveProgress(Map<int, LevelData> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = {
      for (var entry in levels.entries) '${entry.key}': entry.value.toJson(),
    };
    await prefs.setString(_key, json.encode(jsonMap));
  }

  static int calculateStars(Duration time) {
    final seconds = time.inSeconds;
    if (seconds < 30) return 3;
    if (seconds < 60) return 2;
    if (seconds < 90) return 1;
    return 0;
  }
}
