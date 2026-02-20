import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/puzzle_level.dart';
import '../models/daily_level.dart';

class LevelService {
  static final LevelService instance = LevelService._internal();
  LevelService._internal();

  final supabase = Supabase.instance.client;

  /// Получение всех уровней
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

  /// Получение уровня по ID
  Future<PuzzleLevel?> getLevelById(int id) async {
    final levels = await fetchLevels();
    return levels.firstWhere((l) => l.id == id, orElse: () => levels.first);
  }

  /// Получение ачивки по UUID
  Future<Map<String, dynamic>?> getAchievementById(String id) async {
    return await supabase
        .from('daily_achievements')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  /// Добавление монет пользователю
  Future<void> addCoins(int amount) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.rpc(
      'increment_coins',
      params: {'user_id': user.id, 'amount': amount},
    );
  }

  /// Сохранение результата уровня
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

    // разблокируем следующий уровень
    await unlockNextLevel(levelId);
  }

  Future<void> unlockNextLevel(int passedLevelId) async {
    final nextId = passedLevelId + 1;

    await supabase.from('progress').upsert({
      'level_id': nextId,
      'unlocked': true,
    });
  }

  /// Получение ежедневного испытания
  Future<DailyChallenge?> fetchTodayDailyChallenge() async {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    final startOfDay = '$today 00:00:00';
    final endOfDay = '$today 23:59:59';

    final response = await supabase
        .from('daily_challenges')
        .select()
        .gte('challenge_date', startOfDay)
        .lte('challenge_date', endOfDay)
        .maybeSingle();

    if (response == null) return null;

    return DailyChallenge.fromMap(response);
  }
}

class DailyChallenge {
  final String type; // 'level' или 'achievement'
  final dynamic id; // int для уровня, String (UUID) для ачивки

  DailyChallenge({required this.type, required this.id});

  factory DailyChallenge.fromMap(Map<String, dynamic> map) {
    return DailyChallenge(type: map['challenge_type'], id: map['challenge_id']);
  }
}
