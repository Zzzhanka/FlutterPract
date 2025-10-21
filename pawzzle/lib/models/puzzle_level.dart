import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class PuzzleLevel {
  final int id;
  final String imagePath;
  final int grid;
  final int shuffleMoves;

  // добавляем недостающие поля
  bool isLocked;
  int stars; // 0–3 звезды
  double bestTime; // лучшее время в секундах (если нужно)

  PuzzleLevel({
    required this.id,
    required this.imagePath,
    required this.grid,
    required this.shuffleMoves,
    this.isLocked = true,
    this.stars = 0,
    this.bestTime = 0,
  });

  factory PuzzleLevel.fromJson(Map<String, dynamic> json) {
    return PuzzleLevel(
      id: json['id'],
      imagePath: json['imagePath'],
      grid: json['grid'],
      shuffleMoves: json['shuffleMoves'],
      isLocked: json['isLocked'] ?? true,
      stars: json['stars'] ?? 0,
      bestTime: (json['bestTime'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'grid': grid,
    'shuffleMoves': shuffleMoves,
    'isLocked': isLocked,
    'stars': stars,
    'bestTime': bestTime,
  };

  static Future<List<PuzzleLevel>> loadLevels() async {
    // грузим данные из json-файла
    final jsonStr = await rootBundle.loadString('assets/data/levels.json');
    final List<dynamic> data = json.decode(jsonStr);

    final levels = data.map((e) => PuzzleLevel.fromJson(e)).toList();

    // первый уровень всегда открыт
    if (levels.isNotEmpty) {
      levels.first.isLocked = false;
    }

    return levels;
  }
}
