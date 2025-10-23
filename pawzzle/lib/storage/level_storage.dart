import 'package:shared_preferences/shared_preferences.dart';

class LevelStorage {
  static const _unlockedKey = 'unlocked_levels';
  static const _starsKey = 'level_stars';

  /// Разблокировать следующий уровень
  static Future<void> unlockNextLevel(int currentId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getInt(_unlockedKey) ?? 1;
    if (currentId >= unlocked) {
      await prefs.setInt(_unlockedKey, currentId + 1);
    }
  }

  /// Получить количество звёзд для уровня
  static Future<int> getStars(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_starsKey$id') ?? 0;
  }

  /// Сохранить количество звёзд
  static Future<void> saveStars(int id, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('$_starsKey$id') ?? 0;
    if (stars > current) {
      await prefs.setInt('$_starsKey$id', stars);
    }
  }

  /// Проверить, открыт ли уровень
  static Future<bool> isLevelUnlocked(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getInt(_unlockedKey) ?? 1;
    return id <= unlocked;
  }
}
