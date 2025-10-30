import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  /// загружаем прогресс игрока
  static Future<Map<int, Map<String, dynamic>>> getProgress() async {
    try {
      final res = await _client.from('progress').select().order('level_id');

      final Map<int, Map<String, dynamic>> result = {};

      for (var row in res) {
        result[row['level_id']] = {
          'best_time': row['best_time'],
          'best_stars': row['best_stars'],
          'unlocked': row['unlocked'],
        };
      }

      return result;
    } catch (e) {
      print('Error loading progress: $e');
      return {};
    }
  }

  /// обновляем прогресс после прохождения
  static Future<void> saveProgress({
    required int levelId,
    required int stars,
    required int time,
  }) async {
    try {
      await _client.from('progress').upsert({
        'level_id': levelId,
        'best_time': time,
        'best_stars': stars,
        'unlocked': true,
      });
    } catch (e) {
      print('Error saving progress: $e');
    }
  }
}
