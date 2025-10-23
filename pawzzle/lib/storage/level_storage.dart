import 'package:shared_preferences/shared_preferences.dart';

class LevelStorage {
  static const String _keyPrefix = 'level_';

  /// Сохраняем результат уровня (время прохождения)
  static Future<void> saveLevelResult(int levelId, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyPrefix$levelId', seconds);
  }

  /// Получаем результат уровня, если есть
  static Future<int?> getLevelResult(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyPrefix$levelId');
  }

  /// Проверяем, открыт ли уровень
  static Future<bool> isLevelUnlocked(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    if (levelId == 1) return true; // первый всегда доступен
    final prevLevel = prefs.getInt('$_keyPrefix${levelId - 1}');
    return prevLevel != null; // открыт, если предыдущий пройден
  }

  /// Открываем следующий уровень после успешного прохождения
  static Future<void> unlockNextLevel(int currentLevelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('unlocked_${currentLevelId + 1}', true);
  }

  /// Проверка: получено ли 3 звезды (по времени)
  static int calculateStars(int seconds) {
    if (seconds <= 30) return 3;
    if (seconds <= 60) return 2;
    return 1;
  }
}
